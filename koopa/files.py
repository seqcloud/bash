#!/usr/bin/env python3
"""
File manipulation utilities.
Updated 2020-08-14.
"""

from os import makedirs
from os.path import basename, dirname, isfile, join, splitext
from subprocess import CalledProcessError, check_call

from koopa.goalie import assert_is_file
from koopa.print import stop
from koopa.shell import shell


def decompress_but_keep_original(file):
    """
    Decompress but keep original compressed file.
    Updated 2020-02-19.
    """
    assert_is_file(file)
    print("Decompressing '" + file + "'.")
    unzip_file = splitext(file)[0]
    shell("gunzip -c " + file + " > " + unzip_file)
    return unzip_file


def download(url, output_file=None, output_dir=None, decompress=False):
    """
    Download a file using curl.
    If output_file is unset, download to working directory as basename.
    Updated 2019-11-04.
    """
    if not (output_file is None or output_dir is None):
        stop("Specify 'output_file' or 'output_dir' but not both.")
    if output_file is None:
        output_file = basename(url)
    if output_dir is None:
        output_dir = dirname(output_file)
    output_file = join(output_dir, output_file)
    if isfile(output_file):
        print("File exists: '" + output_file + "'.")
    else:
        print("Downloading '" + output_file + "'.")
        init_dir(output_dir)
        try:
            check_call(["curl", "-L", "-o", output_file, url])
        except CalledProcessError:
            stop("Failed to download '" + output_file + "'.")
    if decompress is True:
        output_file = decompress_but_keep_original(output_file)
    return output_file


def init_dir(name):
    """
    Make a directory recursively and don't error if exists.
    Updated 2020-08-14.

    See also:
    - 'basejump::initDir()' in R.
    - 'mkdir -p' in shell.
    - https://stackoverflow.com/questions/600268
    """
    makedirs(name=name, exist_ok=True)
