#!/usr/bin/env python3
"""
Set up koopa package.
https://packaging.python.org/tutorials/packaging-projects/
"""

import setuptools

setuptools.setup(
    name="koopa",
    version="0.0.1",
    author="Michael Steinbaugh",
    author_email="mike@steinbaugh.com",
    description="Shell bootloader for bioinformatics.",
    url="https://koopa.acidgenomics.com/",
    packages=setuptools.find_packages(),
    python_requires='>=3.8',
    # install_requires=[
    #        "PKG >= XXX",
    #        "pytest",
    #    ],
)
