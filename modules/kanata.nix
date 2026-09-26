
{ lib, ... }:
let
  kanataModule = { config, ... }: {
    options.hardware.kanata = {
      internalKeyboard = lib.mkOption {
        type = lib.types.str;
        default = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        description = "Input event device path for internal laptop keyboard";
      };
      bluetoothKeyboard = lib.mkOption {
        type = lib.types.str;
        default = "/dev/input/by-id/lofree-flow84";
        description = "Input event device path for Bluetooth keyboard";
      };
    };

    config = {
      services.kanata = {
        enable = true;
        keyboards.default = {
          devices = [
            config.hardware.kanata.internalKeyboard
            config.hardware.kanata.bluetoothKeyboard
          ];
          extraDefCfg = ''
            process-unmapped-keys yes
            concurrent-tap-hold yes
            tap-hold-require-prior-idle 80
            chords-v2-min-idle 100
          '';
          config = ''
            (defsrc
              esc  1 2 3 4 5 6 7 8 9 0 - = bspc
              tab  q w e r t y u i o p [ ] \
              caps a s d f g h j k l ; ' ret
              lsft z x c v b n m , . / rsft
              lmet lalt       spc       ralt rctl
            )

            (defvar
              left-typing-keys (
                esc  1 2 3 4 5
                tab  q w e r t
                     g
                lsft z x c v b
                lmet lalt spc
              )
              right-typing-keys (
                6 7 8 9 0 - = bspc
                y u i o p [ ] \
                h             ' ret
                n m , . / rsft
                ralt rctl spc
              )
            )

            (defalias
              spc_nav (tap-hold-release 200 200 spc (layer-while-held nav))
              a      (tap-hold-except-keys 200 200 a lalt $left-typing-keys)
              scln   (tap-hold-except-keys 200 200 ; ralt $right-typing-keys)
              s      (tap-hold-except-keys 180 180 s lctl $left-typing-keys)
              l      (tap-hold-except-keys 180 180 l rctl $right-typing-keys)
              d      (tap-hold-except-keys 160 160 d lmet $left-typing-keys)
              k      (tap-hold-except-keys 160 160 k rmet $right-typing-keys)
              f      (tap-hold-except-keys 130 130 f lsft $left-typing-keys)
              j      (tap-hold-except-keys 130 130 j rsft $right-typing-keys)

              tog_raw (switch
                ((base-layer raw)) (layer-switch base) break
                () (layer-switch raw) break
              )
            )

            (deflayer base
              esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
              tab    q      w      e      r      t y u      i      o      p      [      ]    \
              esc    @a     @s     @d     @f     g h @j     @k     @l     @scln  '      ret
              lsft   z      x      c      v      b n m      ,      .      /      rsft
              lmet   lalt                 @spc_nav          ralt   rctl
            )

            (deflayer nav
              _      _      _      _      _      _ _      _    _    _    _      _      _    _
              _      _      _      _      _      _ C-S-z  C-v  C-c  C-x  C-z    _      _    _
              _      _      _      _      _      _ left   down up   rght _      _      _
              _      _      _      _      _      _ home   pgdn pgup end  _      _
              _      _                    _                    _    _
            )

            (deflayer raw
              esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
              tab    q      w      e      r      t y u      i      o      p      [      ]    \
              caps   a      s      d      f      g h j      k      l      ;      '      ret
              lsft   z      x      c      v      b n m      ,      .      /      rsft
              lmet   lalt                 spc               ralt   rctl
            )

            (defchordsv2
              (lsft rsft) @tog_raw  50 all-released ()
              (a z)       C-S-z     50 all-released ()
              (z x)       C-z       50 all-released ()
              (x c)       C-ins     50 all-released ()
              (c v)       S-ins     50 all-released ()
              (x v)       S-del     50 all-released ()
              (z v)       C-a       50 all-released ()
              (n m)       C-b       50 all-released ()
              (m ,)       C-bspc    50 all-released ()
              (, .)       C-del     50 all-released ()
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
