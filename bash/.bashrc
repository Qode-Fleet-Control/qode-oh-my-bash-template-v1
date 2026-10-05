# .bashrc — the versioned bash setup this repo ships, on Oh My Bash. Oh My Bash lives in
# $OSH; everything custom (plugin, theme) lives next to this file in ./custom.
case $- in *i*) ;; *) return ;; esac   # interactive shells only

_qode_rc_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
QODE_BASH_VERSION="$(<"$_qode_rc_dir/../VERSION")"

export OSH="${OSH:-$HOME/.local/share/oh-my-bash}"
OSH_CUSTOM="$_qode_rc_dir/custom"
OSH_THEME="qode"

# A pinned install: never self-update.
DISABLE_AUTO_UPDATE="true"
OMB_USE_SUDO=false

completions=(git)
aliases=(general)
plugins=(git qode)

source "$OSH/oh-my-bash.sh"

# --- user configuration -----------------------------------------------------------
export EDITOR="${EDITOR:-vi}"
