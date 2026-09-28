# Nushell Configuration - Castor Workstation Final Specification
$env.config = {
  show_banner: false
  edit_mode: 'vi'
  cursor_shape: {
    vi_insert: 'line'
    vi_normal: 'block'
  }
  table: {
    mode: 'rounded'
    index_mode: 'always'
  }
  hooks: {
    pre_prompt: [{ ||
      if (which direnv | is-not-empty) {
        direnv export json | from json | default {} | load-env
      }
    }]
  }

  abbreviations: {
    # --- PIPES, SINKS & REDIRECTIONS ---
    toclip:   "| wl-copy"
    fromclip: "wl-paste"
    silent:   "o+e> /dev/null"
    noerr:    "e> /dev/null"
    savef:    "| save --force "
    savea:    "| save --force --append "

    # --- FORMAT CONVERTERS (Nushell-Native) ---
    tojson:   "| to json -i 2"
    fromjson: "| from json"
    toyaml:   "| to yaml"
    fromyaml: "| from yaml"
    tokdl:    "| to kdl"
    fromkdl:  "| from kdl"

    # --- NOCTALIA DESKTOP INTENTS ---
    nlaunch:   "noctalia msg panel-toggle launcher"
    ncontrol:  "noctalia msg panel-toggle control-center"
    nsession:  "noctalia msg panel-toggle session"
    nclip:     "noctalia msg panel-toggle clipboard"
    nsettings: "noctalia msg settings-toggle"
    nbar:      "noctalia msg bar-toggle"
    nlock:     "noctalia msg lock"
    nclosemsg: "noctalia msg notification-dismiss"

    # --- NIRI WINDOW MANAGER INTENTS ---
    nreload: "niri msg action load-config-file"
    nclose:  "niri msg action close-window"
    nquit:   "niri msg action quit"
    nfocus:  "niri msg action focus-window --id "
    nwins:   "niri msg -j windows | from json"
    nwork:   "niri msg -j workspaces | from json"
    nmon:    "niri msg -j outputs | from json"

    # --- NIXOS SYSTEM INTENTS ---
    rebuild: "sudo nixos-rebuild switch --flake /etc/nixos#castor"
    nr:      "sudo nixos-rebuild switch --flake /etc/nixos#castor"
    nboot:   "sudo nixos-rebuild boot --flake /etc/nixos#castor"
    ntest:   "sudo nixos-rebuild test --flake /etc/nixos#castor"
    ncd:     "cd /etc/nixos"
    nupdate: "nix flake update --flake /etc/nixos"
    nclean:  "nix-collect-garbage -d"
    ntry:    "nix run nixpkgs#"
    nshell:  "nix shell nixpkgs#"
    ntrace:  "--show-trace"

    # --- GIT ACTION INTENTS ---
    ga:       "git add -A"
    gstage:   "git add -A"
    gpatch:   "git add -p"
    gundo:    "git reset --soft HEAD~1"
    gunstage: "git restore --staged ."
    gwipe:    "git reset --hard HEAD"
    gamend:   "git commit --amend --no-edit"
    gst:      "git status"
    gc:       "git commit -m \"\""
    gdiff:    "git diff"
    gdiffs:   "git diff --staged"
    gp:       "git push"
    gpushf:   "git push --force-with-lease"
    gpl:      "git pull"
    glg:      "git log --oneline --graph -n 20"
    gbranch:  "git switch "
    gnew:     "git switch -c "

    # --- TMUX INTENTS ---
    tsess: "tmux list-sessions"
    tlw:   "tmux list-windows"
    tjoin: "tmux attach-session -t "
    tnew:  "tmux new-session -s "
    tkill: "tmux kill-session -t "
    twipe: "tmux kill-server"

    # --- ZELLIJ WORKSPACE INTENTS ---
    zj:    "zellij"
    zja:   "zellij attach "
    zjl:   "zellij list-sessions"
    zjk:   "zellij kill-session "
    zjka:  "zellij kill-all-sessions"

    # --- ZOXIDE INTENTS ---
    zq:    "zoxide query "
    zql:   "zoxide query -l"
    za:    "zoxide add "
    zr:    "zoxide remove "

    # --- DIRECT HELIX CONFIG JUMPS ---
    hxf: "hx /etc/nixos/flake.nix"
    hxc: "hx /etc/nixos/modules/apps/helix/default.nix"
    hxn: "hx /etc/nixos/modules/terminal/nushell/config.nu"
    hxi: "hx /etc/nixos/modules/desktop/niri/config.kdl"
    hxt: "hx /etc/nixos/modules/terminal/tmux/tmux.conf"
  }
}

# --- TOKEN-OPTIMIZED CONFIG INSPECTION ENGINE ---

# Helper: Collects configuration files using clean Nu array spreading (no multiline parse bugs)
def get-config-files [path: string] {
  let target = ($path | path expand)
  let extensions = [
    "-e" "nix" "-e" "kdl" "-e" "toml" "-e" "conf" "-e" "ini" "-e" "el" "-e" "json" "-e" "nu" "-e" "py"
  ]
  let excludes = [
    "-E" ".git"
    "-E" "flake.lock"
    "-E" "node_modules"
    "-E" "target"
    "-E" "result"
    "-E" "*cache*"
    "-E" "*Cache*"
    "-E" "net.imput.helium"
    "-E" "google-chrome"
    "-E" "chromium"
    "-E" "spicetify"
    "-E" "spotify"
    "-E" "dconf"
    "-E" "pulse"
    "-E" "Trash"
    "-E" "storage"
    "-E" "IndexedDB"
    "-E" "*.log"
    "-E" "*.sqlite*"
    "-E" "*.db*"
    "-E" "session-store*"
  ]

  ^fd . $target -t f -H -S -50k ...$extensions ...$excludes | lines
}

# cft: Generates an AI-token-safe tree of only configuration files (default: current directory)
def cft [path: string = "."] {
  let files = (get-config-files $path)
  if ($files | is-empty) {
    print $"No configuration files found in ($path)"
    return
  }

  let tree_out = ($files | str join (char nl) | tree -a -F --fromfile)
  $tree_out | wl-copy
  print $tree_out
  print $"\n[Copied tree of ($files | length) core config files to clipboard]"
}

# cfb: Formats and dumps contents of only configuration files to clipboard (default: current directory)
def cfb [path: string = "."] {
  let files = (get-config-files $path)
  if ($files | is-empty) {
    print $"No configuration files found in ($path)"
    return
  }

  if ($files | length) > 60 {
    print $"Warning: Found ($files | length) files. Dumping full contents may use significant context tokens."
  }

  let content = ($files | each { |f| bat --style=header,grid --paging=never $f } | str join (char nl))
  $content | wl-copy
  print $"[Copied full content of ($files | length) config files to clipboard]"
}

# --- BASE ALIASES ---
alias l = ls
alias ll = ls -l
alias la = ls -a
alias hx = helix
alias bottom = btm
alias y = yazi
alias f = ^fetch
alias fetch = ^fetch
alias g = git
alias lg = lazygit

# --- COMPILED NIX STORE INTEGRATIONS ---
source "@starshipInit@"
source "@zoxideInit@"
source "@carapaceInit@"
