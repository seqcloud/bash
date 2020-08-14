#!/usr/bin/env python3
"""
System utilities.
"""

from __future__ import print_function

import os
import subprocess
import sys

from koopa.shell import shell


def assert_is_not_file(path):
    """
    Does the input not contain a file?
    Updated 2020-08-14.
    """
    if os.path.isfile(path):
        stop("File exists: '" + path + "'")


def assert_is_dir(path):
    """
    Does the input contain a file?
    Updated 2020-08-14.
    """
    if not os.path.isdir(path):
        stop("Not directory: '" + path + "'")


def assert_is_file(path):
    """
    Does the input contain a file?
    Updated 2020-08-14.
    """
    if not os.path.isfile(path):
        stop("Not file: '" + path + "'")


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


def find_bash():
    """
    Find bash.
    Updated 2020-02-09.
    """
    for bash in [
        find_cmd("bash"),
        "/usr/local/bin/bash",
        "/usr/bin/bash",
        "/bin/bash",
    ]:
        if bash and os.path.exists(bash):
            return bash
    raise IOError("Could not find bash in any standard location.")


def find_cmd(cmd):
    """
    Find a system command.
    Updated 2020-08-12.

    Modified version from bcbio provenance:
    https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/provenance/do.py
    """
    try:
        return subprocess.check_output(["which", cmd]).decode().strip()
    except subprocess.CalledProcessError:
        return None


def find_koopa():
    """
    Find koopa in standard locations.
    Updated 2020-08-12.

    Modified version of 'find_bash' from bcbio provenance:
    https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/provenance/do.py
    """
    for test_koopa in [
        find_cmd("koopa"),
        "/usr/local/bin/koopa",
        "/usr/local/koopa/bin/koopa",
        "~/.local/share/koopa/bin/koopa",
    ]:
        if test_koopa and os.path.exists(test_koopa):
            return test_koopa
    raise IOError("Could not find koopa in any standard location.")


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


def koopa_help():
    """
    Koopa help.
    Updated 2020-08-14.
    """
    cmd = sys.argv[0]
    pos_args = sys.argv[1:]
    if "-h" in pos_args or "--help" in pos_args:
        man_file = os.path.realpath(
            os.path.join(__file__, "..", "man", "man1", cmd + ".1")
        )
        if not os.path.isfile(man_file):
            stop("No documentation for '" + cmd + "'.")
        subprocess.call(["man", man_file])
        sys.exit(0)


def koopa_prefix():
    """
    Koopa prefix.
    Updated 2020-08-11.
    """
    koopa = find_koopa()
    path = os.path.realpath(os.path.join(koopa, "..", ".."))
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
        stop("Specify 'output_file' or 'output_dir' but not both.")
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
            stop("Failed to download '" + output_file + "'.")
    if decompress is True:
        output_file = decompress_but_keep_original(output_file)
    return output_file


def stop(*args, **kwargs):
    """
    Stop with error message.

    See also:
    - 'sys.stderr.write()'.
    - https://stackoverflow.com/questions/5574702

    Updated 2020-08-14.
    """
    print(*args, file=sys.stderr, **kwargs)
    sys.exit(1)
