{ self, inputs, ... }:
let
  makeNiriConfig = { pkgs, lib, system, noctaliaPkg }:
    let
      screenshotArea = pkgs.writeShellScriptBin "screenshot-area" ''
        set -euo pipefail
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      screenshotFull = pkgs.writeShellScriptBin "screenshot-full" ''
        set -euo pipefail
        ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      brightnessUp = pkgs.writeShellScriptBin "brightness-up" ''
        set -euo pipefail
        ${pkgs.brightnessctl}/bin/brightnessctl set +5%
      '';

      brightnessDown = pkgs.writeShellScriptBin "brightness-down" ''
        set -euo pipefail
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl get)
        max=$(${pkgs.brightnessctl}/bin/brightnessctl max)
        new=$((curr - max * 5 / 100))
        if [ "$new" -lt "$((max * 5 / 100))" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set 5%
        else
          ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
        fi
      '';

      zellijFocus = pkgs.writeShellScriptBin "zellij-focus" ''
        set -euo pipefail
        WINDOW_ID=$(${pkgs.niri}/bin/niri msg -j windows 2>/dev/null | \
          ${pkgs.jq}/bin/jq -r '.[] | select((.app_id == "ghostty.zellij") or (.title | test("zellij-terminal"; "i"))) | .id' | head -n1 || true)
        if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
          ${pkgs.niri}/bin/niri msg action focus-window --id "$WINDOW_ID"
        else
          exec ${pkgs.ghostty}/bin/ghostty \
            --class="ghostty.zellij" --title="zellij-terminal" \
            -e ${pkgs.zellij}/bin/zellij attach --create
        fi
      '';
    in
    builtins.replaceStrings
      [
        "@noctalia@"
        "@xwaylandSatellite@"
        "@systemctl@"
        "@ghostty@"
        "@brave@"
        "@obsidian@"
        "@nautilus@"
        "@wpctl@"
        "@playerctl@"
        "@zellijFocus@"
        "@easyeffects@"
        "@pavucontrol@"
        "@screenshotArea@"
        "@screenshotFull@"
        "@brightnessUp@"
        "@brightnessDown@"
      ]
      [
        "${noctaliaPkg}/bin/noctalia"
        "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
        "${pkgs.systemd}/bin/systemctl"
        "${pkgs.ghostty}/bin/ghostty"
        "${lib.getExe pkgs.brave-origin}"
        "${pkgs.obsidian}/bin/obsidian"
        "${pkgs.nautilus}/bin/nautilus"
        "${pkgs.wireplumber}/bin/wpctl"
        "${pkgs.playerctl}/bin/playerctl"
        "${zellijFocus}/bin/zellij-focus"
        "${pkgs.easyeffects}/bin/easyeffects"
        "${pkgs.pavucontrol}/bin/pavucontrol"
        "${screenshotArea}/bin/screenshot-area"
        "${screenshotFull}/bin/screenshot-full"
        "${brightnessUp}/bin/brightness-up"
        "${brightnessDown}/bin/brightness-down"
      ]
      (builtins.readFile ./config.kdl);
in
{
  perSystem = { pkgs, lib, system, ... }:
  let
    noctaliaPkg = inputs.noctalia.packages.${system}.default;
    niriConfigRaw = makeNiriConfig { inherit pkgs lib system noctaliaPkg; };
  in
  {
    packages.myNiri = pkgs.symlinkJoin {
      name = "niri-wrapped";
      paths = [ pkgs.niri ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/niri \
          --prefix PATH : "${lib.makeBinPath [ pkgs.xwayland-satellite pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.brightnessctl pkgs.playerctl pkgs.wireplumber ]}"
      '';
      passthru = (pkgs.niri.passthru or {}) // {
        providedSessions = [ "niri" ];
        configKdl = niriConfigRaw;
      };
    };
  };

  flake.nixosModules.niri = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
    system = pkgs.stdenv.hostPlatform.system;
    myNiri = self.packages.${system}.myNiri;
    noctaliaPkg = inputs.noctalia.packages.${system}.default;
    niriConfigText = makeNiriConfig { inherit pkgs lib system noctaliaPkg; };
  in
  {
    programs.niri.enable = true;
    # Maintain pkgs.niri as the canonical sessionPackage while using myNiri for runtime executions
    programs.niri.package = pkgs.niri;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${myNiri}/bin/niri-session";
          user = user;
        };
      };
    };

    home-manager.users.${user} = {
      xdg.configFile."niri/config.kdl" = {
        text = niriConfigText;
        force = true;
      };
    };

    environment.systemPackages = [
      myNiri
      pkgs.xwayland-satellite
    ];
  };
}
