
$env.config = {
  show_banner: false
  edit_mode: emacs
  cursor_shape: {
    emacs: block
    vi_insert: line
    vi_normal: block
  }
  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "prefix"
  }
}

# --- Expandable Command Abbreviations (Modular & Composable) ---
$env.config.abbreviations = {
  # =========================================================================
  # 1. Modular Pipe Suffixes & Structured Data (Stringable at end of command)
  # =========================================================================
  tojson: "| to json -i 2"
  fromjson: "| from json"
  toyaml: "| to yaml"
  fromyaml: "| from yaml"
  totoml: "| to toml"
  fromtoml: "| from toml"
  tomd: "| to md -p"
  wcopy: "| wl-copy"
  wpaste: "| wl-paste"
  sortby: "| sort-by"
  first10: "| first 10"
  savef: "| save -f"
  strim: "| str trim"
  lines: "| lines"
  flatten: "| flatten"

  # =========================================================================
  # 2. Nushell-Exclusive System & Table Powers
  # =========================================================================
  nps: "ps | sort-by cpu -r | first 15"
  nmem: "ps | sort-by mem -r | first 15"
  nls: "ls | sort-by modified -r"
  nlsize: "ls | sort-by size -r"
  ncpu: "sys cpu"
  nsys: "sys host"
  nopen: "open --raw"
  npath: "$env.PATH | split row (char esep)"
  nenv: "$env | transpose key value | sort-by key"

  # =========================================================================
  # 3. NixOS & Flake Maintenance (castor-specific & generic)
  # =========================================================================
  ncd: "cd /etc/nixos"
  nr: "sudo nixos-rebuild switch --flake /etc/nixos#castor"
  nrb: "sudo nixos-rebuild boot --flake /etc/nixos#castor"
  nrt: "sudo nixos-rebuild test --flake /etc/nixos#castor"
  nfc: "nix flake check /etc/nixos --show-trace"
  nfu: "nix flake update --flake /etc/nixos"
  ndev: "nix develop"
  nsh: "nix-shell -p"
  nrun: "nix run nixpkgs#"
  ncg: "sudo nix-collect-garbage -d"
  nopt: "nix store optimise"

  # =========================================================================
  # 4. Git Workflows
  # =========================================================================
  gaa: "git add -A"
  gap: "git add -p"
  gcm: "git commit -m"
  gca: "git commit --amend"
  gcan: "git commit --amend --no-edit"
  gco: "git checkout"
  gcb: "git checkout -b"
  gsw: "git switch"
  gswc: "git switch -c"
  gst: "git status -sb"
  gdiff: "git diff"
  gds: "git diff --staged"
  gpush: "git push"
  gpf: "git push --force-with-lease"
  gpull: "git pull --rebase"
  glog: "git log --oneline --graph --decorate"
  grbi: "git rebase -i"
  grbc: "git rebase --continue"
  grba: "git rebase --abort"
  gsta: "git stash push -m"
  gstp: "git stash pop"
  gstd: "git stash drop"
  greset: "git reset --hard"

  # =========================================================================
  # 5. GitHub CLI (gh)
  # =========================================================================
  ghpr: "gh pr list"
  ghprc: "gh pr create"
  ghprv: "gh pr view --web"
  ghrc: "gh repo clone"
  ghrv: "gh repo view --web"
  ghis: "gh issue list"

  # =========================================================================
  # 6. Compositor & Shell (Niri & Noctalia IPC)
  # =========================================================================
  nmsg: "niri msg"
  nwin: "niri msg windows"
  nlay: "niri msg layers"
  nact: "niri msg action"
  nrel: "niri msg action reload-config"
  nmon: "niri msg outputs"
  noc: "noctalia msg"
  nocset: "noctalia msg color-scheme-set builtin"
  nocapp: "noctalia msg templates-apply"
  noclist: "noctalia theme --list-templates"
  nocwall: "noctalia msg wallpaper-random"
  noclock: "noctalia msg lock"
  nocbar: "noctalia msg bar-toggle"

  # =========================================================================
  # 7. Terminal Multiplexer & Modal Editor (Tmux & Helix)
  # =========================================================================
  tma: "tmux attach -t"
  tml: "tmux list-sessions"
  tmn: "tmux new-session -s"
  tmk: "tmux kill-session -t"
  tmka: "tmux kill-server"
  hxconf: "helix /etc/nixos/modules/config.toml"
  hxrel: "pkill -USR1 hx"

  # =========================================================================
  # 8. Modern CLI Tools & New Diagnostics (btm, dust, procs, tealdeer, etc.)
  # =========================================================================
  bt: "btm"
  lg: "lazygit"
  tlup: "tldr --update"
  ll: "eza -l --icons --git"
  la: "eza -la --icons --git"
  lt: "eza --tree --level=2 --icons"
  tree: "eza --tree --icons"
  cat: "bat --paging=never"
  grep: "rg"
  find: "fd"
}

# Initialize dynamic integrations
source @starshipInit@
source @zoxideInit@
source @carapaceInit@
