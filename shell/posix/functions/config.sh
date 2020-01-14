#!/bin/sh
# shellcheck disable=SC2039

_koopa_enable_passwordless_sudo() {                                       # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # Updated 2020-01-14.
    # """
    _koopa_assert_is_linux
    _koopa_assert_has_sudo
    local group
    group="$(_koopa_group)"
    local sudo_file
    sudo_file="/etc/sudoers.d/sudo"
    _koopa_message "Updating '${sudo_file}' to include '${group}'."
    if [ ! -f "$sudo_file" ]
    then
        sudo touch "$sudo_file"
    fi
    if ! sudo grep -q "$group" "$sudo_file"
    then
        sudo sh -c "echo '%${group} ALL=(ALL) NOPASSWD: ALL' >> ${sudo_file}"
    else
        _koopa_note "Passwordless sudo already enabled for '${group}'."
    fi
    sudo chmod 0440 "$sudo_file"
    return 0
}

_koopa_link_r_etc() {                                                     # {{{1
    # """
    # Link R config files inside 'etc/'.
    # Updated 2019-12-16.
    #
    # Applies to 'Renviron.site' and 'Rprofile.site' files.
    # Note that on macOS, we don't want to copy the 'Makevars' file here.
    # """
    local r_home
    r_home="$(_koopa_r_home)"
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    local r_etc_source
    r_etc_source="${koopa_prefix}/os/${os_id}/etc/R"
    if [ ! -d "$r_etc_source" ]
    then
        _koopa_note "Source files missing: '${r_etc_source}'."
        return 0
    fi
    _koopa_message "Updating '${r_home}'."
    ln -fnsv "${r_etc_source}/"*".site" "${r_home}/etc/."
    return 0
}

_koopa_link_r_site_library() {                                            # {{{1
    # """
    # Link R site library.
    # Updated 2019-12-16.
    # """
    local r_home
    r_home="$(_koopa_r_home)"
    local version
    version="$(_koopa_current_version r)"
    local minor_version
    minor_version="$(_koopa_minor_version "$version")"
    local app_prefix
    app_prefix="$(_koopa_app_prefix)"
    _koopa_message "Creating site library at '${r_home}'."
    local lib_source
    lib_source="${app_prefix}/r/${minor_version}/site-library"
    local lib_target
    lib_target="${r_home}/site-library"
    rm -frv "$lib_target"
    mkdir -pv "$lib_source"
    ln -fnsv "$lib_source" "$lib_target"
    if _koopa_is_debian
    then
        local lib_local_target
        lib_local_target="/usr/local/lib/R/site-library"
        sudo rm -frv "$lib_local_target"
        sudo ln -fnsv "$lib_source" "$lib_local_target"
    fi
    return 0
}

_koopa_make_build_string() {                                              # {{{1
    # """
    # OS build string for 'make' configuration.
    # Updated 2020-01-13.
    #
    # Use this for 'configure --build' flag.
    #
    # This function will distinguish between RedHat, Amazon, and other distros
    # instead of just returning "linux". Note that we're substituting "redhat"
    # instead of "rhel" here, when applicable.
    #
    # - AWS:    x86_64-amzn-linux-gnu
    # - macOS: x86_64-darwin15.6.0
    # - RedHat: x86_64-redhat-linux-gnu
    # """
    local mach
    mach="$(uname -m)"
    local os_type
    os_type="${OSTYPE:?}"
    local os_id
    local string
    if _koopa_is_macos
    then
        string="${mach}-${os_type}"
    else
        os_id="$(_koopa_os_id)"
        if echo "$os_id" | grep -q "rhel"
        then
            os_id="redhat"
        fi
        string="${mach}-${os_id}-${os_type}"
    fi
    echo "$string"
}

_koopa_prefix_chgrp() {                                                   # {{{1
    # """
    # Fix the group permissions on the target build prefix.
    # Updated 2020-01-12.
    # """
    local path
    path="${1:?}"
    local group
    group="$(_koopa_group)"
    if _koopa_has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
    return 0
}

_koopa_prefix_mkdir() {                                                   # {{{1
    # """
    # Create directory in target build prefix.
    # Updated 2020-01-12.
    #
    # Sets correct group and write permissions automatically.
    # """
    local path
    path="${1:?}"
    _koopa_assert_is_not_dir "$path"
    if _koopa_has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi
    _koopa_prefix_chgrp "$path"
    return 0
}

_koopa_prepare_make_prefix() {                                            # {{{1
    # """
    # Ensure the make prefix is writable.
    # Updated 2019-11-25.
    #
    # Run this function prior to cellar installs.
    # """
    local prefix
    prefix="$(_koopa_make_prefix)"
    _koopa_set_permissions "$prefix"
    if _koopa_is_shared_install
    then
        sudo chmod g+s "$prefix"
    else
        chmod g+s "$prefix"
    fi
    return 0
}

_koopa_reset_prefix_permissions() {                                       # {{{1
    # """
    # Reset prefix permissions.
    # Updated 2020-01-12.
    # """
    prefix="${1:-$(_koopa_make_prefix)}"
    _koopa_set_permissions "$prefix"
    # Ensure group on top level is sticky.
    if _koopa_is_shared_install
    then
        sudo chmod g+s "$prefix"
    else
        chmod g+s "$prefix"
    fi
    return 0
}

_koopa_set_permissions() {                                                # {{{1
    # """
    # Set permissions on a koopa-related directory.
    # Updated 2020-01-12.
    #
    # Generally used to reset the build prefix directory (e.g. '/usr/local').
    # """
    local path
    path="${1:?}"
    _koopa_message "Setting permissions on '${path}'."
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi
    _koopa_prefix_chgrp "$path"
    return 0
}

_koopa_update_ldconfig() {                                                # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # Updated 2019-12-16.
    # """
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    [ -d /etc/ld.so.conf.d ] || return 0
    _koopa_assert_is_installed ldconfig
    local os_id
    os_id="$(_koopa_os_id)"
    local prefix
    prefix="$(_koopa_prefix)"
    local conf_source
    conf_source="${prefix}/os/${os_id}/etc/ld.so.conf.d"
    [ -d "$conf_source" ] || return 0
    # Create symlinks with "koopa-" prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    _koopa_message "Updating ldconfig in '/etc/ld.so.conf.d/'."
    local source_file
    local dest_file
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fnsv "$source_file" "$dest_file"
    done
    sudo ldconfig
    return 0
}

_koopa_update_lmod_config() {                                             # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # Updated 2019-11-26.
    # """
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    _koopa_message "Updating Lmod configuration in '/etc/profile.d/'."
    local init_dir
    init_dir="$(_koopa_app_prefix)/lmod/apps/lmod/lmod/init"
    [ -d "$init_dir" ] || return 0
    sudo ln -fnsv "${init_dir}/cshrc" "/etc/profile.d/z00_lmod.csh"
    sudo ln -fnsv "${init_dir}/profile" "/etc/profile.d/z00_lmod.sh"
    return 0
}

_koopa_update_profile() {                                                 # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # Updated 2020-01-11.
    # """
    _koopa_is_shared_install || return 0
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    local symlink
    symlink="/etc/profile.d/zzz-koopa.sh"
    # Early return if link already exists.
    [ -L "$symlink" ] && return 0
    _koopa_message "Adding '${symlink}'."
    sudo rm -fv "/etc/profile.d/koopa.sh"
    sudo ln -fnsv \
        "$(_koopa_prefix)/os/linux/etc/profile.d/zzz-koopa.sh" \
        "$symlink"
    return 0
}

_koopa_update_r_config() {                                                # {{{1
    # """
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # Updated 2019-12-16.
    # """
    _koopa_has_sudo || return 0
    _koopa_is_installed R || return 0
    local r_home
    r_home="$(_koopa_r_home)"
    _koopa_link_r_etc
    _koopa_link_r_site_library
    _koopa_set_permissions "$r_home"
    _koopa_r_javareconf
    return 0
}

_koopa_update_r_config_macos() {                                          # {{{1
    # """
    # Update R config on macOS.
    # Updated 2019-10-31.
    #
    # Need to include Makevars to build packages from source.
    # """
    mkdir -pv "${HOME}/.R"
    ln -fnsv "/usr/local/koopa/os/macos/etc/R/Makevars" "${HOME}/.R/."
    return 0
}

_koopa_update_shells() {                                                  # {{{1
    # """
    # Update shell configuration.
    # Updated 2020-01-12.
    # """
    _koopa_assert_has_sudo
    local shell_name
    shell_name="${1:?}"
    local shell_path
    shell_path="$(_koopa_make_prefix)/bin/${shell_name}"
    local shell_file
    shell_file="/etc/shells"
    if ! grep -q "$shell_path" "$shell_file"
    then
        _koopa_message "Updating '${shell_file}' to include '${shell_path}'."
        sudo sh -c "echo ${shell_path} >> ${shell_file}"
    fi
    _koopa_note "Run 'chsh -s ${shell_path} ${USER}' to change default shell."
    return 0
}

_koopa_update_xdg_config() {                                              # {{{1
    # """
    # Update XDG configuration.
    # Updated 2020-01-09.
    #
    # Path: '~/.config/koopa'.
    # """
    _koopa_is_root && return 0
    local config_dir
    config_dir="$(_koopa_config_prefix)"
    local prefix_dir
    prefix_dir="$(_koopa_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    mkdir -p "$config_dir"
    _koopa_relink "${prefix_dir}" "${config_dir}/home"
    _koopa_relink "${prefix_dir}/activate" "${config_dir}/activate"
    if [ -d "${prefix_dir}/os/${os_id}" ]
    then
        _koopa_relink "${prefix_dir}/os/${os_id}/etc/R" "${config_dir}/R"
    fi
    return 0
}
