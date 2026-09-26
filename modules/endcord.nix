
{ self, ... }:
let
  nixosModule = { pkgs, config, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.endcord
    ];

    systemd.tmpfiles.rules = [
      "d /home/${config.mainUser}/.config/endcord/themes 0755 ${config.mainUser} users -"
    ];
  };
in
{
  flake.nixosModules.endcord = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      version = "1.5.3";
      endcordTar = pkgs.fetchurl {
        url = "https://github.com/sparklost/endcord/releases/download/${version}/endcord-${version}-linux.tar.gz";
        sha256 = "dc6d2b202e464a52760ed7a0a5463fd78b6b87ba939833abb4255d9416027fa4";
      };

      endcordRaw = pkgs.stdenv.mkDerivation {
        pname = "endcord";
        inherit version;
        src = endcordTar;
        sourceRoot = ".";

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ pkgs.stdenv.cc.cc.lib pkgs.glibc pkgs.alsa-lib ];

        installPhase = ''
          mkdir -p $out/bin
          cp endcord $out/bin/endcord
          chmod +x $out/bin/endcord
        '';
      };

      noctaliaTheme = pkgs.writeText "noctalia.ini" ''
        [theme]
        format_message = "[%timestamp] <%global_name> | %content %edited"
        format_message_grouped = " > %content %edited"
        format_newline = " %content"
        format_reply = "[REPLY] <%global_name> | ┌── [%timestamp] %content"
        format_reactions = "[REACT] └── %reactions"
      '';

      endcordConfig = pkgs.writeText "config.ini" ''
        [settings]
        theme = noctalia
      '';

      endcordConfigDir = pkgs.runCommand "endcord-config-dir" {} ''
        mkdir -p $out/endcord/themes
        cp ${endcordConfig} $out/endcord/config.ini
        cp ${noctaliaTheme} $out/endcord/themes/noctalia.ini
      '';

      wrappedEndcord = pkgs.symlinkJoin {
        name = "endcord";
        paths = [ endcordRaw ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/endcord \
            --prefix PATH : "${lib.makeBinPath [ pkgs.wl-clipboard pkgs.xclip ]}" \
            --run '
              mkdir -p "$HOME/.config/endcord/themes"
              ln -sf "${noctaliaTheme}" "$HOME/.config/endcord/themes/noctalia.ini"
            ' \
            --add-flags "-c ${endcordConfigDir}/endcord/config.ini"
        '';
      };
    in
    {
      packages.endcord = wrappedEndcord;

      apps.endcord = {
        type = "app";
        program = "${wrappedEndcord}/bin/endcord";
        meta.description = "Feature-rich Discord TUI client with Noctalia theme";
      };
    };
}
