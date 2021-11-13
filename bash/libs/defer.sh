# copy from https://gist.github.com/phemmer/e943dce38eaa948f1893d9392741970f
function _run_deferred() {
  local _depth="$BASHPID.${#FUNCNAME[@]}"
  [[ "$_depth" != "$_deferred_depth" ]] && return
  local opt=$-
  set +e
  for (( i=${#_deferred[@]} - 1; i >= 0; i-- )); do
    eval "${_deferred[i]}"
  done
  [[ "$opt" == *e* ]] && set -e
}
function _defer() {
  _deferred_depth="$BASHPID.${#FUNCNAME[@]}"
  _deferred+=( "$(printf '%q ' "$@")" )
}
# This has to be an alias so that the `trap ... RETURN` runs appropriately.
shopt -s expand_aliases
alias defer='declare -a _deferred; declare _deferred_depth; trap _run_deferred EXIT RETURN; _defer'
