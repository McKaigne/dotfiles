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
    {
      name: newline_shift_enter
      modifier: shift
      keycode: enter
      mode: [emacs, vi_insert]
      event: { edit: insertnewline }
    }
    {
      name: newline_alt_enter
      modifier: alt
      keycode: enter
      mode: [emacs, vi_insert]
      event: { edit: insertnewline }
    }
  ]
)

$env.config.abbreviations = {
  # NixOS & Flake
  nr: "sudo nixos-rebuild switch --flake /etc/nixos#castor"
  nfu: "nix flake update --flake /etc/nixos"
  ncd: "cd /etc/nixos"

  # Git
  ga: "git add -A"
  gc: "git commit -m"
  gca: "git commit -a -m"
  gp: "git push"
  gpu: "git pull"
  gst: "git status"
  gd: "git diff"

  # Editors
  e: "emacsclient -c -a 'emacs'"
  et: "emacsclient -t -a 'emacs'"
  v: "emacsclient -c -a 'emacs'"
  doom: "doom"
  ds: "doom sync"
  h: "hx"
  hx: "hx"
  "h.": "hx ."
  z: "zed"
  zed: "zed"

  # Terminal & Multiplexer
  t: "tmux"
  ta: "tmux attach"
  tls: "tmux list-sessions"
  tn: "tmux new -s"
  tk: "tmux kill-session -t"

  # File Managers & Utilities
  fm: "thunar"
  y: "yazi"
  f: "fetch"
  lt: "eza --tree --level=2 --long --icons --git"
  cat: "bat --paging=never"

  # Zoxide Navigation
  cd: "z"
  cdi: "zi"
  cda: "zoxide add"
  cdq: "zoxide query"
  cdqi: "zoxide query -i"
  cdl: "zoxide query -l"
  cdr: "zoxide remove"
  za: "zoxide add"
  zq: "zoxide query"
  zqi: "zoxide query -i"
  zl: "zoxide query -l"
  zr: "zoxide remove"
}

def cx [dir: path] {
  cd $dir
  ls -l
}

source @starshipInit@
source @zoxideInit@

# Modal & Multiline indicators:
$env.PROMPT_INDICATOR = $"(ansi cyan_bold)> (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi cyan_bold)> (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi magenta_bold): (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = $"(ansi dark_gray) (ansi reset)"