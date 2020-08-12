#!/usr/bin/env python3
"""
Genome utilities.
"""

import os
import subprocess

from koopa.shell import shell
from koopa.system import arg_string, koopa_prefix


# FIXME Need to rework this. koopa_prefix not picked up correctly.
def _genome_version(name, *args):
    """
    Internal shared genome version fetcher.
    Updated 2020-06-03.
    """
    cmd = os.path.join(koopa_prefix(), "bin", "current-" + name + "-version")
    args = arg_string(*args)
    if args is not None:
        cmd = cmd + args
    out = subprocess.check_output(cmd, shell=True, universal_newlines=True)
    out = out.rstrip()
    return out


def tx2gene_from_fasta(source_name, output_dir):
    """
    Generate tx2gene.csv mapping file from transcriptome FASTA.
    Updated 2020-06-03.

    Note that this function is currently called by genome download scripts, and
    assumes that output_dir has a specific structure, containing a
    "transcriptome" subdirectory with the FASTA.
    """
    cmd = os.path.join(
        koopa_prefix(), "bin", "tx2gene-from-" + source_name + "-fasta"
    )
    transcriptome_dir = os.path.join(output_dir, "transcriptome")
    input_file = os.path.join(transcriptome_dir, "*.fa*.gz")
    output_file = os.path.join(transcriptome_dir, "tx2gene.csv")
    if os.path.isfile(output_file):
        print("File exists: '" + output_file + "'.")
        return output_file
    shell(cmd + " " + input_file + " " + output_file)
    return output_file
