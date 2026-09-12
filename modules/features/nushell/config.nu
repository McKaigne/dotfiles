$env.config.show_banner = false
$env.config.edit_mode = 'vi'
$env.config.cursor_shape = {
  vi_insert: 'block'
  vi_normal: 'block'
  emacs: 'block'
}

$env.config.hooks = ($env.config.hooks? | default {} | merge {
  pre_prompt: [ { print "" } ]
})

$env.config.keybindings = (
  $env.config.keybindings? | default [] | append [
    {
      name: delete_one_word_backward
      modifier: control
      keycode: char_w
      mode: [emacs, vi_insert]
      event: { edit: backspaceword }
    }
  ]
)

$env.config.abbreviations = {
  nr: "sudo nixos-rebuild switch --flake /etc/nixos#castor"
  nfu: "nix flake update --flake /etc/nixos"
  ncd: "cd /etc/nixos"
  ga: "git add -A"
  gc: "git commit -m"
  gca: "git commit -a -m"
  gp: "git push"
  gpu: "git pull"
  gst: "git status"
  gd: "git diff"
  e: "emacsclient -c -a 'emacs'"
  et: "emacsclient -t -a 'emacs'"
  v: "emacsclient -c -a 'emacs'"
  doom: "doom"
  ds: "doom sync"
  h: "hx"
  hx: "hx"
  "h.": "hx ."
  fm: "thunar"
  y: "yazi"
  t: "tmux"
  ta: "tmux attach"
  tls: "tmux list-sessions"
  tn: "tmux new -s"
  tk: "tmux kill-session -t"
  f: "fetch"
  lt: "eza --tree --level=2 --long --icons --git"
  cat: "bat --paging=never"
}

def cx [dir: path] {
  cd $dir
  ls -l
}

source @starshipInit@

# Modal & Multiline indicators:
# Insert -> Bold Cyan () | Normal -> Bold Magenta () | Multiline -> Bold Yellow ()
$env.PROMPT_INDICATOR = $"(ansi cyan_bold)    (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi cyan_bold)    (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi magenta_bold)    (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = $"(ansi yellow_bold)    (ansi reset)"