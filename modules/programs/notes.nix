# Helix as the note-taking editor: a Markdown vault in ~/Areas/Notes (synced
# to castor by Syncthing), markdown-oxide for [[wiki links]], backlinks (gr),
# #tags and renames that update links, harper for grammar and spelling, and a
# Space+n menu in Helix. Super+Shift+N or `notes` opens today's note.
{
  flake.modules.homeManager.helix = {
    config,
    lib,
    pkgs,
    ...
  }: let
    vault = "${config.home.homeDirectory}/Areas/Notes";

    # Prints today's (or an offset day's) journal path, creating it from a
    # heading the first time.
    noteDay = pkgs.writeShellApplication {
      name = "note-day";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        day="''${1:-today}"
        file=${lib.escapeShellArg vault}/journal/$(date -d "$day" +%F).md
        if [ ! -e "$file" ]; then
          mkdir -p "$(dirname "$file")"
          printf '# %s\n\n' "$(date -d "$day" '+%A, %d %B %Y')" > "$file"
        fi
        printf '%s\n' "$file"
      '';
    };

    # Today's note in Helix, with the vault as the working directory so the
    # note pickers and markdown-oxide see every note.
    notes = pkgs.writeShellApplication {
      name = "notes";
      runtimeInputs = [noteDay];
      text = ''
        cd ${lib.escapeShellArg vault}
        exec hx "$(note-day)"
      '';
    };
  in {
    home.packages = [noteDay notes];

    programs.helix = {
      extraPackages = [pkgs.markdown-oxide pkgs.harper];
      languages = {
        language-server.harper-ls = {
          command = "harper-ls";
          args = ["--stdio"];
        };
        language = [
          {
            name = "markdown";
            language-servers = ["markdown-oxide" "harper-ls"];
            soft-wrap.enable = true;
          }
        ];
      };
      settings.keys.normal.space.n = {
        d = ":open %sh{note-day}";
        y = ":open %sh{note-day yesterday}";
        n = [":cd ${vault}" "file_picker"];
        s = [":cd ${vault}" "global_search"];
        i = ":open ${vault}/inbox.md";
        t = ":open ${vault}/tasks.md";
        # Rendered preview in a floating zellij pane (inside zellij only).
        p = ":sh zellij run --floating --close-on-exit --cwd %sh{pwd} -- glow -p %{buffer_name}";
      };
    };

    home.activation.seedNotes = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        mkdir -p ${lib.escapeShellArg "${vault}/journal"}
        for f in Inbox Tasks; do
          file=${lib.escapeShellArg vault}/''${f,,}.md
          [ -e "$file" ] || printf '# %s\n\n' "$f" > "$file"
        done
      fi
    '';
  };
}
