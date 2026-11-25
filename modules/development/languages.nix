# Languages: toolchains, language servers and formatters on the normal PATH,
# so Emacs and the shell use the same ones. Grouped by what
# they are for; per-project versions still come from each project's flake /
# devShell (direnv), which take precedence inside the project.
{
  flake.modules.homeManager.development = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Python, with the usual numeric stack.
      (python3.withPackages (ps:
        with ps; [
          numpy
          scipy
          sympy
          matplotlib
          ipython
          evdev # input-device scripts, alongside evtest (tools.nix)
        ]))
      basedpyright
      ruff

      # Systems: Rust (C/C++ toolchain is in cpp.nix), debugging, CMake.
      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer
      llvmPackages_23.lldb
      neocmakelsp

      # Web: Go + htmx (templ templates).
      go
      gopls
      gofumpt
      golangci-lint
      templ
      htmx-lsp
      prettier

      # Config and shell.
      nixd
      nixfmt
      bash-language-server
      shellcheck
      shfmt
      yaml-language-server
      taplo
      marksman
    ];
  };
}
