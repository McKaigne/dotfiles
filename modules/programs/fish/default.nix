{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.fish =
    { config, pkgs, ... }:
    {
      home-manager.sharedModules = [ flakeConfig.flake.modules.homeManager.fish ];
      programs.fish.enable = true;
      users.users.${config.workstation.username}.shell = pkgs.fish;
    };

  flake.modules.homeManager.fish =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      isFlag = cmd: lib.hasPrefix "-" cmd;
      safeAbbrs = lib.filterAttrs (_: cmd: !isFlag cmd) config.workstation.shellAbbrs;
      tideVarsRaw = builtins.readFile ./data/fish_variables;
      tideVarsHash = builtins.hashString "sha256" (tideVarsRaw + ":v6-tide-clean");

      setuvarLines = lib.filter (l: lib.hasPrefix "SETUVAR " l) (
        lib.splitString "\n" tideVarsRaw
      );

      splitSetuvar =
        line:
        let
          rest = lib.removePrefix "SETUVAR " line;
          parts = lib.splitString ":" rest;
          name = builtins.head parts;
          value = lib.concatStringsSep ":" (lib.drop 1 parts);
        in
        {
          inherit name value;
        };

      skipVars = [
        "_tide_left_items"
        "_tide_right_items"
      ];

      listVars = [
        "tide_left_prompt_items"
        "tide_right_prompt_items"
        "tide_docker_default_contexts"
        "tide_pwd_markers"
      ];

      fishSingleQuote = s: "'${lib.replaceStrings [ "'" ] [ "'\\''" ] s}'";

      setUniversalVar =
        item:
        if builtins.elem item.name skipVars then
          ""
        else if builtins.elem item.name listVars then
          "set -U ${item.name} (string split \\x1e -- (printf '%b' ${fishSingleQuote item.value}))"
        else if lib.hasInfix "\\" item.value then
          "set -U ${item.name} (printf '%b' ${fishSingleQuote item.value})"
        else
          "set -U ${item.name} ${fishSingleQuote item.value}";

      tideVarInit = lib.concatStringsSep "\n" (
        lib.filter (s: s != "") (map setUniversalVar (map splitSetuvar setuvarLines))
      );
    in
    {
      programs.fish = {
        enable = true;
        shellAbbrs = safeAbbrs;
        plugins = [
          {
            name = "tide";
            src = pkgs.fishPlugins.tide.src;
          }
        ];

        interactiveShellInit = (builtins.readFile ./data/config.fish) + ''

          abbr --add ntrace --position anywhere -- --show-trace

          if status is-interactive; and test "$__nixos_tide_vars_hash" != "${tideVarsHash}"
            set -U __nixos_tide_vars_hash ${tideVarsHash}
            ${tideVarInit}
          end
        '';

        functions = {
          fish_user_key_bindings.body = builtins.readFile ./data/fish_user_key_bindings.fish;

          fkill = {
            description = "Interactively select and kill a process";
            body = ''
              set -l selected (ps -eo pid,user,comm,%cpu,%mem | ${pkgs.fzf}/bin/fzf --header="Select process to kill (ESC to cancel)")
              if test -n "$selected"
                set -l targetPid (echo "$selected" | ${pkgs.gawk}/bin/awk '{print $1}')
                kill -9 "$targetPid"; and echo "Killed process $targetPid"
              end
            '';
          };

          clast = {
            description = "Re-run last command and copy its output to clipboard";
            body = ''
              set -l cmd (history --max 1)
              if test -n "$cmd"
                eval "$cmd" | ${pkgs.wl-clipboard}/bin/wl-copy
                and echo "Copied output of '$cmd' to clipboard."
              end
            '';
          };

          chist = {
            description = "Interactively select a historical command and copy its output";
            body = ''
              set -l cmd (history | ${pkgs.fzf}/bin/fzf --reverse --header="Select command to copy output to clipboard:")
              if test -n "$cmd"
                eval "$cmd" | ${pkgs.wl-clipboard}/bin/wl-copy
                and echo "Copied output of '$cmd' to clipboard."
              end
            '';
          };
        };
      };

      home.activation.removeManagedFishVariables =
        lib.hm.dag.entryAfter [ "writeBoundary" ]
          ''
            fish_vars="${config.home.homeDirectory}/.config/fish/fish_variables"
            if [ -L "$fish_vars" ] && readlink "$fish_vars" | grep -q '^/nix/store/'; then
              $DRY_RUN_CMD rm -f "$fish_vars"
            fi
          '';
    };
}
