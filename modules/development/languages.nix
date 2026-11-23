# Languages: toolchains, language servers and formatters on the normal PATH,
# so Emacs and the shell use the same ones. Grouped by what
# they are for; per-project versions still come from each project's flake /
# devShell (direnv), which take precedence inside the project.
{
  flake.modules.homeManager.development = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Math: Python (with the usual numeric stack), Julia, Haskell.
      (python3.withPackages (ps:
        with ps; [
          numpy
          scipy
          sympy
          matplotlib
          ipython
          evdev # tools/evtest scripts
        ]))
      basedpyright
      ruff
      # Its language server is a Julia package, installed once per machine:
      #   julia -e 'using Pkg; Pkg.add(["LanguageServer", "SymbolServer"])'
      julia-bin
      ghc
      cabal-install
      haskell-language-server
      ormolu
      # Writing math up: Typst (LaTeX-like output, instant preview).
      typst
      tinymist
      typstyle

      # Systems: Rust (C/C++ toolchain is in cpp.nix), debugging, CMake.
      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer
      llvmPackages_23.lldb # lldb-dap: Emacs debugging
      neocmakelsp

      # Web: Go + htmx (templ templates), HTML/CSS/JSON, TypeScript, SQL.
      go
      gopls
      gofumpt
      golangci-lint
      templ
      htmx-lsp
      superhtml
      vscode-langservers-extracted
      vtsls
      prettier
      sqls
      sqlfluff

      # Android: Kotlin and Flutter (Dart ships with Flutter).
      kotlin
      kotlin-language-server
      ktfmt
      flutter

      # Config, shell and containers.
      nixd
      nixfmt
      bash-language-server
      shellcheck
      shfmt
      yaml-language-server
      taplo
      marksman
      just-lsp
      dockerfile-language-server
      docker-compose-language-service
      glsl_analyzer
    ];
  };
}
