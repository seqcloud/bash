#!/usr/bin/env bash
set -Eeu -o pipefail

(
    cd ../ || exit 1
    python3 -m pip install .
)
