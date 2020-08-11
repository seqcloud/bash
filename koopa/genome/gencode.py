#!/usr/bin/env python3
"""
GENCODE genome utilities.
"""

import os

from koopa.genome import _genome_version
from koopa.system import download


def download_gencode_genome(genome_fasta_url, output_dir, decompress):
    """
    Download GENCODE genome FASTA.
    Updated 2020-02-09.
    """
    download(
        url=genome_fasta_url,
        output_dir=os.path.join(output_dir, "genome"),
        decompress=decompress,
    )


def download_gencode_transcriptome(
    transcriptome_fasta_url, output_dir, decompress
):
    """
    Download GENCODE transcriptome FASTA.
    Updated 2020-02-09.
    """
    download(
        url=transcriptome_fasta_url,
        output_dir=os.path.join(output_dir, "transcriptome"),
        decompress=decompress,
    )


def download_gencode_gtf(gtf_url, output_dir, decompress):
    """
    Download GENCODE GTF file.
    Updated 2020-02-09.
    """
    download(
        url=gtf_url,
        output_dir=os.path.join(output_dir, "gtf"),
        decompress=decompress,
    )


def download_gencode_gff(gff_url, output_dir, decompress):
    """
    Download GENCODE GFF3 file.
    Updated 2020-02-09.
    """
    download(
        url=gff_url,
        output_dir=os.path.join(output_dir, "gff"),
        decompress=decompress,
    )


def gencode_version(organism):
    """
    Current GENCODE release version.
    Updated 2019-10-07.
    """
    return _genome_version("gencode", ('"' + organism + '"'))
