#!/bin/sh

# General global variable exports.
# Updated 2019-09-17.



# Standard globals                                                          {{{1
# ==============================================================================

# This variables are used by some koopa scripts, so ensure they're always
# consistently exported across platforms.

# HOSTNAME
if [ -z "${HOSTNAME:-}" ]
then
    HOSTNAME="$(uname -n)"
    export HOSTNAME
fi

# OSTYPE
# Automatically set by bash and zsh.
# Updated 2019-06-26.
if [ -z "${OSTYPE:-}" ]
then
    OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
    export OSTYPE
fi

# TERM
# Terminal color mode. This should normally be set by the terminal client.
if [ -z "${TERM:-}" ]
then
    export TERM="screen-256color"
fi

# TODAY
# Current date. Alternatively, can use `%F` shorthand.
if [ -z "${TODAY:-}" ]
then
    TODAY="$(date +%Y-%m-%d)"
    export TODAY
fi

# USER
if [ -z "${USER:-}" ]
then
    USER="$(whoami)"
    export USER
fi



# Interface                                                                 {{{1
# ==============================================================================

# Trim the maximum number of directories in prompt (PS1).
# For bash, requires >= v4.
if [ -z "${PROMPT_DIRTRIM:-}" ]
then
    export PROMPT_DIRTRIM=4
fi



# History                                                                   {{{1
# ==============================================================================

if [ -z "${HISTFILE:-}" ]
then
    HISTFILE="${HOME}/.$(_koopa_shell)-history"
    export HISTFILE
fi

if [ -z "${HISTSIZE:-}" ]
then
    export HISTSIZE=100000
fi

if [ -z "${SAVEHIST:-}" ]
then
    export SAVEHIST=100000
fi

if [ -z "${HISTCONTROL:-}" ]
then
    export HISTCONTROL="ignoredups"
fi

if [ -z "${HISTIGNORE:-}" ]
then
    export HISTIGNORE="&:ls:[bf]g:exit"
fi

# Add the date/time to `history` command output.
# Note that on macOS bash will fail if `set -e` is set and this isn't exported.
if [ -z "${HISTTIMEFORMAT:-}" ]
then
    export HISTTIMEFORMAT="%Y%m%d %T  "
fi

# For bash users, autojump keeps track of directories by modifying
# `$PROMPT_COMMAND`. Do not overwrite `$PROMPT_COMMAND`:
# https://github.com/wting/autojump
# > export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
if [ -z "${PROMPT_COMMAND:-}" ]
then
    export PROMPT_COMMAND="history -a"
fi



# Locale / encoding                                                         {{{1
# ==============================================================================

# Force UTF-8 to avoid encoding issues for users with broken locale settings.
# https://github.com/Homebrew/brew/blob/master/Library/Homebrew/brew.sh
# > export LC_ALL="C"

if [ "$(locale charmap 2>/dev/null)" != "UTF-8" ]
then
    export LC_ALL="en_US.UTF-8"
fi



# Editor                                                                    {{{1
# ==============================================================================

# Set text editor, if unset.
# Recommending vim by default.
if [ -z "${EDITOR:-}" ]
then
    export EDITOR="vim"
fi
# Ensure VISUAL matches EDITOR.
if [ -n "${EDITOR:-}" ]
then
    export VISUAL="$EDITOR"
fi



# CPU count                                                                 {{{1
# ==============================================================================

# Get the number of cores (CPUs) available.
# Updated 2019-06-23.
if _koopa_is_darwin
then
    CPU_COUNT="$(sysctl -n hw.ncpu)"
elif _koopa_is_linux
then
    CPU_COUNT="$(getconf _NPROCESSORS_ONLN)"
else
    # Otherwise assume single threaded.
    CPU_COUNT=1
fi
export CPU_COUNT



# Program-specific                                                          {{{1
# ==============================================================================

# GnuPGP                                                                    {{{2
# ------------------------------------------------------------------------------

# Enable passphrase prompting in terminal.
# Note that this step will error if tty isn't installed.
if [ -z "${GPG_TTY:-}" ]
then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi

# Ruby                                                                      {{{2
# ------------------------------------------------------------------------------

if [ -d "${HOME}/.gem" ]
then
    export GEM_HOME="${HOME}/.gem"
fi

# rsync                                                                     {{{2
# ------------------------------------------------------------------------------

# Useful flags:
# -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
# -z, --compress              compress file data during the transfer
# -L, --copy-links            transform symlink into referent file/dir
#     --delete-before         receiver deletes before xfer, not during
# -h, --human-readable        output numbers in a human-readable format
#     --iconv=CONVERT_SPEC    request charset conversion of filenames
#     --progress              show progress during transfer
#     --dry-run
#     --one-file-system
#     --acls --xattrs
#     --iconv=utf-8,utf-8-mac

if [ -z "${RSYNC_FLAGS:-}" ]
then
    RSYNC_FLAGS="$(_koopa_rsync_flags)"
    export RSYNC_FLAGS
fi
