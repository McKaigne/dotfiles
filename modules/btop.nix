
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
      noctaliaBtopTheme = pkgs.writeText "noctalia.theme" ''
        theme[main_bg]="#1e1e2e"
        theme[main_fg]="#cdd6f4"
        theme[title]="#cba6f7"
        theme[hi_fg]="#cba6f7"
        theme[selected_bg]="#313244"
        theme[selected_fg]="#cdd6f4"
        theme[inactive_fg]="#585b70"
        theme[graph_text]="#a6adc8"
        theme[meter_bg]="#313244"
        theme[proc_misc]="#94e2d5"
        theme[cpu_box]="#cba6f7"
        theme[mem_box]="#89b4fa"
        theme[net_box]="#f5c2e7"
        theme[proc_box]="#fab387"
        theme[div_line]="#45475a"
        theme[temp_start]="#a6e3a1"
        theme[temp_mid]="#f9e2af"
        theme[temp_end]="#f38ba8"
        theme[cpu_start]="#a6e3a1"
        theme[cpu_mid]="#f9e2af"
        theme[cpu_end]="#f38ba8"
      '';

      btopConfigDir = pkgs.runCommand "btop-config-dir" {} ''
        mkdir -p $out/btop/themes
        cp ${./btop.conf} $out/btop/btop.conf
        cp ${noctaliaBtopTheme} $out/btop/themes/noctalia.theme
      '';

      wrappedBtop = pkgs.symlinkJoin {
        name = "btop";
        paths = [ pkgs.btop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/btop \
            --add-flags "--config ${btopConfigDir}/btop/btop.conf --themes-dir ${btopConfigDir}/btop/themes"
        '';
      };
    in
    {
      packages.btop = wrappedBtop;

      apps.btop = {
        type = "app";
        program = "${wrappedBtop}/bin/btop";
        meta.description = "Hermetically wrapped btop monitor with Noctalia theme";
      };
    };
}
