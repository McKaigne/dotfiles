# nsync: review what you changed in the Noctalia settings window, then keep it
# in /etc/nixos or throw it away. Nothing is saved or reset unless you name it.

state="$HOME/.local/state/noctalia/settings.toml"
confdir="$HOME/.config/noctalia"
saved=/etc/nixos/modules/programs/noctalia/config/gui.json

usage() {
  cat <<'USAGE'
nsync                 list settings changed in the settings window
nsync keep NAME...    save them to /etc/nixos and deploy
nsync keep --all      save everything listed
nsync drop NAME...    discard them; Noctalia goes back to the config
nsync drop --all      discard everything listed

NAME is a setting or a group of them: theme, bar.fancy, shell.font_family.
USAGE
}

toml2json() { remarshal -if toml -of json < "$1"; }

# The deployed config: every config file merged in load order.
config_json() {
  for f in "$confdir"/*.toml; do toml2json "$f"; done | jq -s 'reduce .[] as $x ({}; . * $x)'
}

state_json() {
  if [ -s "$state" ]; then toml2json "$state"; else echo '{}'; fi
}

# Every setting in the GUI state that differs from the config. The last-shown
# wallpaper is runtime state, not a setting, so it is never listed.
changes() {
  jq -n --argjson s "$(state_json)" --argjson c "$(config_json)" '
    [ $s | paths(type != "object") as $p
      | select(($p | length) == 1 or ($s | getpath($p[:-1]) | type) == "object")
      | select($p[0] != "config_version")
      | select(($p[0] == "wallpaper" and ($p[1] == "last" or $p[1] == "monitors")) | not)
      | { path: $p,
          name: ($p | map(tostring) | join(".")),
          gui: ($s | getpath($p)),
          config: ($c | getpath($p)) }
      | select(.gui != .config) ]'
}

# The changes named on the command line (or all of them with --all).
selected() {
  local all
  all="$(changes)"
  if [ "${1:-}" = "--all" ]; then
    echo "$all"
  else
    jq --args 'map(select(.name as $n | any($ARGS.positional[] as $a | $n == $a or ($n | startswith($a + ".")); .)))' "$@" <<<"$all"
  fi
}

# Remove settings from the GUI state so the config applies again.
forget() {
  local json
  json="$(state_json | jq --argjson sel "$1" '
    reduce $sel[] as $e (.; delpaths([$e.path]))
    | until(([.. | objects | select(. == {})] | length) <= 1;
        walk(if type == "object" then with_entries(select(.value != {})) else . end))')"
  remarshal -if json -of toml <<<"$json" > "$state.tmp"
  mv "$state.tmp" "$state"
}

show() {
  jq -r '.[] | "  \(.name) = \(.gui | tojson)\(if .config == null then "" else "   (config: \(.config | tojson))" end)"' <<<"$1"
}

cmd="${1:-list}"
[ $# -gt 0 ] && shift

case "$cmd" in
  list)
    all="$(changes)"
    if [ "$(jq length <<<"$all")" -eq 0 ]; then
      echo "No settings-window changes; Noctalia matches /etc/nixos."
    else
      echo "Changed in the settings window:"
      show "$all"
      echo
      echo "Keep with 'nsync keep NAME' or discard with 'nsync drop NAME' (or --all)."
    fi
    ;;
  keep | drop)
    [ $# -gt 0 ] || { usage; exit 1; }
    sel="$(selected "$@")"
    if [ "$(jq length <<<"$sel")" -eq 0 ]; then
      echo "Nothing matches. Run 'nsync' to see what changed."
      exit 1
    fi
    if [ "$cmd" = keep ]; then
      echo "Keeping:"
      show "$sel"
      jq --argjson sel "$sel" 'reduce $sel[] as $e (.; setpath($e.path; $e.gui))' "$saved" > "$saved.tmp"
      mv "$saved.tmp" "$saved"
      ndeploy switch
      forget "$sel"
      echo "Saved to $saved. Run 'nr castor' to apply it there, and commit when happy."
    else
      echo "Discarding:"
      show "$sel"
      forget "$sel"
    fi
    ;;
  -h | --help | help) usage ;;
  *) usage; exit 1 ;;
esac
