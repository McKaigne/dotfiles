{ self, ... }: {
  flake.nixosModules.thunar = { pkgs, ... }: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    programs.xfconf.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    environment.systemPackages = with pkgs; [
      file-roller
      adwaita-icon-theme
      adw-gtk3
      zip
      unzip
      p7zip
      gnutar
      gzip
      bzip2
      xz
      zstd
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
          <command>ghostty --working-directory=%f</command>
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
          <command>zip -r "%n.zip" %N</command>
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
          <command>tar -czf "%n.tar.gz" %N</command>
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
}