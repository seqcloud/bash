#!/usr/bin/env python3
"""
Genome utilities.
"""

from os.path import isfile, join
from subprocess import check_output

from koopa.arg import arg_string
from koopa.shell import shell
from koopa.system import koopa_prefix


def _genome_version(name, *args):
    """
    Internal shared genome version fetcher.
    Updated 2020-08-14.
    """
    cmd = join(koopa_prefix(), "bin", "current-" + name + "-version")
    args = arg_string(*args)
    if args is not None:
        cmd = cmd + args
    out = check_output(cmd, shell=True, universal_newlines=True)
    out = out.rstrip()
    return out


def tx2gene_from_fasta(source_name, output_dir):
    """
    Generate tx2gene.csv mapping file from transcriptome FASTA.
    Updated 2020-12-09.

    Note that this function is currently called by genome download scripts, and
    assumes that output_dir has a specific structure, containing a
    "transcriptome" subdirectory with the FASTA.
    """
    cmd = join(koopa_prefix(), "bin", "tx2gene-from-" + source_name + "-fasta")
    transcriptome_dir = join(output_dir, "transcriptome")
    input_file = join(transcriptome_dir, "*.fa*.gz")
    output_file = join(transcriptome_dir, "tx2gene.csv")
    if isfile(output_file):
        print("File exists: '" + output_file + "'.")
        return output_file
    # FIXME THIS ISNT SHOWING THE TX2GENE MESSAGE CORRECTLY.
    shell(cmd + " " + input_file + " " + output_file)
    return output_file
