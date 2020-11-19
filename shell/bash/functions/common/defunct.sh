#!/usr/bin/env bash

# Note that these are defined primarily to catch errors in private scripts that
# are defined outside of the koopa package.

koopa::defunct() { # {{{1
    # """
    # Make a function defunct.
    # @note Updated 2020-02-18.
    # """
    local msg new
    new="${1:-}"
    msg='Defunct.'
    if [[ -n "$new" ]]
    then
        msg="${msg} Use '${new}' instead."
    fi
    koopa::stop "${msg}"
}

koopa::cellar_prefix() { # {{{1
    # """
    # @note Updated 2020-11-19.
    # """
    koopa::defunct 'koopa::app_prefix'
}

koopa::is_darwin() { # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    koopa::defunct 'koopa::is_macos'
}

koopa::is_matching_fixed() {  #{{{1
    # """
    # @note Updated 2020-04-29.
    # """
    koopa::defunct 'koopa::str_match'
}

koopa::is_matching_regex() {  #{{{1
    # """
    # @note Updated 2020-04-29.
    # """
    koopa::defunct 'koopa::str_match_regex'
}

koopa::local_app_prefix() { # {{{1
    # """
    # @note Updated 2020-11-19.
    # """
    koopa::defunct 'koopa::local_data_prefix'
}

koopa::prefix_mkdir() { # {{{1
    # """
    # @note Updated 2020-02-19.
    # """
    koopa::defunct 'koopa::mkdir'
}

koopa::quiet_cd() { # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    koopa::defunct 'koopa::cd'
}

koopa::remove_broken_cellar_symlinks() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa::defunct 'koopa::delete_broken_cellar_symlinks'
}

koopa::remove_broken_symlinks() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa::defunct 'koopa::delete_broken_symlinks'
}

koopa::remove_empty_dirs() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa::defunct 'koopa::delete_empty_dirs'
}

koopa::update_profile() { # {{{1
    # """
    # @note Updated 2020-02-15.
    # """
    koopa::defunct 'koopa::update_etc_profile_d'
}

koopa::update_shells() { # {{{1
    # """
    # @note Updated 2020-02-11.
    # """
    koopa::defunct 'koopa::enable_shell'
}
