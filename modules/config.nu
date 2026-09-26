
$env.config = {
  show_banner: false
  edit_mode: emacs
  cursor_shape: {
    emacs: block
    vi_insert: bar
    vi_normal: block
  }
  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "prefix"
  }
}

# --- Expandable Command Abbreviations (Expand on Space or Enter) ---
$env.config.abbreviations = {
  g: "git"
  ga: "git add"
  gc: "git commit -m"
  gca: "git commit --amend"
  gco: "git checkout"
  gd: "git diff"
  gl: "git pull"
  gp: "git push"
  gst: "git status"
  ll: "ls -l"
  la: "ls -a"
  lla: "ls -la"
  hx: "helix"
  v: "helix"
  spf: "superfile"
  nr: "sudo nixos-rebuild switch --flake /etc/nixos#castor"
}

# Initialize dynamic integrations
source @starshipInit@
source @zoxideInit@
source @carapaceInit@
