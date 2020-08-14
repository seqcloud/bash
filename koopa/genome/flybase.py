#!/usr/bin/env python3
"""
FlyBase genome utilities.
"""

from os.path import join, isfile

from koopa.files import decompress_but_keep_original, download
from koopa.genome import _genome_version
from koopa.shell import shell
from koopa.strings import paste_url


def download_flybase_genome(release_url, output_dir, decompress, dmel):
    """
    Download genome FASTA.
    Updated 2020-08-14.
    """
    output_dir = join(output_dir, "genome")
    fasta_url = paste_url(release_url, "fasta")
    download(url=paste_url(fasta_url, "md5sum.txt"), output_dir=output_dir)
    download(
        url=paste_url(fasta_url, "dmel-all-aligned-" + dmel + ".fasta.gz"),
        output_dir=output_dir,
        decompress=decompress,
    )


def download_flybase_transcriptome(release_url, output_dir, decompress, dmel):
    """
    Download FlyBase transcriptome FASTA.
    Updated 2020-02-09.
    """
    output_dir = join(output_dir, "transcriptome")
    cat_dir = join(output_dir, "cat")
    output_fasta_file = join(
        output_dir, "dmel-transcriptome-" + dmel + ".fasta.gz"
    )
    fasta_url = paste_url(release_url, "fasta")
    download(url=paste_url(fasta_url, "md5sum.txt"), output_dir=cat_dir)
    download(
        url=paste_url(fasta_url, "dmel-all-transcript-" + dmel + ".fasta.gz"),
        output_dir=cat_dir,
    )
    download(
        url=paste_url(fasta_url, "dmel-all-miRNA-" + dmel + ".fasta.gz"),
        output_dir=cat_dir,
    )
    download(
        url=paste_url(fasta_url, "dmel-all-miscRNA-" + dmel + ".fasta.gz"),
        output_dir=cat_dir,
    )
    download(
        url=paste_url(fasta_url, "dmel-all-ncRNA-" + dmel + ".fasta.gz"),
        output_dir=cat_dir,
    )
    download(
        url=paste_url(fasta_url, "dmel-all-pseudogene-" + dmel + ".fasta.gz"),
        output_dir=cat_dir,
    )
    download(
        url=paste_url(fasta_url, "dmel-all-tRNA-" + dmel + ".fasta.gz"),
        output_dir=cat_dir,
    )
    if not isfile(output_fasta_file):
        print("Concatenating '" + output_fasta_file + "'.")
        fasta_glob = join(cat_dir, "dmel-all-*.fasta.gz")
        shell("cat " + fasta_glob + " > " + output_fasta_file)
        if decompress is True:
            decompress_but_keep_original(output_fasta_file)


def download_flybase_gtf(release_url, output_dir, decompress, dmel):
    """
    Download FlyBase GTF file.
    Updated 2020-08-14.
    """
    output_dir = join(output_dir, "gtf")
    gtf_url = paste_url(release_url, "gtf")
    download(url=paste_url(gtf_url, "md5sum.txt"), output_dir=output_dir)
    download(
        url=paste_url(gtf_url, "dmel-all-" + dmel + ".gtf.gz"),
        output_dir=output_dir,
        decompress=decompress,
    )


def download_flybase_gff(release_url, output_dir, decompress, dmel):
    """
    Download FlyBase GFF3 file.
    Updated 2020-08-14.
    """
    output_dir = join(output_dir, "gff")
    gff_url = paste_url(release_url, "gff")
    download(url=paste_url(gff_url, "md5sum.txt"), output_dir=output_dir)
    download(
        url=paste_url(gff_url, "dmel-all-" + dmel + ".gff.gz"),
        output_dir=output_dir,
        decompress=decompress,
    )


def flybase_dmel_version():
    """
    Current Drosophila melanogaster genome version on FlyBase.
    Updated 2019-10-07.
    """
    return _genome_version("flybase", "--dmel")


def flybase_version():
    """
    Current FlyBase release version.
    Updated 2019-10-07.
    """
    return _genome_version("flybase")
