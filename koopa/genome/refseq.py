#!/usr/bin/env python3
"""
RefSeq genome utilities.
"""

import os

from koopa.genome import _genome_version
from koopa.system import download, paste_url


def download_refseq_genome(build, release_url, output_dir, decompress):
    """
    Download RefSeq genome FASTA.
    Updated 2020-02-09.
    """
    download(
        url=paste_url(release_url, build + "_latest_genomic.fna.gz"),
        output_dir=os.path.join(output_dir, "genome"),
        decompress=decompress,
    )


def download_refseq_transcriptome(build, release_url, output_dir, decompress):
    """
    Download RefSeq transcriptome FASTA.
    Updated 2020-02-09.
    """
    download(
        url=paste_url(release_url, build + "_latest_rna.fna.gz"),
        output_dir=os.path.join(output_dir, "transcriptome"),
        decompress=decompress,
    )


def download_refseq_gff(build, release_url, output_dir, decompress):
    """
    Download RefSeq GFF3 file.
    Updated 2020-02-09.
    """
    download(
        url=paste_url(release_url, build + "_latest_genomic.gff.gz"),
        output_dir=os.path.join(output_dir, "gff"),
        decompress=decompress,
    )


def download_refseq_gtf(build, release_url, output_dir, decompress):
    """
    Download RefSeq GTF file.
    Updated 2020-02-09.
    """
    download(
        url=paste_url(release_url, build + "_latest_genomic.gtf.gz"),
        output_dir=os.path.join(output_dir, "gtf"),
        decompress=decompress,
    )


def refseq_version():
    """
    Current RefSeq release version.
    Updated 2019-10-07.
    """
    return _genome_version("refseq")
