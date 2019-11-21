#!/usr/bin/env bash
set -Eeu -o pipefail

name="neovim"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
jobs="$(_koopa_cpu_count)"
exe_file="${prefix}/bin/nvim"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "${name}-${version}" || exit 1
    make \
        --jobs="$jobs" \
        CMAKE_BUILD_TYPE=Release \
        CMAKE_INSTALL_PREFIX="$prefix"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
