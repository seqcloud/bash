#!/usr/bin/env python3
"""
Syntactically valid names.
"""

import re


def kebab_case(string):
    """
    Kebab case.
    Updated 2019-10-06.
    """
    string = re.sub("[^0-9a-zA-Z]+", "-", string)
    string = string.lower()
    return string


def snake_case(string):
    """
    Snake case.
    Updated 2019-10-06.
    """
    string = re.sub("[^0-9a-zA-Z]+", "_", string)
    string = string.lower()
    return string
