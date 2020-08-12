#!/usr/bin/env bash
set -Eeu -o pipefail

(
    cd ../ || exit 1
    pip install .
)
