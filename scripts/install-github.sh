#!/usr/bin/env bash
set -Eeu -o pipefail

# FIXME Move this into main koopa Bash functions.

python3 -m pip install \
    --upgrade \
    'https://github.com/acidgenomics/koopa/archive/python.tar.gz'
