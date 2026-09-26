
# ==============================================================================
# Nushell User Configuration
# ==============================================================================

$env.config = {
  show_banner: false
  edit_mode: 'vi'
  cursor_shape: {
    vi_insert: 'line'
    vi_normal: 'block'
  }
}

# --- Core Aliases (Fast & Reliable) ---
alias f = fetch             # aerofyl's animated 3D fetch
alias ff = fetch
alias g = git
alias ga = git add
alias gc = git commit
alias gp = git push
alias gl = git pull
alias gst = git status
alias gd = git diff
alias h = hx
alias v = hx
alias l = ls -l
alias la = ls -a
alias ll = ls -la
alias c = clear

# --- NixOS Quick Directory Navigation (ncd) ---
def --env ncd [dir?: path] {
  let target = ($dir | default "/etc/nixos")
  cd $target
}

# --- Shell Integrations ---
source @starshipInit@
source @zoxideInit@
source @carapaceInit@
