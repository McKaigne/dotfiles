# Pick a project directory and open its own zellij session, named after the
# directory: focus the window already showing it, resume it where you left off
# (zellij saves sessions), or start it from the code layout. Typing something
# that is not listed looks the directory up with zoxide.
# Menu: fuzzel from a keybind, fzf in a terminal or inside zellij.

layouts="${XDG_CONFIG_HOME:-$HOME/.config}/zellij/layouts"

session_name() {
  case "$1" in
    /etc/nixos) echo nixos ;;
    *) basename "$1" | tr '.: ' '___' ;;
  esac
}

# Known sessions: running, or saved (exited, resumable).
declare -A state
while read -r line; do
  name=${line%% *}
  [[ -n $name ]] || continue
  if [[ $line == *EXITED* ]]; then state[$name]=saved; else state[$name]=running; fi
done < <(zellij list-sessions --no-formatting 2>/dev/null || true)

# Directories, most used first: git repositories zoxide knows under $HOME,
# then /etc/nixos, the notes vault and every directory in ~/Projects.
declare -A seen
dirs=()
add_dir() {
  [[ -d $1 && -z ${seen[$1]:-} ]] || return 0
  seen[$1]=1
  dirs+=("$1")
}
while read -r dir; do
  [[ $dir == "$HOME"/* && -e $dir/.git ]] && add_dir "$dir"
done < <(zoxide query --list 2>/dev/null | head -n 300)
add_dir /etc/nixos
add_dir "$HOME/Areas/Notes"
for dir in "$HOME"/Projects/*/; do add_dir "${dir%/}"; done

mark() {
  case "${state[$1]:-}" in
    running) printf '●' ;;
    saved) printf '◐' ;;
    *) printf ' ' ;;
  esac
}

declare -A pick_dir pick_name
labels=()
declare -A listed
for dir in "${dirs[@]}"; do
  name=$(session_name "$dir")
  label="$(mark "$name") $name  ${dir/#"$HOME"/\~}"
  labels+=("$label")
  pick_dir[$label]=$dir
  pick_name[$label]=$name
  listed[$name]=1
done
# Sessions that belong to no listed directory (e.g. main) stay reachable.
for name in "${!state[@]}"; do
  [[ -n ${listed[$name]:-} ]] && continue
  label="$(mark "$name") $name  (session)"
  labels+=("$label")
  pick_dir[$label]=""
  pick_name[$label]=$name
done

in_terminal=false
if [[ -n ${ZELLIJ:-} || -t 0 ]]; then in_terminal=true; fi

if $in_terminal; then
  mapfile -t out < <(printf '%s\n' "${labels[@]}" |
    fzf --print-query --prompt 'project ➜ ' --header '● running  ◐ saved  ·  or type a directory' || true)
  query=${out[0]:-}
  choice=${out[1]:-}
else
  choice=$(printf '%s\n' "${labels[@]}" |
    fuzzel --dmenu --prompt 'project ➜ ' --placeholder 'pick a project or type a directory' \
      --mesg '● running  ◐ saved' --width 60 --lines 15 || true)
  query=$choice
fi

if [[ -n $choice && -n ${pick_name[$choice]+x} ]]; then
  dir=${pick_dir[$choice]}
  name=${pick_name[$choice]}
else
  [[ -n $query ]] || exit 0
  query=${query/#\~/$HOME}
  if [[ -d $query ]]; then
    dir=$(realpath "$query")
  else
    # Words as separate zoxide keywords.
    read -ra words <<<"$query"
    dir=$(zoxide query -- "${words[@]}" 2>/dev/null) || {
      $in_terminal || notify-send "zproj" "No directory matches '$query'"
      $in_terminal && echo "zproj: no directory matches '$query'" >&2
      exit 1
    }
  fi
  name=$(session_name "$dir")
fi

[[ -n $dir ]] && zoxide add "$dir"
[[ -n $dir ]] || dir=$HOME

# A new session starts from the code layout when Noctalia has rendered it.
new_layout=()
[[ -f $layouts/code.kdl ]] && new_layout=(--new-session-with-layout code)

if [[ -n ${ZELLIJ:-} ]]; then
  if [[ -n ${state[$name]:-} ]]; then
    exec zellij action switch-session "$name"
  fi
  switch_layout=()
  [[ -f $layouts/code.kdl ]] && switch_layout=(--layout code)
  exec zellij action switch-session "$name" --cwd "$dir" "${switch_layout[@]}"
fi

if $in_terminal; then
  cd "$dir"
  [[ -n ${state[$name]:-} ]] && exec zellij attach "$name"
  exec zellij --session "$name" "${new_layout[@]}"
fi

# From the desktop: focus the window this picker opened for the session.
if [[ ${state[$name]:-} == running ]] && command -v umbriel >/dev/null; then
  while IFS=$'\t' read -r id pid; do
    if tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | grep -qx "ZPROJ_SESSION=$name"; then
      exec umbriel msg window-focus "$id"
    fi
  done < <(umbriel windows --json 2>/dev/null | jq -r '.[] | select(.app_id == "foot") | "\(.id)\t\(.pid)"')
fi

if [[ -n ${state[$name]:-} ]]; then
  cmd=(zellij attach "$name")
else
  cmd=(zellij --session "$name" "${new_layout[@]}")
fi
ZPROJ_SESSION=$name setsid -f foot --working-directory "$dir" "${cmd[@]}" >/dev/null 2>&1
