#!/usr/bin/env python3
"""
Argument parsing functions.
"""

from argparse import ArgumentTypeError
from os.path import isdir


def arg_string(*args):
    """
    Concatenate args into a string suitable for use in shell commands.
    Updated 2019-10-06.
    """
    if len(args) == 0:
        return None
    args = " %s" % args
    return args


def dir_path(path):
    """
    Directory path.
    Updated 2020-08-14.
    """
    if isdir(path):
        return path
    raise ArgumentTypeError(f"readable_dir:{path} is not a valid path")
