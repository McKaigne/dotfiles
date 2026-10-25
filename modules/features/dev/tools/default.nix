{ self, inputs, ... }: {
  flake.nixosModules.devTools =
    { pkgs, lib, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      ghgrabPkg = inputs.ghgrab.packages.${system}.default;

      # LearnHarness JIT AppImage Runtime
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

      # Google Antigravity CLI
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

      # upmd: Markdown task runner (pre-built static MUSL binary)
      upmdPkg = pkgs.writeShellScriptBin "upmd" ''
        DIR="$HOME/.local/share/upmd"
        BIN="$DIR/upmd"
        mkdir -p "$DIR"
        if [ ! -x "$BIN" ]; then
          echo "==> Fetching upmd static release..." >&2
          ${pkgs.curl}/bin/curl -fsSL https://github.com/rezigned/upmd/releases/latest/download/upmd-x86_64-unknown-linux-musl.tar.gz | ${pkgs.gnutar}/bin/tar -xz -C "$DIR"
          chmod +x "$BIN"
        fi
        exec "$BIN" "$@"
      '';

      # lazyrsync: Friendly TUI for rsync (pre-built static MUSL binary)
      lazyrsyncPkg = pkgs.writeShellScriptBin "lazyrsync" ''
        DIR="$HOME/.local/share/lazyrsync"
        BIN="$DIR/lazyrsync"
        mkdir -p "$DIR"
        if [ ! -x "$BIN" ]; then
          echo "==> Fetching lazyrsync static release..." >&2
          ${pkgs.curl}/bin/curl -fsSL https://github.com/westpoint-io/lazyrsync/releases/latest/download/lazyrsync-x86_64-unknown-linux-musl.tar.gz | ${pkgs.gnutar}/bin/tar -xz -C "$DIR"
          chmod +x "$BIN"
        fi
        exec "$BIN" "$@"
      '';

      # lazyssh: Terminal SSH Manager in Go (pre-built static binary)
      lazysshPkg = pkgs.writeShellScriptBin "lazyssh" ''
        DIR="$HOME/.local/share/lazyssh"
        BIN="$DIR/lazyssh"
        mkdir -p "$DIR"
        if [ ! -x "$BIN" ]; then
          echo "==> Fetching lazyssh static release..." >&2
          ${pkgs.curl}/bin/curl -fsSL https://github.com/Adembc/lazyssh/releases/latest/download/lazyssh_Linux_x86_64.tar.gz | ${pkgs.gnutar}/bin/tar -xz -C "$DIR"
          chmod +x "$BIN"
        fi
        exec "$BIN" "$@"
      '';

      # usbtree: Live USB device tree TUI in Rust (pre-built static binary)
      usbtreePkg = pkgs.writeShellScriptBin "usbtree" ''
        DIR="$HOME/.local/share/usbtree"
        BIN="$DIR/usbtree"
        mkdir -p "$DIR"
        if [ ! -x "$BIN" ]; then
          echo "==> Fetching usbtree static release..." >&2
          ${pkgs.curl}/bin/curl -fsSL https://github.com/gnomeria/usbtree/releases/latest/download/usbtree_x86_64-unknown-linux-musl.tar.gz | ${pkgs.gnutar}/bin/tar -xz -C "$DIR"
          chmod +x "$BIN"
        fi
        exec "$BIN" "$@"
      '';

      # quien: Modern interactive whois/domain intelligence TUI (pre-built binary)
      quienPkg = pkgs.writeShellScriptBin "quien" ''
        DIR="$HOME/.local/share/quien"
        BIN="$DIR/quien"
        mkdir -p "$DIR"
        if [ ! -x "$BIN" ]; then
          echo "==> Fetching quien static release..." >&2
          ${pkgs.curl}/bin/curl -fsSL https://github.com/retlehs/quien/releases/latest/download/quien_Linux_x86_64.tar.gz | ${pkgs.gnutar}/bin/tar -xz -C "$DIR"
          chmod +x "$BIN"
        fi
        exec "$BIN" "$@"
      '';

      # linecast: Ambient weather, sun, moon, and tides TUI
      linecastPkg = pkgs.writeShellScriptBin "linecast" ''
        DIR="$HOME/.local/share/linecast"
        PYZ="$DIR/linecast.pyz"
        mkdir -p "$DIR"
        if [ ! -f "$PYZ" ]; then
          echo "==> Fetching linecast executable..." >&2
          ${pkgs.curl}/bin/curl -fsSL https://github.com/ashuttl/linecast/releases/latest/download/linecast.pyz -o "$PYZ"
        fi
        exec ${pkgs.python3}/bin/python3 "$PYZ" "$@"
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
