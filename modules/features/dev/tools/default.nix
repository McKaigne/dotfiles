{ self, inputs, ... }: {
  flake.nixosModules.devTools =
    { pkgs, lib, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      ghgrabPkg = inputs.ghgrab.packages.${system}.default;

      mkStaticBinary =
        {
          pname,
          version,
          url,
          hash,
          binaryName ? pname,
        }:
        pkgs.stdenv.mkDerivation {
          inherit pname version;
          src = pkgs.fetchurl {
            inherit url hash;
          };
          sourceRoot = ".";
          dontBuild = true;
          dontConfigure = true;
          nativeBuildInputs = [
            pkgs.autoPatchelfHook
            pkgs.unzip
          ];
          buildInputs = [
            pkgs.stdenv.cc.cc.lib
          ];
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            install -Dm755 "${binaryName}" "$out/bin/${pname}" 2>/dev/null || find . -type f -name "${binaryName}" -exec install -Dm755 {} "$out/bin/${pname}" \;
            runHook postInstall
          '';
        };

      upmdPkg = mkStaticBinary {
        pname = "upmd";
        version = "0.2.7";
        url = "https://github.com/rezigned/upmd/releases/download/v0.2.7/upmd-x86_64-unknown-linux-gnu.tar.xz";
        hash = "sha256-EBM216j0ZIo7+JTVY2h18d89IZcZ1HAJbFYuDPTWuao=";
      };

      lazyrsyncPkg = mkStaticBinary {
        pname = "lazyrsync";
        version = "0.4.0";
        url = "https://github.com/westpoint-io/lazyrsync/releases/download/v0.4.0/lazyrsync-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-G/j96R5q5SNNGsitr36rRWUa8uYTynwOLIS1O/16nns=";
      };

      lazysshPkg = mkStaticBinary {
        pname = "lazyssh";
        version = "0.3.0";
        url = "https://github.com/Adembc/lazyssh/releases/download/v0.3.0/lazyssh_Linux_x86_64.tar.gz";
        hash = "sha256-PocZb690iQX5gGIEDVoOBW3g4OsCR0E7cML8A8OSitk=";
      };

      usbtreePkg = mkStaticBinary {
        pname = "usbtree";
        version = "0.1.1";
        url = "https://github.com/gnomeria/usbtree/releases/download/v0.1.1/usbtree_0.1.1_linux-amd64.tar.gz";
        hash = "sha256-AA/LZKO1qnOsRhgzppNGGM9b0DlHEXdS1hFzvz0rjvo=";
      };

      quienPkg = mkStaticBinary {
        pname = "quien";
        version = "0.12.0";
        url = "https://github.com/retlehs/quien/releases/download/v0.12.0/quien_linux_amd64.tar.gz";
        hash = "sha256-Kq5C6GEDdO5X5Hk5vmW/fhbxRhRaQCcI5/G12yaP7YM=";
      };

      linecastPkg = pkgs.stdenv.mkDerivation {
        pname = "linecast";
        version = "2.11.0";
        src = pkgs.fetchurl {
          url = "https://github.com/ashuttl/linecast/releases/download/v2.11.0/linecast.pyz";
          hash = "sha256-FbbEsBhjdGxkIOphxxE9i1YbE/sKsFKAKAvFylp+RAE=";
        };
        dontUnpack = true;
        dontBuild = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin $out/share/linecast
          cp $src $out/share/linecast/linecast.pyz
          makeWrapper ${pkgs.python3}/bin/python3 $out/bin/linecast \
            --add-flags "$out/share/linecast/linecast.pyz"
          runHook postInstall
        '';
      };

      # LearnHarness JIT AppImage Runtime Bridge (Active Development)
      learnharnessPkg = pkgs.writeShellScriptBin "learnharness" ''
        APP_DIR="$HOME/.local/share/learnharness"
        APP_BIN="$APP_DIR/learnharness.AppImage"
        mkdir -p "$APP_DIR"

        if [ ! -f "$APP_BIN" ]; then
          echo "==> LearnHarness: Initializing local runtime from amosblomqvist/learnharness..." >&2
          LATEST_URL=$(${pkgs.curl}/bin/curl -fsSL https://api.github.com/repos/amosblomqvist/learnharness/releases/latest 2>/dev/null \
            | ${pkgs.jq}/bin/jq -r '.assets[] | select(.name | test("(?i)\\.AppImage$")) | .browser_download_url' | head -n 1)

          if [ -z "$LATEST_URL" ] || [ "$LATEST_URL" = "null" ]; then
            LATEST_URL="https://github.com/amosblomqvist/learnharness/releases/download/v0.3.7/LearnHarness-0.3.7.AppImage"
          fi

          ${pkgs.curl}/bin/curl -fL --progress-bar -o "$APP_BIN" "$LATEST_URL"
          chmod +x "$APP_BIN"
        fi

        exec ${pkgs.appimage-run}/bin/appimage-run "$APP_BIN" --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations "$@"
      '';

      # Google Antigravity CLI Runtime Bridge
      agyPkg = pkgs.writeShellScriptBin "agy" ''
        if [ -x "$HOME/.local/bin/agy" ]; then
          exec "$HOME/.local/bin/agy" "$@"
        fi
        exec ${pkgs.curl}/bin/curl -fsSL https://antigravity.google/cli/install.sh | bash && exec "$HOME/.local/bin/agy" "$@"
      '';

      # OpenAI Codex CLI runtime
      codexPkg = pkgs.writeShellScriptBin "codex" ''
        exec ${pkgs.nodejs_22}/bin/npx --yes @openai/codex "$@"
      '';

      # Pi Coding Agent Harness
      piPkg = pkgs.writeShellScriptBin "pi" ''
        exec ${pkgs.nodejs_22}/bin/npx --yes @earendil-works/pi-coding-agent "$@"
      '';

      # endcord: Terminal Discord Client
      endcordPkg = pkgs.writeShellScriptBin "endcord" ''
        DIR="$HOME/.local/share/endcord"
        mkdir -p "$DIR"
        if [ ! -d "$DIR/repo" ]; then
          echo "==> Initializing endcord repository..." >&2
          ${pkgs.git}/bin/git clone --depth 1 https://github.com/sparklost/endcord.git "$DIR/repo"
        fi
        exec ${pkgs.python3}/bin/python3 "$DIR/repo/endcord.py" "$@"
      '';
    in
    {
      environment.systemPackages = with pkgs; [
        hyperfine
        tokei
        glow
        lazydocker
        ast-grep
        ghgrabPkg
        lazyrsyncPkg
        lazysshPkg
        usbtreePkg
        quienPkg
        linecastPkg
        upmdPkg
        endcordPkg
        agyPkg
        codexPkg
        piPkg
        learnharnessPkg
        appimage-run
      ];
    };
}
