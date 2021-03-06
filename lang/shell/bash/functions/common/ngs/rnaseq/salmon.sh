#!/usr/bin/env bash

koopa:::salmon_index() { # {{{1
    # """
    # Generate salmon index.
    # @note Updated 2020-08-12.
    # """
    local fasta_file index_dir log_file threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'salmon'
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                index_dir="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set fasta_file index_dir
    koopa::assert_is_file "$fasta_file"
    if [[ -d "$index_dir" ]]
    then
        koopa::alert_note "Index exists at '${index_dir}'. Skipping."
        return 0
    fi
    koopa::h2 "Generating salmon index at '${index_dir}'."
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    log_file="$(dirname "$index_dir")/salmon-index.log"
    koopa::mkdir "$index_dir"
    salmon index \
        -k 31 \
        -p "$threads" \
        -i "$index_dir" \
        -t "$fasta_file" \
        2>&1 | tee "$log_file"
    return 0
}

koopa:::salmon_quant() { # {{{1
    # """
    # Run salmon quant (per sample).
    # @note Updated 2021-01-04.
    #
    # Quartz is currently using only '--validateMappings' and '--gcBias' flags.
    #
    # Important options:
    # * --libType='A': Enable ability to automatically infer (i.e. guess) the
    #   library type based on how the first few thousand reads map to the
    #   transcriptome. Note that most commercial vendors use Illumina TruSeq,
    #   which is dUTP, corresponding to 'ISR' for salmon.
    # * --validateMappings: Enables selective alignment of the sequencing reads
    #   when mapping them to the transcriptome. This can improve both the
    #   sensitivity and specificity of mapping and, as a result, can improve
    #   quantification accuracy.
    # * --numBootstraps: Compute bootstrapped abundance estimates. This is done
    #   by resampling (with replacement) from the counts assigned to the
    #   fragment equivalence classes, and then re-running the optimization
    #   procedure.
    # * --seqBias: Enable salmon to learn and correct for sequence-specific
    #   biases in the input data. Specifically, this model will attempt to
    #   correct for random hexamer priming bias, which results in the
    #   preferential sequencing of fragments starting with certain nucleotide
    #   motifs.
    # * --gcBias: Learn and correct for fragment-level GC biases in the input
    #   data. Specifically, this model will attempt to correct for biases in how
    #   likely a sequence is to be observed based on its internal GC content.
    # * --posBias: Experimental. Enable modeling of a position-specific fragment
    #   start distribution. This is meant to model non-uniform coverage biases
    #   that are sometimes present in RNA-seq data (e.g. 5' or 3' positional
    #   bias).
    #
    # Consider use of '--numGibbsSamples' instead of '--numBootstraps'.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       rnaseq/salmon.py
    # """
    local bootstraps fastq_r1 fastq_r1_bn fastq_r2 fastq_r2_bn id index_dir
    local lib_type log_file output_dir r1_tail r2_tail sample_output_dir threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'salmon'
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                bootstraps="${1#*=}"
                shift 1
                ;;
            --fastq-r1=*)
                fastq_r1="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                fastq_r2="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                index_dir="${1#*=}"
                shift 1
                ;;
            --lib-type=*)
                lib_type="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                r1_tail="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                r2_tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set bootstraps fastq_r1 fastq_r2 index_dir lib_type \
        output_dir r1_tail r2_tail
    koopa::assert_is_file "$fastq_r1" "$fastq_r2"
    fastq_r1_bn="$(basename "$fastq_r1")"
    fastq_r1_bn="${fastq_r1_bn/${r1_tail}/}"
    fastq_r2_bn="$(basename "$fastq_r2")"
    fastq_r2_bn="${fastq_r2_bn/${r2_tail}/}"
    koopa::assert_are_identical "$fastq_r1_bn" "$fastq_r2_bn"
    id="$fastq_r1_bn"
    sample_output_dir="${output_dir}/${id}"
    if [[ -d "$sample_output_dir" ]]
    then
        koopa::alert_note "Skipping '${id}'."
        return 0
    fi
    koopa::h2 "Quantifying '${id}' into '${sample_output_dir}'."
    koopa::dl 'Bootstraps' "$bootstraps"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    log_file="${sample_output_dir}/salmon-quant.log"
    koopa::mkdir "$sample_output_dir"
    salmon quant \
        --gcBias \
        --index="$index_dir" \
        --libType="$lib_type" \
        --mates1="$fastq_r1" \
        --mates2="$fastq_r2" \
        --numBootstraps="$bootstraps" \
        --output="$sample_output_dir" \
        --seqBias \
        --threads="$threads" \
        --validateMappings \
        2>&1 | tee "$log_file"
    return 0
}

koopa::run_salmon() { # {{{1
    # """
    # Run salmon on multiple samples (per FASTQ directory).
    # @note Updated 2021-05-22.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # """
    local bootstraps fastq_dir fastq_r1_files lib_type output_dir
    local r1_tail r2_tail
    koopa::assert_has_args "$#"
    bootstraps=30
    fastq_dir='fastq'
    lib_type='A'
    output_dir='salmon'
    r1_tail='_R1_001.fastq.gz'
    r2_tail='_R2_001.fastq.gz'
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                bootstraps="${1#*=}"
                shift 1
                ;;
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --fastq-dir=*)
                fastq_dir="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                index_dir="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                r1_tail="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                r2_tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${fasta_file:-}" ]] && [[ -z "${index_dir:-}" ]]
    then
        koopa::stop "Specify 'fasta-file' or 'index-dir'."
    elif [[ -n "${fasta_file:-}" ]] && [[ -n "${index_dir:-}" ]]
    then
        koopa::stop "Specify 'fasta-file' or 'index-dir', but not both."
    fi
    koopa::assert_is_set fastq_dir output_dir
    fastq_dir="$(koopa::strip_trailing_slash "$fastq_dir")"
    output_dir="$(koopa::strip_trailing_slash "$output_dir")"
    koopa::h1 'Running salmon.'
    koopa::activate_conda_env salmon
    fastq_dir="$(koopa::realpath "$fastq_dir")"
    koopa::dl 'fastq dir' "$fastq_dir"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    # Pipe GNU find into array.
    readarray -t fastq_r1_files <<< "$( \
        find "$fastq_dir" \
            -maxdepth 1 \
            -mindepth 1 \
            -type f \
            -name "*${r1_tail}" \
            -not -name '._*' \
            -print \
        | sort \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQs in '${fastq_dir}' with '${r1_tail}'."
    fi
    koopa::alert_info "${#fastq_r1_files[@]} samples detected."
    koopa::mkdir "$output_dir"
    # Index {{{2
    # --------------------------------------------------------------------------
    # Generate the genome index on the fly, if necessary.
    if [[ -n "${index_dir:-}" ]]
    then
        index_dir="$(koopa::realpath "$index_dir")"
    else
        index_dir="${output_dir}/salmon.idx"
        koopa:::salmon_index \
            --fasta-file="$fasta_file" \
            --index-dir="$index_dir"
    fi
    koopa::dl 'index' "$index_dir"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${r1_tail}/${r2_tail}}"
        koopa:::salmon_quant \
            --bootstraps="$bootstraps" \
            --fastq-r1="$fastq_r1" \
            --fastq-r2="$fastq_r2" \
            --index-dir="$index_dir" \
            --lib-type="$lib_type" \
            --output-dir="$output_dir" \
            --r1-tail="$r1_tail" \
            --r2-tail="$r2_tail"
    done
    return 0
}
