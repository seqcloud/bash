#!/usr/bin/env bash
set -Eeuxo pipefail

echo "sudo access is required for installation."
sudo -v

# Check for RedHat.
if ! grep -q 'ID="rhel"' /etc/os-release
then
    echo "Error: RedHat Enterprise Linux (RHEL) is required." >&2
    exit 1
fi

# Error on conda detection.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
    exit 1
fi

# Ensure yum-utils is installed, so we can build dependencies.
sudo yum -y install yum-utils
