# nixos — hyde & castor

Based on [Ly-sec/nixos](https://github.com/Ly-sec/nixos): a dendritic flake-parts
config built around [Umbriel](modules/desktops/umbriel) and
[Noctalia](modules/programs/noctalia).

| Host | User | Hardware |
| :--- | :--- | :--- |
| [hyde](modules/hosts/hyde) | `jekyll` | AMD desktop, DP-1 1920x1080@240 |
| [castor](modules/hosts/castor) | `pollux` | Intel laptop, eDP-1 |

**Apps** · [Foot](modules/programs/foot.nix) + [Zellij](modules/programs/zellij.nix)
· [Fish + Tide](modules/programs/fish) · [Emacs](modules/programs/emacs)
· [Helix](modules/programs/helix.nix) · [LibreWolf](modules/programs/librewolf)
· [Helium](modules/programs/helium)

## Build

```sh
nr              # switch this host (ndeploy switch)
ntest           # activate until reboot
nr castor       # build on hyde, activate on castor over Tailscale
```
