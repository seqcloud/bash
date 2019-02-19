#!/usr/bin/env zsh

# Pure prompt
#
# This won't work if an oh-my-zsh theme is enabled.
# This step must be sourced after oh-my-zsh.
#
# See also:
# - https://github.com/sindresorhus/pure
# - https://github.com/sindresorhus/pure/wiki
#
# Quick install using node:
# npm install --global pure-prompt
# Note that npm method requires write access into /usr/local (elevated).
# Let's configure manually instead, which also works on remote servers.

koopa_fpath="${KOOPA_BASE_DIR}/zsh/fpath"
fpath=( $koopa_fpath $fpath )
autoload -U promptinit; promptinit
prompt pure
unset -v koopa_fpath
