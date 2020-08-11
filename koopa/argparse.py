#!/usr/bin/env python3
"""
argparse functions.
"""

import argparse
import os


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
