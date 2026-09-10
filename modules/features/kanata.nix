{ self, lib, ... }:

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

            (defalias
              cap (tap-hold 200 200 esc esc)
              a (tap-hold 200 200 a lalt)
              s (tap-hold 200 200 s lctl)
              d (tap-hold 200 200 d lmet)
              f (tap-hold 200 200 f lsft)
              j (tap-hold 120 120 j rsft)
              k (tap-hold 120 120 k rmet)
              l (tap-hold 200 200 l rctl)
              scln (tap-hold 200 200 ; ralt)
            )

            (deflayer base
              @cap @a @s @d @f @j @k @l @scln _ _ _ _ _ _ _ _ _ _ _
            )

            (defchordsv2
              (a z) C-S-z 35 all-released ()
              (z x) C-z   35 all-released ()
              (x c) C-ins 35 all-released ()
              (c v) S-ins 35 all-released ()
              (x v) S-del 35 all-released ()
              (z v) C-a   35 all-released ()
              (u i) C-bspc 35 all-released ()
              (i o) C-del  35 all-released ()
              (n m) tab   35 all-released ()
              (m ,) C-pgup 35 all-released ()
              (, .) C-pgdn 35 all-released ()
            )
          '';
        };
      };
    };
  };
in
{
  flake.nixosModules.kanata = kanataModule;
  flake.nixosModules.castorConfiguration = kanataModule;
}