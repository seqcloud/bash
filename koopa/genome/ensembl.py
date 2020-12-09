#!/usr/bin/env python3
"""
Ensembl genome utilities.
"""

from os.path import join

from koopa.genome import _genome_version
from koopa.files import download
from koopa.strings import paste_url
from shutil import copyfileobj


def download_ensembl_genome(
    organism, build, release_url, output_dir, decompress
):
    """
    Download Ensembl genome FASTA.
    Updated 2020-08-14.
    """
    output_dir = join(output_dir, "genome")
    base_url = paste_url(release_url, "fasta", organism.lower(), "dna")
    readme_url = paste_url(base_url, "README")
    checksums_url = paste_url(base_url, "CHECKSUMS")
    if organism in ("Homo_sapiens", "Mus_musculus"):
        assembly = "primary_assembly"
    else:
        assembly = "toplevel"
    fasta_url = paste_url(
        base_url, organism + "." + build + ".dna." + assembly + ".fa.gz"
    )
    download(url=readme_url, output_dir=output_dir)
    download(url=checksums_url, output_dir=output_dir)
    download(url=fasta_url, output_dir=output_dir, decompress=decompress)


# FIXME Need to combine cDNA and ncDNA files here.
# FIXME SAVE TO SUBDIRECTORIES THEN COMBINE.
def download_ensembl_transcriptome(
    organism, build, release_url, output_dir, decompress
):
    """
    Download Ensembl transcriptome FASTA.
    Updated 2020-12-09.
    """
    output_dir = join(output_dir, "transcriptome")
    transcriptome_file = join(output_dir, "transcriptome.fa.gz")
    base_url = paste_url(release_url, "fasta", organism.lower())
    # cDNA.
    cdna_output_dir = join(output_dir, "cdna")
    cdna_base_url = paste_url(base_url, "cdna")
    cdna_readme_url = paste_url(cdna_base_url, "README")
    cdna_checksums_url = paste_url(cdna_base_url, "CHECKSUMS")
    cdna_fasta_file_basename = organism + "." + build + ".cdna.all.fa.gz"
    cdna_fasta_file = join(cdna_output_dir, cdna_fasta_file_basename)
    cdna_fasta_url = paste_url(cdna_base_url, cdna_fasta_file_basename)
    # ncDNA.
    ncdna_output_dir = join(output_dir, "ncdna")
    ncdna_base_url = paste_url(base_url, "ncdna")
    ncdna_readme_url = paste_url(ncdna_base_url, "README")
    ncdna_checksums_url = paste_url(ncdna_base_url, "CHECKSUMS")
    ncdna_fasta_file_basename = organism + "." + build + ".ncdna.all.fa.gz"
    ncdna_fasta_file = join(ncdna_output_dir, ncdna_fasta_file_basename)
    ncdna_fasta_url = paste_url(ncdna_base_url, ncdna_fasta_file_basename)
    # Download files.
    download(url=cdna_readme_url, output_dir=cdna_output_dir)
    download(url=ncdna_readme_url, output_dir=ncdna_output_dir)
    download(url=cdna_checksums_url, output_dir=cdna_output_dir)
    download(url=ncdna_checksums_url, output_dir=ncdna_output_dir)
    download(url=cdna_fasta_url, output_file=cdna_fasta_file, decompress=decompress)
    download(url=ncdna_fasta_url, output_file=ncdna_fasta_file, decompress=decompress)
    # Combine cDNA and ncDNA into a single merged FASTA. This method is memory
    # efficient. It automatically reads the input files chunk by chunk for you,
    # which is more more efficient and reading the input files in and will work
    # even if some of the input files are too large to fit into memory.
    # - https://stackoverflow.com/a/18209002
    # - https://stackoverflow.com/a/27077437
    # FIXME MAKE THIS A NEW FUNCTION IN FILES.
    # > with open(..., 'wb') as wfp:
    # >     for fn in filenames:
    # >         with open(fn, 'rb') as rfp:
    # >             copyfileobj(rfp, wfp)
    with open(transcriptome_file, 'wb') as wfd:
        for f in [cdna_fasta_file, ncdna_fasta_file]:
            with open(f, 'rb') as fd:
                copyfileobj(fd, wfd)


def download_ensembl_gtf(
    organism, build, release, release_url, output_dir, decompress
):
    """
    Download Ensembl GTF file.
    Updated 2020-02-09.
    """
    output_dir = join(output_dir, "gtf")
    base_url = paste_url(release_url, "gtf", organism.lower())
    readme_url = paste_url(base_url, "README")
    checksums_url = paste_url(base_url, "CHECKSUMS")
    gtf_url = paste_url(
        base_url, organism + "." + build + "." + release + ".gtf.gz"
    )
    download(url=readme_url, output_dir=output_dir)
    download(url=checksums_url, output_dir=output_dir)
    download(url=gtf_url, output_dir=output_dir, decompress=decompress)
    if organism in ("Homo_sapiens", "Mus_musculus"):
        gtf_patch_url = paste_url(
            base_url,
            organism
            + "."
            + build
            + "."
            + release
            + ".chr_patch_hapl_scaff.gtf.gz",
        )
        download(
            url=gtf_patch_url, output_dir=output_dir, decompress=decompress
        )


def download_ensembl_gff(
    organism, build, release, release_url, output_dir, decompress
):
    """
    Download Ensembl GFF3 file.
    Updated 2020-02-09.
    """
    output_dir = join(output_dir, "gff")
    base_url = paste_url(release_url, "gff3", organism.lower())
    readme_url = paste_url(base_url, "README")
    checksums_url = paste_url(base_url, "CHECKSUMS")
    gff_url = paste_url(
        base_url, organism + "." + build + "." + release + ".gff3.gz"
    )
    download(url=readme_url, output_dir=output_dir)
    download(url=checksums_url, output_dir=output_dir)
    download(url=gff_url, output_dir=output_dir, decompress=decompress)
    if organism in ("Homo sapiens", "Mus musculus"):
        gtf_patch_url = paste_url(
            base_url,
            organism
            + "."
            + build
            + "."
            + release
            + ".chr_patch_hapl_scaff.gff3.gz",
        )
        download(
            url=gtf_patch_url, output_dir=output_dir, decompress=decompress
        )


def ensembl_version():
    """
    Current Ensembl release version.
    Updated 2019-10-07.
    """
    return _genome_version("ensembl")
