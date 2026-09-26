
{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.btop
    ];
  };
in
{
  flake.nixosModules.btop = nixosModule;

  perSystem = { pkgs, ... }:
    let
      fallbackTheme = pkgs.writeText "noctalia.theme" ''
        theme[main_bg]="#1e2326"
        theme[main_fg]="#d3c6aa"
        theme[title]="#d3c6aa"
        theme[hi_fg]="#a7c080"
        theme[selected_bg]="#2d353b"
        theme[selected_fg]="#d3c6aa"
        theme[inactive_fg]="#7a8478"
        theme[graph_text]="#a6b0a0"
        theme[meter_bg]="#2d353b"
        theme[proc_misc]="#83c092"
        theme[cpu_box]="#a7c080"
        theme[mem_box]="#7fbbb3"
        theme[net_box]="#d699b6"
        theme[proc_box]="#dbbc7f"
        theme[div_line]="#7a8478"
        theme[temp_start]="#a7c080"
        theme[temp_mid]="#dbbc7f"
        theme[temp_end]="#e67e80"
        theme[cpu_start]="#a7c080"
        theme[cpu_mid]="#dbbc7f"
        theme[cpu_end]="#e67e80"
        theme[free_start]="#7fbbb3"
        theme[free_mid]="#83c092"
        theme[free_end]="#a7c080"
        theme[cached_start]="#83c092"
        theme[cached_mid]="#7fbbb3"
        theme[cached_end]="#d699b6"
        theme[available_start]="#dbbc7f"
        theme[available_mid]="#a7c080"
        theme[available_end]="#83c092"
        theme[used_start]="#e67e80"
        theme[used_mid]="#dbbc7f"
        theme[used_end]="#a7c080"
        theme[download_start]="#7fbbb3"
        theme[download_mid]="#83c092"
        theme[download_end]="#a7c080"
        theme[upload_start]="#d699b6"
        theme[upload_end]="#dbbc7f"
        theme[process_start]="#83c092"
        theme[process_mid]="#a7c080"
        theme[process_end]="#e67e80"
      '';

      wrappedBtop = pkgs.symlinkJoin {
        name = "btop";
        paths = [ pkgs.btop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/btop \
            --run '
              # Seed fallback theme if Noctalia has not run its btop template yet
              mkdir -p "$HOME/.config/btop/themes"
              if [ ! -f "$HOME/.config/btop/themes/noctalia.theme" ]; then
                cp "${fallbackTheme}" "$HOME/.config/btop/themes/noctalia.theme" 2>/dev/null || true
              fi
            ' \
            --add-flags "--config ${./btop.conf} --themes-dir $HOME/.config/btop/themes"
        '';
      };
    in
    {
      packages.btop = wrappedBtop;

      apps.btop = {
        type = "app";
        program = "${wrappedBtop}/bin/btop";
        meta.description = "Hermetically wrapped btop connected to Noctalia dynamic themes";
      };
    };
}
