#!/bin/sh

# PATH string modifiers
# Modified 2019-06-24.

# See also:
# - https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh



# FIXME This isn't working correctly.
# Find local bin directories and add them to PATH.
#
# See also:
# - https://stackoverflow.com/questions/23356779
# - https://stackoverflow.com/questions/7442417
#
# Modified 2019-06-20.
_koopa_add_local_bins_to_path() {
    find "$(koopa build-prefix)" \
        -mindepth 2 \
        -maxdepth 3 \
        -name "bin" \
        ! -path "*/Caskroom/*" \
        ! -path "*/Cellar/*" \
        ! -path "*/Homebrew/*" \
        ! -path "*/anaconda3/*" \
        ! -path "*/bcbio/*" \
        ! -path "*/lib/*" \
        ! -path "*/lib64/*" \
        ! -path "*/miniconda3/*" \
        -print0 | \
        sort -z | \
        xargs -0 _koopa_add_to_path_start
}



# Add both 'bin/' and 'sbin/' to PATH.
# Modified 2019-06-20.
_koopa_add_bins_to_path() {
    local relpath
    local prefix
    
    relpath="${1:-}"
    prefix="$KOOPA_HOME"

    [ ! -z "$relpath" ] && prefix="${prefix}/${relpath}"
    
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
}



# Modified 2019-06-24.
_koopa_add_to_path_start() {
    local dir
    dir="$1"
    [ ! -d "$dir" ] && _koopa_remove_from_path "$dir" && return
    echo "$PATH" | grep -q "$dir" && return
    dir="$(realpath "$dir")"
    export PATH="${dir}:${PATH}"
}



# Modified 2019-06-24.
_koopa_add_to_path_end() {
    local dir
    dir="$1"
    [ ! -d "$dir" ] && _koopa_remove_from_path "$dir" && return
    echo "$PATH" | grep -q "$dir" && return
    dir="$(realpath "$dir")"
    export PATH="${PATH}:${dir}"
}



# Modified 2019-06-24.
_koopa_force_add_to_path_start() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    dir="$(realpath "$dir")"
    export PATH="${dir}:${PATH}"
}



# Modified 2019-06-24.
_koopa_force_add_to_path_end() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    dir="$(realpath "$dir")"
    export PATH="${PATH}:${dir}"
}



# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
_koopa_remove_from_path() {
    local dir
    dir="$1"
    # SC2039: In POSIX sh, string replacement is undefined.
    # shellcheck disable=SC2039
    export PATH="${PATH//:$dir/}"
}

