{config, ...}: {
  flake.modules.nixos."git" = {pkgs, ...}: {
    environment.systemPackages = [pkgs.git];
    home-manager.sharedModules = [config.flake.modules.homeManager."git"];
  };
  flake.modules.homeManager."git" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    git = config.workstation.git;
  in {
    programs.gpg.enable = true;

    # keyboxd deadlocks here (duplicate daemon + pubring.db.lock). Use pubring.kbx instead.
    home.file."${config.programs.gpg.homedir}/common.conf".text = ''
      # Managed by home-manager — intentionally no use-keyboxd.
    '';

    services.gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      pinentry.package = pkgs.pinentry-curses;
      defaultCacheTtl = 3600;
    };

    programs.git = {
      enable = true;
      signing = lib.mkIf (git.signingKey != null) {
        key = git.signingKey;
        signByDefault = true;
      };
      settings = {
        user.name = git.name;
        user.email = git.email;
        gpg.format = "openpgp";
        init.defaultBranch = "main";
        pull.rebase = false;
        credential = {
          "https://github.com".helper = "!gh auth git-credential";
          "https://gist.github.com".helper = "!gh auth git-credential";
        };
        safe.directory = ["/etc/nixos"];
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          line-numbers = true;
          side-by-side = false;
        };
        merge.conflictstyle = "zdiff3";
        diff = {
          colorMoved = "default";
          algorithm = "histogram";
        };
        push.autoSetupRemote = true;
        fetch.prune = true;
        rerere.enabled = true;
        rebase = {
          autoStash = true;
          autoSquash = true;
        };
        commit.verbose = true;
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
        column.ui = "auto";
        help.autocorrect = "prompt";
        # Syntax-aware diff on demand: git dft.
        alias.dft = "-c diff.external=difft diff";
      };
    };
    home.packages = [pkgs.gh pkgs.delta pkgs.difftastic];
  };
}
