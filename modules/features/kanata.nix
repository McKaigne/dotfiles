{ ... }:
let
  kanataModule = { ... }: {
    hardware.uinput.enable = true;

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
            n    z    x    c    v    m    ,    .    /
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
            j-mod (tap-hold-release $tap-time 120 j rsft)
            k-mod (tap-hold-release $tap-time 120 k rmet)
            l-mod (tap-hold-release $tap-time $hold-time l rctl)
            scl-mod (tap-hold-release $tap-time $hold-time ; ralt)
          )

          (deflayer base
            esc
            u    i    o
            @a-mod @s-mod @d-mod @f-mod @j-mod @k-mod @l-mod @scl-mod
            n    z    x    c    v    m    ,    .    /
          )

          ;; Combos (Path A: Universal IBM CUA Standard Clipboard Keys)
          (defchordsv2
            (a z) C-S-z  $combo-time first-release ()  ;; Redo
            (z x) C-z    $combo-time first-release ()  ;; Undo
            (x c) C-ins  $combo-time first-release ()  ;; Copy (Universal CUA: Ctrl+Insert)
            (c v) S-ins  $combo-time first-release ()  ;; Paste (Universal CUA: Shift+Insert)
            (x v) S-del  $combo-time first-release ()  ;; Cut (Universal CUA: Shift+Delete)
            (z v) C-a    $combo-time first-release ()  ;; Select All

            (u i) C-bspc $combo-time first-release ()  ;; Ctrl+Backspace (Delete Word Left)
            (i o) C-del  $combo-time first-release ()  ;; Ctrl+Delete (Delete Word Right)
            (n m) tab    $combo-time first-release ()  ;; Tab
            (m ,) C-pgup $combo-time first-release ()  ;; Tab Left
            (, .) C-pgdn $combo-time first-release ()  ;; Tab Right
          )
        '';
      };
    };
  };
in
{
  flake.nixosModules.kanata = kanataModule;
  flake.nixosModules.castorConfiguration = kanataModule;
}