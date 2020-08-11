#!/usr/bin/env python3
"""
WormBase genome utilities.
"""

from koopa.genome import _genome_version


def wormbase_version():
    """
    Current WormBase release version.
    Updated 2019-10-07.
    """
    return _genome_version("wormbase")
