#!/usr/bin/env python3
"""
System utilities.
Updated 2020-08-14.
"""

import sys

from os.path import exists, isfile, join, realpath
from subprocess import CalledProcessError, call, check_output

from koopa.goalie import assert_is_dir
from koopa.print import stop


def find_bash():
    """
    Find bash.
    Updated 2020-08-14.
    """
    for bash in [
        find_cmd("bash"),
        "/usr/local/bin/bash",
        "/usr/bin/bash",
        "/bin/bash",
    ]:
        if bash and exists(bash):
            return bash
    raise IOError("Could not find bash in any standard location.")


def find_cmd(cmd):
    """
    Find a system command.
    Updated 2020-08-14.

    Modified version from bcbio provenance:
    https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/provenance/do.py
    """
    try:
        return check_output(["which", cmd]).decode().strip()
    except CalledProcessError:
        return None


def find_koopa():
    """
    Find koopa in standard locations.
    Updated 2020-08-14.

    Modified version of 'find_bash' from bcbio provenance:
    https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/provenance/do.py
    """
    for test_koopa in [
        find_cmd("koopa"),
        "/usr/local/bin/koopa",
        "/usr/local/koopa/bin/koopa",
        "~/.local/share/koopa/bin/koopa",
    ]:
        if test_koopa and exists(test_koopa):
            return test_koopa
    raise IOError("Could not find koopa in any standard location.")


def koopa_help():
    """
    Koopa help.
    Updated 2020-08-14.
    """
    cmd = sys.argv[0]
    pos_args = sys.argv[1:]
    if "-h" in pos_args or "--help" in pos_args:
        man_file = realpath(
            join(__file__, "..", "man", "man1", cmd + ".1")
        )
        if not isfile(man_file):
            stop("No documentation for '" + cmd + "'.")
        call(["man", man_file])
        sys.exit(0)


def koopa_prefix():
    """
    Koopa prefix.
    Updated 2020-08-11.
    """
    koopa = find_koopa()
    path = realpath(join(koopa, "..", ".."))
    assert_is_dir(path)
    return path
