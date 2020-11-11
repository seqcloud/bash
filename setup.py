#!/usr/bin/env python3
"""
koopa Python package.
Updated 2020-11-11.

See also:
- https://packaging.python.org/tutorials/packaging-projects/
"""

import setuptools

setuptools.setup(
    name="koopa",
    version="0.0.2",
    author="Michael Steinbaugh",
    author_email="mike@steinbaugh.com",
    description="Shell bootloader for bioinformatics.",
    url="https://koopa.acidgenomics.com/",
    packages=setuptools.find_packages(),
    python_requires=">=3.7",
    install_requires=["flake8", "pylint", "pytest", "six"],
)
