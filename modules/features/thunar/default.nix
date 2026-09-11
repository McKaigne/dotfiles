{ self, lib, ... }:
{
  perSystem = { pkgs, self', ... }:
    let
      thunarWithPlugins = pkgs.thunar.override {
        thunarPlugins = with pkgs; [
          thunar-archive-plugin
          thunar-volman
        ];
      };

      archiveTools = with pkgs; [
        file-roller
        gnutar
        zip
        unzip
        gzip
        bzip2
        xz
        zstd
        p7zip
      ];

      iconDirs = "${pkgs.adwaita-icon-theme}/share:${pkgs.hicolor-icon-theme}/share:/run/current-system/sw/share";

      wrappedThunar = pkgs.symlinkJoin {
        name = "thunar";
        paths = [ thunarWithPlugins ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/thunar \
            --prefix PATH : ${lib.makeBinPath archiveTools} \
            --prefix XDG_DATA_DIRS : "${iconDirs}"
        '';
      };
    in
    {
      packages.thunar = wrappedThunar;

      apps.thunar = {
        type = "app";
        program = "${self'.packages.thunar}/bin/thunar";
        meta.description = "Hermetically wrapped Thunar file manager";
      };
    };

  flake = let
    nixosModule = { pkgs, ... }: {
      programs.xfconf.enable = true;
      services.gvfs.enable = true;
      services.tumbler.enable = true;

      services.dbus.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.thunar
      ];

      systemd.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.thunar
      ];

      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.thunar
      ];

      environment.etc."xdg/xfce4/helpers.rc".text = ''
        TerminalEmulator=ghostty
        TerminalEmulatorCustom=ghostty
      '';

      environment.etc."xdg/Thunar/uca.xml".text = builtins.replaceStrings
        [ "@ghostty@" "@zip@" "@gnutar@" ]
        [
          "${self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty}/bin/ghostty"
          "${pkgs.zip}/bin/zip"
          "${pkgs.gnutar}/bin/tar"
        ]
        (builtins.readFile ./uca.xml);

      environment.sessionVariables = {
        FILEMANAGER = "thunar";
        TERMINAL = "ghostty";
      };
    };
  in {
    nixosModules.thunar = nixosModule;
  };
}