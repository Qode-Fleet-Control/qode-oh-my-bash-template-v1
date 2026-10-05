#! bash oh-my-bash.module
# qode — the template's own Oh My Bash plugin. Lives in $OSH_CUSTOM/plugins/qode and is
# enabled by `plugins=(... qode)` in .bashrc.

function qode_hello {
  printf '%s\n' "hello from qode"
}

# mkcd DIR — make a directory and cd into it
function mkcd {
  mkdir -p -- "$1" && cd -- "$1"
}

alias ll='ls -lah'
