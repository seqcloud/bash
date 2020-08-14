#!/usr/bin/env python3
"""
Syntactically valid names.
"""

from re import sub


def kebab_case(string):
    """
    Kebab case.
    Updated 2020-08-14.
    """
    string = sub("[^0-9a-zA-Z]+", "-", string)
    string = string.lower()
    return string


def snake_case(string):
    """
    Snake case.
    Updated 2020-08-14.
    """
    string = sub("[^0-9a-zA-Z]+", "_", string)
    string = string.lower()
    return string
