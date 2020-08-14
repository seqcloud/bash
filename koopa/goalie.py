#!/usr/bin/env python3
"""
Assertive checks.
Updated 2020-08-14.
"""

from os.path import isdir, isfile

from koopa.print import stop


def assert_is_not_file(path):
    """
    Does the input not contain a file?
    Updated 2020-08-14.
    """
    if isfile(path):
        stop("File exists: '" + path + "'")


def assert_is_dir(path):
    """
    Does the input contain a file?
    Updated 2020-08-14.
    """
    if not isdir(path):
        stop("Not directory: '" + path + "'")


def assert_is_file(path):
    """
    Does the input contain a file?
    Updated 2020-08-14.
    """
    if not isfile(path):
        stop("Not file: '" + path + "'")
