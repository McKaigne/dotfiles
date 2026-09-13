{ self, lib, ... }:
{
  perSystem = { pkgs, self', ... }:
    let
      catppuccinIcons = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "blue";
      };

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

      iconDirs = "${catppuccinIcons}/share:${pkgs.adwaita-icon-theme}/share:${pkgs.hicolor-icon-theme}/share:/run/current-system/sw/share";

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
      packages.catppuccin-papirus-folders = catppuccinIcons;

      apps.thunar = {
        type = "app";
        program = "${self'.packages.thunar}/bin/thunar";
        meta.description = "Hermetically wrapped Thunar file manager with Catppuccin Mocha icons";
      };
    };

  flake = let
    nixosModule = { pkgs, ... }:
      let
        catppuccinIcons = pkgs.catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "blue";
        };
      in
      {
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
          catppuccinIcons
        ];

        # Set Papirus-Dark (Catppuccin Mocha) in GTK3 settings
        environment.etc."xdg/gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-icon-theme-name=Papirus-Dark
          gtk-theme-name=adw-gtk3-dark
        '';

        # Set Papirus-Dark in Thunar's native Xfconf channel
        environment.etc."xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <channel name="xsettings" version="1.0">
            <property name="Net" type="empty">
              <property name="ThemeName" type="string" value="adw-gtk3-dark"/>
              <property name="IconThemeName" type="string" value="Papirus-Dark"/>
            </property>
          </channel>
        '';

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