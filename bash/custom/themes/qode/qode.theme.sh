#! bash oh-my-bash.module
# qode theme — a small prompt: "qode <cwd> <git>$". Uses Oh My Bash's own colour and
# scm helpers, and registers itself the way the bundled themes do.

SCM_THEME_PROMPT_PREFIX=" ${_omb_prompt_purple}("
SCM_THEME_PROMPT_SUFFIX=")${_omb_prompt_normal}"
SCM_THEME_PROMPT_DIRTY="*"
SCM_THEME_PROMPT_CLEAN=""

function _omb_theme_PROMPT_COMMAND {
  local status=$?
  local mark="${_omb_prompt_green}\$${_omb_prompt_normal}"
  ((status != 0)) && mark="${_omb_prompt_red}\$${_omb_prompt_normal}"
  PS1="${_omb_prompt_bold_teal}qode${_omb_prompt_normal} ${_omb_prompt_bold_navy}\w${_omb_prompt_normal}$(scm_prompt_info) ${mark} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
