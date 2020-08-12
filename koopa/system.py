#!/usr/bin/env python3
"""
System utilities.
"""

from __future__ import print_function

import os
import subprocess
import sys

from koopa.shell import shell


def arg_string(*args):
    """
    Concatenate args into a string suitable for use in shell commands.
    Updated 2019-10-06.
    """
    if len(args) == 0:
        return None
    args = " %s" % args
    return args


def assert_is_not_file(path):
    """
    Does the input not contain a file?
    Updated 2019-10-07.
    """
    if os.path.isfile(path):
        print("Error: File exists: '" + path + "'")
        sys.exit(0)


def assert_is_dir(path):
    """
    Does the input contain a file?
    Updated 2020-06-03.
    """
    if not os.path.isdir(path):
        print("Error: Not directory: '" + path + "'")
        sys.exit(0)


def assert_is_file(path):
    """
    Does the input contain a file?
    Updated 2019-10-07.
    """
    if not os.path.isfile(path):
        print("Error: Not file: '" + path + "'")
        sys.exit(0)


def decompress_but_keep_original(file):
    """
    Decompress but keep original compressed file.
    Updated 2020-02-19.
    """
    assert_is_file(file)
    print("Decompressing '" + file + "'.")
    unzip_file = os.path.splitext(file)[0]
    shell("gunzip -c " + file + " > " + unzip_file)
    return unzip_file


def eprint(*args, **kwargs):
    """
    Print to stderr.

    See also:
    - 'sys.stderr.write()'.
    - https://stackoverflow.com/questions/5574702

    Updated 2019-10-06.
    """
    print(*args, file=sys.stderr, **kwargs)
    sys.exit(1)


def init_dir(name):
    """
    Make a directory recursively and don't error if exists.

    See also:
    - 'basejump::initDir()' in R.
    - 'mkdir -p' in shell.
    - https://stackoverflow.com/questions/600268

    Updated 2019-10-06.
    """
    os.makedirs(name=name, exist_ok=True)


# FIXME Need to rethink this. Doesn't work in standalone package.
# FIXME Check for /usr/local/bin/koopa or system PATH.
def koopa_prefix():
    """
    Koopa prefix (home).
    Updated 2020-08-11.
    """
    path = os.path.realpath(os.path.join(__file__, "..", "..", "..", ".."))
    assert_is_dir(path)
    return path


def paste_url(*args):
    """
    Paste URL.

    Deals with sanitization of trailing slashes automatically.

    Examples:
    paste_url("https://basejump.acidgenomics.com", "news", "news-0.1.html")

    See also:
    - urlparse
    - https://codereview.stackexchange.com/questions/175421/

    Updated 2019-10-07.
    """
    out = "/".join(arg.strip("/") for arg in args)
    return out


def download(url, output_file=None, output_dir=None, decompress=False):
    """
    Download a file using curl.
    If output_file is unset, download to working directory as basename.
    Updated 2019-11-04.
    """
    if not (output_file is None or output_dir is None):
        eprint("Error: Specify 'output_file' or 'output_dir' but not both.")
    if output_file is None:
        output_file = os.path.basename(url)
    if output_dir is None:
        output_dir = os.path.dirname(output_file)
    output_file = os.path.join(output_dir, output_file)
    if os.path.isfile(output_file):
        print("File exists: '" + output_file + "'.")
    else:
        print("Downloading '" + output_file + "'.")
        init_dir(output_dir)
        try:
            subprocess.check_call(["curl", "-L", "-o", output_file, url])
        except subprocess.CalledProcessError:
            eprint("Failed to download '" + output_file + "'.")
    if decompress is True:
        output_file = decompress_but_keep_original(output_file)
    return output_file
