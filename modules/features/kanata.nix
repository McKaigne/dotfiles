{ lib, ... }:
let
  kanataModule = { config, ... }: {
    options.hardware.kanata = {
      keyboardDevice = lib.mkOption {
        type = lib.types.str;
        default = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        description = "Input event device path for Kanata keyboard interception";
      };
    };

    config = {
      services.kanata = {
        enable = true;
        keyboards.default = {
          devices = [ config.hardware.kanata.keyboardDevice ];
          extraDefCfg = ''
            process-unmapped-keys yes
            concurrent-tap-hold yes
          '';
          config = ''
            (defsrc
              caps a s d f j k l ; u i o z x c v n m , .
            )

            ;; Right-hand key list (triggers left-hand modifiers)
            (defvar
              right-hand-keys (
                y u i o p
                h j k l ; '
                n m , . /
                ret bspc del
                up down left right
                pgup pgdn home end
              )
              left-hand-keys (
                q w e r t
                a s d f g
                z x c v b
                tab esc
              )
            )

            ;; Bilateral tap-hold-release-keys:
            ;; Left-hand modifiers ONLY activate when pressing a right-hand key.
            ;; Right-hand modifiers ONLY activate when pressing a left-hand key.
            ;; Same-hand rolls (like typing "as" or "fa") output plain letters!
            (defalias
              cap  (tap-hold 200 200 esc esc)
              a    (tap-hold-release-keys 200 200 a lalt $right-hand-keys)
              s    (tap-hold-release-keys 200 200 s lctl $right-hand-keys)
              d    (tap-hold-release-keys 200 200 d lmet $right-hand-keys)
              f    (tap-hold-release-keys 200 200 f lsft $right-hand-keys)

              j    (tap-hold-release-keys 200 200 j rsft $left-hand-keys)
              k    (tap-hold-release-keys 200 200 k rmet $left-hand-keys)
              l    (tap-hold-release-keys 200 200 l rctl $left-hand-keys)
              scln (tap-hold-release-keys 200 200 ; ralt $left-hand-keys)
            )

            (deflayer base
              @cap @a @s @d @f @j @k @l @scln _ _ _ _ _ _ _ _ _ _ _
            )

            ;; Chords tightened to 20ms to prevent accidental roll triggers
            (defchordsv2
              (a z) C-S-z 20 all-released ()
              (z x) C-z   20 all-released ()
              (x c) C-ins 20 all-released ()
              (c v) S-ins 20 all-released ()
              (x v) S-del 20 all-released ()
              (z v) C-a   20 all-released ()
              (u i) C-bspc 20 all-released ()
              (i o) C-del  20 all-released ()
              (n m) tab   20 all-released ()
              (m ,) C-pgup 20 all-released ()
              (, .) C-pgdn 20 all-released ()
            )
          '';
        };
      };
    };
  };
in
{
  flake.nixosModules.kanata = kanataModule;
}