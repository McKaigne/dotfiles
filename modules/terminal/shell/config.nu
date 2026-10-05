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
    toclip:   "| wl-copy"
    fromclip: "wl-paste"
    silent:   "o+e> /dev/null"
    noerr:    "e> /dev/null"
    savef:    "| save --force "
    savea:    "| save --force --append "

    tojson:   "| to json -i 2"
    fromjson: "| from json"
    toyaml:   "| to yaml"
    fromyaml: "| from yaml"
    tokdl:    "| to kdl"
    fromkdl:  "| from kdl"

    nlaunch:   "noctalia msg panel-toggle launcher"
    ncontrol:  "noctalia msg panel-toggle control-center"
    nsession:  "noctalia msg panel-toggle session"
    nclip:     "noctalia msg panel-toggle clipboard"
    nsettings: "noctalia msg settings-toggle"
    nbar:      "noctalia msg bar-toggle"
    nlock:     "noctalia msg session lock"
    nclosemsg: "noctalia msg notification-clear-active"

    nreload: "niri msg action load-config-file"
    nclose:  "niri msg action close-window"
    nquit:   "niri msg action quit"
    nfocus:  "niri msg action focus-window --id "
    nwins:   "niri msg -j windows | from json"
    nwork:   "niri msg -j workspaces | from json"
    nmon:    "niri msg -j outputs | from json"

    rebuild: "sudo nixos-rebuild switch --flake /etc/nixos"
    nr:      "sudo nixos-rebuild switch --flake /etc/nixos"
    nboot:   "sudo nixos-rebuild boot --flake /etc/nixos"
    ntest:   "sudo nixos-rebuild test --flake /etc/nixos"
    ncd:     "cd /etc/nixos"
    nupdate: "nix flake update --flake /etc/nixos"
    nclean:  "nix-collect-garbage -d"
    ntry:    "nix run nixpkgs#"
    nshell:  "nix shell nixpkgs#"
    ntrace:  "--show-trace"

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

    zj:    "zellij"
    zja:   "zellij attach "
    zjl:   "zellij list-sessions"
    zjk:   "zellij kill-session "
    zjka:  "zellij kill-all-sessions"

    zq:    "zoxide query "
    zql:   "zoxide query -l"
    za:    "zoxide add "
    zr:    "zoxide remove "

    hxf: "nvim /etc/nixos/flake.nix"
    hxh: "nvim /etc/nixos/hosts/castor/default.nix"
    hxc: "nvim /etc/nixos/modules/core/default.nix"
    hxn: "nvim /etc/nixos/modules/terminal/shell/config.nu"
    hxi: "nvim /etc/nixos/modules/desktop/niri/config.kdl"
    hxz: "nvim /etc/nixos/modules/terminal/zellij/config.kdl"
  }
}

def get-config-files [path: string] {
  let target = ($path | path expand)
  let extensions = [
    "-e" "nix" "-e" "kdl" "-e" "toml" "-e" "conf" "-e" "ini" "-e" "el" "-e" "json" "-e" "nu" "-e" "py" "-e" "css" "-e" "lua"
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

  ^fd . $target -t f -L -H -S -50k ...$extensions ...$excludes | lines
}

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

alias l = ls
alias ll = ls -l
alias la = ls -a
alias v = nvim
alias vi = nvim
alias vim = nvim
alias hx = helix
alias bottom = btm
alias y = yazi
alias f = ^fetch
alias fetch = ^fetch
alias g = git
alias lg = lazygit
alias music = cliamp
alias amp = cliamp

source "@starshipInit@"
source "@zoxideInit@"
source "@carapaceInit@"
