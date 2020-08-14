#!/usr/bin/env python3
"""
Ensembl genome utilities.
"""

from os.path import join

from koopa.genome import _genome_version
from koopa.files import download
from koopa.strings import paste_url


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


def download_ensembl_transcriptome(
    organism, build, release_url, output_dir, decompress
):
    """
    Download Ensembl transcriptome FASTA.
    Updated 2020-08-14.
    """
    output_dir = join(output_dir, "transcriptome")
    base_url = paste_url(release_url, "fasta", organism.lower(), "cdna")
    readme_url = paste_url(base_url, "README")
    checksums_url = paste_url(base_url, "CHECKSUMS")
    fasta_url = paste_url(base_url, organism + "." + build + ".cdna.all.fa.gz")
    download(url=readme_url, output_dir=output_dir)
    download(url=checksums_url, output_dir=output_dir)
    download(url=fasta_url, output_dir=output_dir, decompress=decompress)


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
