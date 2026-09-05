
{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, lib, ... }:
    let
      bibataFixed = pkgs.runCommand "bibata-modern-classic-fixed" { } ''
        mkdir -p $out/share/icons
        cp -r ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic $out/share/icons/Bibata-Modern-Classic
        chmod -R u+w $out/share/icons/Bibata-Modern-Classic
        cd $out/share/icons/Bibata-Modern-Classic/cursors
        [ -e hand2 ] || ln -sf pointer hand2
        [ -e sb_v_double_arrow ] || ln -sf ns-resize sb_v_double_arrow
        [ -e sb_h_double_arrow ] || ln -sf ew-resize sb_h_double_arrow
      '';
    in
    {
      security.pam.services.hyprlock = {};

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "antigravity-cli"
        ];

      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Classic";
        XCURSOR_SIZE = "16";
      };

      environment.systemPackages = with pkgs; [
        bat
        fd
        ripgrep
        btop
        cava
        yazi
        fetch
        zoxide
        antigravity-cli
        bibataFixed

        hyprlock
        overskride
        bluez
        bluez-tools

        git
        ghostty
        foot
        grim
        slurp
        wl-clipboard
        brightnessctl
        playerctl
        vim
        wget
        curl
      ];

      fonts.packages = with pkgs; [
        maple-mono.NF-unhinted
        maple-mono.truetype
        symbola
        nerd-fonts.symbols-only
      ];
    };
}
