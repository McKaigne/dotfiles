{ ... }:
let
  kanataModule = { config, lib, ... }: {
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
            tap-hold-require-prior-idle 120
            chords-v2-min-idle 100
          '';
          config = ''
            ;; =========================================================================
            ;; Kanata Timeless Home Row Mods Configuration
            ;; Architecture: urob's balanced flavor, positional hold-tap,
            ;; hold-trigger-on-release, global quick-tap idle, and 20ms combos.
            ;; =========================================================================

            (defsrc
              esc  1 2 3 4 5 6 7 8 9 0 - = bspc
              tab  q w e r t y u i o p [ ] \
              caps a s d f g h j k l scln ' ret
              lsft z x c v b n m , . / rsft
              lmet lalt       spc       ralt rctl
            )

            (defvar
              tap-repress 175
              hold-time   200

              left-nonhome (
                esc  1 2 3 4 5
                tab  q w e r t
                     g
                lsft z x c v b
                lmet lalt spc
              )
              left-home-a (s d f)
              left-home-s (a d f)
              left-home-d (a s f)
              left-home-f (a s d)

              right-nonhome (
                6 7 8 9 0 - = bspc
                y u i o p [ ] \
                h             ' ret
                n m , . / rsft
                ralt rctl spc
              )
              right-home-j (k l scln)
              right-home-k (j l scln)
              right-home-l (j k scln)
              right-home-scln (j k l)
            )

            (defalias
              spc_nav (tap-hold-release 200 200 spc (layer-while-held nav))

              ;; Left Hand Modifiers (Alt, Ctrl, Super, Shift)
              a    (tap-hold-release-tap-keys-release $tap-repress $hold-time a lalt $left-nonhome $left-home-a)
              s    (tap-hold-release-tap-keys-release $tap-repress $hold-time s lctl $left-nonhome $left-home-s)
              d    (tap-hold-release-tap-keys-release $tap-repress $hold-time d lmet $left-nonhome $left-home-d)
              f    (tap-hold-release-tap-keys-release $tap-repress $hold-time f lsft $left-nonhome $left-home-f)

              ;; Right Hand Modifiers (Shift, Super, Ctrl, Alt)
              j    (tap-hold-release-tap-keys-release $tap-repress $hold-time j rsft $right-nonhome $right-home-j)
              k    (tap-hold-release-tap-keys-release $tap-repress $hold-time k rmet $right-nonhome $right-home-k)
              l    (tap-hold-release-tap-keys-release $tap-repress $hold-time l rctl $right-nonhome $right-home-l)
              scln (tap-hold-release-tap-keys-release $tap-repress $hold-time scln ralt $right-nonhome $right-home-scln)

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
              caps   a      s      d      f      g h j      k      l      scln   '      ret
              lsft   z      x      c      v      b n m      ,      .      /      rsft
              lmet   lalt                 spc               ralt   rctl
            )

            (defchordsv2
              (lsft rsft) @tog_raw  20 all-released ()
              (a z)       C-S-z     20 all-released ()
              (z x)       C-z       20 all-released ()
              (x c)       C-ins     20 all-released ()
              (c v)       S-ins     20 all-released ()
              (x v)       S-del     20 all-released ()
              (z v)       C-a       20 all-released ()
              (n m)       C-b       20 all-released ()
              (m ,)       C-bspc    20 all-released ()
              (, .)       C-del     20 all-released ()
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
