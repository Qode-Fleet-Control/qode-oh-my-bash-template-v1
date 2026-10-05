#!/usr/bin/env bash
# The job: start an INTERACTIVE bash with this repo's bash/.bashrc and check that the
# setup loaded — Oh My Bash itself, a bundled plugin, the custom plugin, the custom theme
# and the prompt it draws. Exits 0 when every check passes.
set -u
here=$(cd "$(dirname "$0")/.." && pwd)
export OSH="${OSH:-$here/.local/share/oh-my-bash}"   # docker sets OSH; local default
export TERM="${TERM:-xterm-256color}"

errfile=$(mktemp)
bash --rcfile "$here/bash/.bashrc" -i -c '
  fail=0
  ok()  { printf "ok   %s\n" "$1"; }
  bad() { printf "FAIL %s\n" "$1"; fail=1; }
  echo "qode bash setup $QODE_BASH_VERSION, bash $BASH_VERSION"
  declare -F _omb_module_require >/dev/null && ok "oh-my-bash loaded from $OSH"  || bad "oh-my-bash not loaded"
  [[ " ${_omb_module_loaded-} " == *" plugin:git "* ]] && ok "bundled plugin: git" || bad "git plugin not loaded"
  declare -F qode_hello >/dev/null       && ok "custom plugin: qode"            || bad "qode plugin not loaded"
  [[ "$(qode_hello)" == "hello from qode" ]] && ok "qode_hello works"         || bad "qode_hello output"
  [[ $OSH_THEME == qode ]]               && ok "theme: $OSH_THEME"              || bad "theme is ${OSH_THEME:-unset}"
  _omb_theme_PROMPT_COMMAND
  rendered=$(printf "%s" "${PS1@P}" | sed "s/\x1b\[[0-9;]*m//g" | tr -d "\001\002")
  [[ $rendered == qode* ]]               && ok "prompt renders: $rendered"      || bad "prompt not from the theme: $rendered"
  exit $fail
' 2>"$errfile"
rc=$?
# bash -i without a terminal may say it has no job control, and an interactive bash
# echoes "exit" as it leaves; anything else on stderr is a load error
grep -v -x 'exit' "$errfile" | grep -v -e 'no job control in this shell' -e 'cannot set terminal process group' > "$errfile.real"
if [[ -s $errfile.real ]]; then
  echo "FAIL bash wrote to stderr while loading:"; sed 's/^/  | /' "$errfile.real"; rc=1
fi
rm -f "$errfile" "$errfile.real"
[[ $rc -eq 0 ]] && echo PASS || echo FAILED
exit $rc
