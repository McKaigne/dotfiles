
{ self, inputs, ... }: {
  flake.nixosModules.kanata = { pkgs, ... }: {
    hardware.uinput.enable = true;
    users.groups.uinput.members = [ "pollux" ];
    users.groups.input.members = [ "pollux" ];

    services.kanata = {
      enable = true;
      keyboards.internal = {
        extraDefCfg = ''
          process-unmapped-keys yes
          concurrent-tap-hold yes
        '';

        config = ''
          (defsrc
            caps
            u    i    o
            a    s    d    f    j    k    l    ;
            z    x    c    v    m    ,    .    /
          )

          ;; Timing: 200ms hold time for Home Row Mods, 35ms combo window
          (defvar
            tap-time 200
            hold-time 200
            combo-time 35
          )

          (defalias
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

          (deflayer base
            esc
            u    i    o
            @a-mod @s-mod @d-mod @f-mod @j-mod @k-mod @l-mod @scl-mod
            z    x    c    v    m    ,    .    /
          )

          ;; Combos
          (defchordsv2
            (a z) C-S-z  $combo-time first-release ()  ;; Redo
            (z x) C-z    $combo-time first-release ()  ;; Undo
            (x c) C-c    $combo-time first-release ()  ;; Copy
            (c v) C-v    $combo-time first-release ()  ;; Paste
            (x v) C-x    $combo-time first-release ()  ;; Cut
            (z v) C-a    $combo-time first-release ()  ;; Select All

            (u i) bspc   $combo-time first-release ()  ;; Backspace
            (i o) del    $combo-time first-release ()  ;; Delete
            (m ,) tab    $combo-time first-release ()  ;; Tab
            (, .) C-pgup $combo-time first-release ()  ;; Tab Left
            (. /) C-pgdn $combo-time first-release ()  ;; Tab Right
          )
        '';
      };
    };
  };
}
