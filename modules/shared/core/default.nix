{ self, inputs, ... }:
let
  cfb =
    { pkgs }:
    pkgs.writeShellScriptBin "cfb" ''
      set -euo pipefail
      targetPath="."
      if [ $# -ge 1 ]; then
        case "$1" in
          nix) targetPath="/etc/nixos" ;;
          cfg) targetPath="$HOME/.config" ;;
          *) targetPath="$1" ;;
        esac
      fi

      targetPath=$(realpath "$targetPath" 2>/dev/null || echo "$targetPath")
      if [ ! -d "$targetPath" ]; then
        echo "Error: Target directory '$targetPath' does not exist." >&2
        exit 1
      fi

      echo "Generating structured LLM context snapshot for: $targetPath..."

      hostName=$(hostname 2>/dev/null || echo "workstation")
      userName=$(whoami 2>/dev/null || echo "user")
      dateString=$(date '+%Y-%m-%d %H:%M:%S')

      outputStr="================================================================================
SYSTEM CONTEXT SNAPSHOT
Host: $hostName | User: $userName | Target: $targetPath | Date: $dateString
================================================================================

--------------------------------------------------------------------------------
DIRECTORY TOPOLOGY (including empty directories)
--------------------------------------------------------------------------------
"

      extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e fish -e zsh -e sh -e py -e css -e lua -e md)

      if [[ "$targetPath" == *".config"* ]]; then
        treeIgnores='.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*|*.bin|*.dat|*asar*|*BraveSoftware*|*brave*|*chromium*|*floorp*|*librewolf*|*mozilla*|*google-chrome*|*obsidian*|*zennotes*|*Ferdium*'
        outputStr+="$(${pkgs.tree}/bin/tree "$targetPath" -a -I "$treeIgnores" --noreport 2>/dev/null || ${pkgs.tree}/bin/tree "$targetPath" -a -I '.git|result' --noreport)"
        fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "*asar" -E "*BraveSoftware*" -E "*brave*" -E "*chromium*" -E "*floorp*" -E "*librewolf*" -E "*mozilla*" -E "*google-chrome*" -E "*obsidian*" -E "*zennotes*" -E "*Ferdium*")
      else
        outputStr+="$(${pkgs.tree}/bin/tree "$targetPath" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*' --noreport 2>/dev/null || ${pkgs.tree}/bin/tree "$targetPath" --noreport)"
        fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*")
      fi

      outputStr+=$'\n\n--------------------------------------------------------------------------------\nFILE CONTENTS\n--------------------------------------------------------------------------------\n'

      files=()
      while IFS= read -r -d $'\0' file; do
        files+=("$file")
      done < <(${pkgs.fd}/bin/fd . "$targetPath" -t f -L -H -S -250k "''${extensions[@]}" "''${fdExcludes[@]}" -0 2>/dev/null)

      fileCount="''${#files[@]}"

      if [ "$fileCount" -eq 0 ]; then
        outputStr+=$'\n[No configuration files found matching extension filters.]\n'
      else
        for file in "''${files[@]}"; do
          relPath="''${file#$targetPath/}"
          outputStr+=$'\n--- START OF FILE: '"$relPath"$' ---\n'
          outputStr+="$(cat "$file" 2>/dev/null)"$'\n'
          outputStr+='--- END OF FILE: '"$relPath"$' ---\n'
        done
      fi

      printf "%s" "$outputStr" | ${pkgs.wl-clipboard}/bin/wl-copy
      byteSize=$(printf "%s" "$outputStr" | wc -c)
      kilobyteSize=$(( byteSize / 1024 ))
      echo "[Copied context: Tree + $fileCount files (''${kilobyteSize} KB) from $targetPath to clipboard]"
    '';
in
{
  flake.nixosModules.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      cfbPkg = cfb { inherit pkgs; };
    in
    {
      nixpkgs.config.allowUnfree = true;
      i18n.defaultLocale = "en_US.UTF-8";

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        auto-optimise-store = true;
        max-jobs = "auto";
        cores = 0;
        substituters = [
          "https://cache.nixos.org"
          "https://devenv.cachix.org"
          "https://noctalia.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };

      systemd.tmpfiles.rules = [
        "d /etc/nixos 0775 ${user} wheel -"
        "z /etc/nixos 0775 ${user} wheel -"
      ];

      boot.kernel.sysctl = {
        "fs.inotify.max_user_watches" = 1048576;
        "fs.inotify.max_user_instances" = 1024;
      };

      security.sudo.extraConfig = ''
        Defaults passwd_timeout=0
        Defaults timestamp_timeout=30
      '';

      environment.localBinInPath = true;

      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          openssl
          curl
          glibc
        ];
      };

      hardware.keyboard.qmk.enable = true;

      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", ATTRS{idProduct}=="0051", MODE="0660", GROUP="users", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", MODE="0660", GROUP="users", TAG+="uaccess"
      '';

      environment.sessionVariables = {
        EDITOR = "hx";
        VISUAL = "hx";
        BAT_THEME = "Catppuccin Mocha";
      };

      environment.systemPackages = with pkgs; [
        git
        delta
        lazygit
        gh
        tree
        btop
        bat
        eza
        dust
        gdu
        procs
        ripgrep
        fd
        findutils
        jq
        jnv
        sd
        xh
        curl
        yazi
        nnn
        wtype
        gawk
        fzf
        zoxide
        direnv
        cfbPkg
        aria2
        p7zip
        unrar
        rsync
        devenv
        nvd
        nix-output-monitor
        wl-clipboard
      ];
    };
}
