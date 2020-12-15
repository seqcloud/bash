#!/usr/bin/env python3
"""
URL processing.
"""

from urllib import parse


def paste_url(*args):
    """
    Paste URL.
    Updated 2019-10-07.

    Deals with sanitization of trailing slashes automatically.

    Examples:
    paste_url("https://basejump.acidgenomics.com", "news", "news-0.1.html")

    See also:
    - urlparse
    - https://codereview.stackexchange.com/questions/175421/
    """
    out = "/".join(arg.strip("/") for arg in args)
    return out


def url_encode(string):
    """
    URL encode.
    Updated 2020-08-14.

    See also `utils::URLencode` in R.
    """
    string = parse.quote(string)
    return string
