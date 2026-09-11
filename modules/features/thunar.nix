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
        pkgs.file-roller
      ];

      environment.etc."xdg/xfce4/helpers.rc".text = ''
        TerminalEmulator=ghostty
        TerminalEmulatorCustom=ghostty
      '';

      environment.etc."xdg/Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
          <action>
            <icon>utilities-terminal</icon>
            <name>Open Terminal Here</name>
            <submenu></submenu>
            <unique-id>open-terminal-here</unique-id>
            <command>${self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty}/bin/ghostty --working-directory=%f</command>
            <description>Open Ghostty in the current directory</description>
            <range></range>
            <patterns>*</patterns>
            <directories/>
          </action>

          <action>
            <icon>package-x-generic</icon>
            <name>Compress to .ZIP</name>
            <submenu></submenu>
            <unique-id>compress-to-zip</unique-id>
            <command>${pkgs.zip}/bin/zip -r "%n.zip" %N</command>
            <description>Compress selection into a .zip archive</description>
            <range></range>
            <patterns>*</patterns>
            <all-files/>
            <directories/>
            <audio-files/>
            <image-files/>
            <other-files/>
            <text-files/>
            <video-files/>
          </action>

          <action>
            <icon>package-x-generic</icon>
            <name>Compress to .TAR.GZ</name>
            <submenu></submenu>
            <unique-id>compress-to-tar</unique-id>
            <command>${pkgs.gnutar}/bin/tar -czf "%n.tar.gz" %N</command>
            <description>Compress selection into a .tar.gz archive</description>
            <range></range>
            <patterns>*</patterns>
            <all-files/>
            <directories/>
            <audio-files/>
            <image-files/>
            <other-files/>
            <text-files/>
            <video-files/>
          </action>
        </actions>
      '';

      environment.sessionVariables = {
        FILEMANAGER = "thunar";
        TERMINAL = "ghostty";
      };
    };
  in {
    nixosModules.thunar = nixosModule;
    nixosModules.castorConfiguration = nixosModule;
  };
}