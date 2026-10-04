{ config, pkgs, lib, ... }:
let
  user = config.mainUser;
  zjstatusWasm = pkgs.fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
    sha256 = "4de426d20b1cbf861272e927aeeb5b49d92c17f0e2bb9d173f85bf7f0154dd53";
  };

  zellijLayout = ''
    layout {
      pane
      pane size=1 borderless=true {
        plugin location="file:${zjstatusWasm}" {
          format_left   " {mode} #[fg=$fg,bold]□ {session}#[fg=$black]    {tabs}"
          format_center ""
          format_right  ""
          format_space  ""

          tab_normal   "#[fg=$black] {index} {name} #[fg=$black]·"
          tab_active   "#[fg=$fg,bold]▶ {index} {name} #[fg=$black]·"
          tab_sync     "#[fg=$yellow] "

          mode_locked  "#[fg=$black,bold]⬡ LOCKED"
          mode_normal  "#[fg=$magenta,bold]⬢ NORMAL"
          mode_pane    "#[fg=$cyan,bold]⬟ PANE"
          mode_tab     "#[fg=$yellow,bold]■ TAB"
          mode_resize  "#[fg=$blue,bold]▲ RESIZE"
          mode_scroll  "#[fg=$green,bold]● SCROLL"
          mode_session "#[fg=$orange,bold]◆ SESSION"
        }
      }
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
