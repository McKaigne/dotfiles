# Keep the glass import last in each gtk.css: its translucent backgrounds
# only win if they come after Noctalia's noctalia.css. Noctalia appends its
# own import whenever it finds it missing, which can land it after ours.
config="${XDG_CONFIG_HOME:-$HOME/.config}"
for dir in gtk-3.0 gtk-4.0; do
  css="$config/$dir/gtk.css"
  mkdir -p "$config/$dir"
  [ -f "$css" ] || printf '@import url("noctalia.css");\n' > "$css"
  others=$(grep -v 'glass\.css' "$css" || true)
  printf '%s\n@import url("glass.css");\n' "$others" > "$css"
done
