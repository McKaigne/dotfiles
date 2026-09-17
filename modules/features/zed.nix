{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.zed-editor
    ];
  };
in
{
  flake.nixosModules.zed = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      fixedCursor = self'.packages.bibata-cursors-fixed;
      iconPath = "${fixedCursor}/share/icons:/run/current-system/sw/share/icons";

      # Pre-installed language servers, compilers, and formatters
      zedRuntimeDeps = with pkgs; [
        direnv
        git
        wl-clipboard

        # C / C++
        clang-tools # provides clangd
        gcc
        gnumake

        # CMake
        cmake
        cmake-language-server

        # Nix
        nixd
        nixfmt

        # Lua
        lua-language-server
        stylua

        # TOML
        taplo

        # Markdown
        marksman
      ];

      zedSettings = pkgs.writeText "settings.json" (builtins.toJSON {
        helix_mode = true;
        theme = "Noctalia Dark";
        load_direnv = "shell_hook";
        buffer_font_family = "Maple Mono NF";
        buffer_font_size = 14;
        ui_font_family = "Maple Mono NF";
        ui_font_size = 14;
        cursor_shape = "block";
        relative_line_numbers = true;
        auto_update = false;

        telemetry = {
          diagnostics = false;
          metrics = false;
        };

        vim = {
          use_system_clipboard = "always";
        };

        # Disable automatic downloading of package-version-server from GitHub
        language_servers = [
          "!package-version-server"
          "..."
        ];

        languages = {
          "C" = {
            format_on_save = "on";
            language_servers = [ "clangd" "..." ];
          };
          "C++" = {
            format_on_save = "on";
            language_servers = [ "clangd" "..." ];
          };
          "CMake" = {
            format_on_save = "on";
            language_servers = [ "cmake" "..." ];
          };
          "Nix" = {
            format_on_save = "on";
            formatter = {
              external = {
                command = "nixfmt";
              };
            };
            language_servers = [ "nixd" "..." ];
          };
          "Lua" = {
            format_on_save = "on";
            formatter = {
              external = {
                command = "stylua";
                arguments = [ "--stdin-filepath" "{buffer_path}" "-" ];
              };
            };
            language_servers = [ "lua-language-server" "..." ];
          };
          "TOML" = {
            format_on_save = "on";
            language_servers = [ "taplo" "..." ];
          };
          "Markdown" = {
            format_on_save = "on";
            language_servers = [ "marksman" "..." ];
          };
          "JSON" = {
            language_servers = [ "!package-version-server" "..." ];
          };
          "JSONC" = {
            language_servers = [ "!package-version-server" "..." ];
          };
        };

        lsp = {
          clangd = {
            binary = { path_lookup = true; };
            initialization_options = {
              fallbackFlags = [ "-std=c++20" ];
            };
          };
          cmake = {
            binary = { path_lookup = true; };
          };
          nixd = {
            binary = { path_lookup = true; };
          };
          lua-language-server = {
            binary = { path_lookup = true; };
          };
          taplo = {
            binary = { path_lookup = true; };
          };
          marksman = {
            binary = { path_lookup = true; };
          };
        };
      });

      wrappedZed = pkgs.symlinkJoin {
        name = "zed-editor";
        paths = [ pkgs.zed-editor ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zeditor \
            --prefix PATH : ${lib.makeBinPath zedRuntimeDeps} \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}" \
            --run '
              ZED_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/zed"
              mkdir -p "$ZED_DIR"
              cp -f "${zedSettings}" "$ZED_DIR/settings.json"
              chmod u+w "$ZED_DIR/settings.json"
            '

          [ -e $out/bin/zed ] || ln -sf $out/bin/zeditor $out/bin/zed
          [ -e $out/bin/zed-editor ] || ln -sf $out/bin/zeditor $out/bin/zed-editor
        '';
      };
    in
    {
      packages.zed-editor = wrappedZed;
      packages.zed = wrappedZed;

      apps.zed-editor = {
        type = "app";
        program = "${wrappedZed}/bin/zed";
        meta.description = "Hermetically wrapped Zed editor with toolchains for C++, CMake, Nix, Lua, TOML, and Markdown";
      };
      apps.zed = {
        type = "app";
        program = "${wrappedZed}/bin/zed";
        meta.description = "Hermetically wrapped Zed editor with toolchains for C++, CMake, Nix, Lua, TOML, and Markdown";
      };
    };
}