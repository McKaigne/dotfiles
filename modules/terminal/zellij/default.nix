{ config, pkgs, lib, ... }:
let
  user = config.mainUser;
  zjstatusWasm = pkgs.fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
    sha256 = "4de426d20b1cbf861272e927aeeb5b49d92c17f0e2bb9d173f85bf7f0154dd53";
  };

  zellijLayout = ''
    layout {
      pane size=1 borderless=true {
        plugin location="file:${zjstatusWasm}" {
          format_left   " #[fg=$yellow,bold]● {session} #[fg=$black]•{tabs}"
          format_center ""
          format_right  "{mode} "
          format_space  "#[bg=NONE]"

          tab_normal   " #[fg=$white]○ {index} {name} #[fg=$black]•"
          tab_active   " #[fg=$fg,bold]● {index} {name} #[fg=$black]•"
          tab_sync     " #[fg=$yellow,bold]󰓩 "

          mode_locked  "#[fg=$black]LCK"
          mode_normal  "#[fg=$magenta,bold]NOR #[fg=$white][p]ane [t]ab [r]esize [s]croll [q]uit"
          mode_pane    "#[fg=$cyan,bold]PAN #[fg=$white][h/j/k/l]move [r]ight [d]own [x]close [f]ull"
          mode_tab     "#[fg=$yellow,bold]TAB #[fg=$white][h/l]prev/next [n]ew [x]close [1-9]goto"
          mode_scroll  "#[fg=$green,bold]SCR #[fg=$white][j/k]down/up [d/u]page [s]earch"
          mode_resize  "#[fg=$blue,bold]RES #[fg=$white][h/j/k/l]resize [+/-]grow/shrink"
          mode_session "#[fg=$orange,bold]SES #[fg=$white][d]etach [w]orkspace"
        }
      }
      pane
    }
  '';
in
{
  environment.systemPackages = [ pkgs.zellij ];

  home-manager.users.${user} = {
    xdg.configFile."zellij/config.kdl".source = ./config.kdl;
    xdg.configFile."zellij/layouts/default.kdl" = {
      text = zellijLayout;
      force = true;
    };
  };
}
