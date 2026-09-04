
{ self, inputs, ... }: {
  flake.nixosModules.kanata = { pkgs, ... }: {
    # Enable uinput permissions for virtual input injection
    hardware.uinput.enable = true;
    users.groups.uinput.members = [ "pollux" ];
    users.groups.input.members = [ "pollux" ];

    services.kanata = {
      enable = true;
      keyboards.internal = {
        # Extra configuration options injected into NixOS's generated defcfg
        extraDefCfg = ''
          process-unmapped-keys yes
          concurrent-tap-hold yes
        '';

        config = ''
          ;; Physical source keys intercepted by Kanata
          (defsrc
            caps
            u    i    o
            a    s    d    f    j    k    l    ;
            z    x    c    v    m    ,    .    /
          )

          ;; 150ms timing for Home Row Mods
          (defvar
            tap-time 150
            hold-time 150
          )

          ;; Home Row Mod & Dual-Function Aliases
          (defalias
            cap (tap-hold $tap-time $hold-time esc lctl)

            ;; Left Hand: A (Alt), S (Ctrl), D (GUI/Super), F (Shift)
            a-mod (tap-hold-release $tap-time $hold-time a lalt)
            s-mod (tap-hold-release $tap-time $hold-time s lctl)
            d-mod (tap-hold-release $tap-time $hold-time d lmet)
            f-mod (tap-hold-release $tap-time $hold-time f lsft)

            ;; Right Hand: J (Shift), K (GUI/Super), L (Ctrl), ; (Alt)
            j-mod (tap-hold-release $tap-time $hold-time j rsft)
            k-mod (tap-hold-release $tap-time $hold-time k rmet)
            l-mod (tap-hold-release $tap-time $hold-time l rctl)
            scl-mod (tap-hold-release $tap-time $hold-time ; ralt)
          )

          ;; Base Layer Mapping
          (deflayer base
            @cap
            u    i    o
            @a-mod @s-mod @d-mod @f-mod @j-mod @k-mod @l-mod @scl-mod
            z    x    c    v    m    ,    .    /
          )

          ;; Combos (50ms simultaneous press window)
          (defchords mychords 50
            ;; Clipboard & History
            (a z) C-S-z  ;; Redo
            (z x) C-z    ;; Undo
            (x c) C-c    ;; Copy
            (c v) C-v    ;; Paste
            (x v) C-x    ;; Cut
            (z v) C-a    ;; Select All

            ;; Navigation & Editing
            (u i) bspc   ;; Backspace
            (i o) del    ;; Delete
            (m ,) tab    ;; Tab
            (, .) C-pgup ;; Tab Left (Previous Browser Tab)
            (. /) C-pgdn ;; Tab Right (Next Browser Tab)
          )
        '';
      };
    };
  };
}
