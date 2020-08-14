#!/usr/bin/env python3
"""
Functions that print to console.
Updated 2020-08-14.
"""

from __future__ import print_function

import sys


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
