#!/usr/bin/env python3
"""
Argument parsing functions.
"""

import argparse
import os


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
    Updated 2020-02-09.
    """
    if os.path.isdir(path):
        return path
    raise argparse.ArgumentTypeError(
        f"readable_dir:{path} is not a valid path"
    )
