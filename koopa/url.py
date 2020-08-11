#!/usr/bin/env python3
"""
URL processing.
"""

import urllib.parse


def url_encode(string):
    """
    URL encode.
    Updated 2020-08-07.
    """
    string = urllib.parse.quote(string)
    return string
