#!/usr/bin/env bash
set -Eeuxo pipefail

# Install R-devel for macOS
# https://mac.r-project.org/

echo "Installing r-devel"
echo "sudo is required for this script."
sudo -v

# version="devel"
r_version="3.6-branch"
macos_version="el-capitain"

tarball="R-${r_version}-${macos_version}-sa-x86_64.tar.gz"

rm -f "$tarball"
wget "https://mac.r-project.org/${macos_version}/R-${r_version}/${tarball}"

# Note that this step will overwrite an existing R installation, located at:
# /Library/Frameworks/R.framework
#
# If necessary, rename your previous install first (e.g. R-3.5.2.framework).
#
# I use symlinks to point `R.framework` to a specific version.

if [[ -d /Library/Frameworks/R.framework ]]
then
    echo "Backing up existing R.framework to R.framework.bak."
    sudo mv "/Library/Frameworks/R.framework" "/Library/Frameworks/R.framework.bak"
fi

sudo tar fvxz "$tarball" -C /

sudo mv "/Library/Frameworks/R.framework" "/Library/Frameworks/R-${r_version}.framework"
sudo ln -s "/Library/Frameworks/R-${r_version}.framework" "/Library/Frameworks/R.framework"

echo "R-${r_version} installed correctly."
echo "Ensure that R_LIBS_USER in ~/.Renviron is updated before running R."
