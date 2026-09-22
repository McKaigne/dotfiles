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
            tap-hold-require-prior-idle 150
            chords-v2-min-idle 140
          '';
          config = ''
            ;; Complete 58-key physical keyboard matrix
            (defsrc
              esc  1 2 3 4 5 6 7 8 9 0 - = bspc
              tab  q w e r t y u i o p [ ] \
              caps a s d f g h j k l ; ' ret
              lsft z x c v b n m , . / rsft
              lmet lalt       spc       ralt rctl
            )

            ;; Non-modifier typing keys: Excludes HRM keys so modifiers can stack!
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

            ;; Aliases: Home Row Mods, Space-Held Navigation Layer, and Raw Gaming Toggle
            (defalias
              ;; Space-Held Nav Layer: Tap for Space, Hold for Navigation & Editing
              spc_nav (tap-hold-release 200 200 spc (layer-while-held nav))

              ;; Urob's Timeless Home Row Mods
              a      (tap-hold-except-keys 250 250 a lalt $left-typing-keys)
              s      (tap-hold-except-keys 250 250 s lctl $left-typing-keys)
              d      (tap-hold-except-keys 250 250 d lmet $left-typing-keys)
              f      (tap-hold-except-keys 220 220 f lsft $left-typing-keys)

              j      (tap-hold-except-keys 220 220 j rsft $right-typing-keys)
              k      (tap-hold-except-keys 250 250 k rmet $right-typing-keys)
              l      (tap-hold-except-keys 250 250 l rctl $right-typing-keys)
              scln   (tap-hold-except-keys 250 250 ; ralt $right-typing-keys)

              ;; Gaming / Raw Bypass Toggle
              tog_raw (switch
                ((base-layer raw)) (layer-switch base) break
                () (layer-switch raw) break
              )
            )

            ;; =========================================================================
            ;; LAYER 1: BASE (Space-Held Navigation Active via @spc_nav)
            ;; =========================================================================
            (deflayer base
              esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
              tab    q      w      e      r      t y u      i      o      p      [      ]    \
              esc    @a     @s     @d     @f     g h @j     @k     @l     @scln  '      ret
              lsft   z      x      c      v      b n m      ,      .      /      rsft
              lmet   lalt                 @spc_nav          ralt   rctl
            )

            ;; =========================================================================
            ;; LAYER 2: NAV (Activated while holding Spacebar)
            ;; =========================================================================
            (deflayer nav
              _      _      _      _      _      _ _      _    _    _    _      _      _    _
              _      _      _      _      _      _ C-S-z  C-v  C-c  C-x  C-z    _      _    _
              _      _      _      _      _      _ left   down up   rght _      _      _
              _      _      _      _      _      _ home   pgdn pgup end  _      _
              _      _                    _                    _    _
            )

            ;; =========================================================================
            ;; LAYER 3: RAW (Gaming / Typing Test Bypass: Pure Keys / Zero Tap-Holds)
            ;; =========================================================================
            (deflayer raw
              esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
              tab    q      w      e      r      t y u      i      o      p      [      ]    \
              caps   a      s      d      f      g h j      k      l      ;      '      ret
              lsft   z      x      c      v      b n m      ,      .      /      rsft
              lmet   lalt                 spc               ralt   rctl
            )

            ;; Universal Bigrams & Chords
            (defchordsv2
              ;; Gaming / Raw Bypass Toggle (Press both Shift keys simultaneously)
              (lsft rsft) @tog_raw  50 all-released ()

              ;; Clipboard & Undo (Left Hand Bottom Row)
              (a z) C-S-z           15 all-released ()
              (z x) C-z             15 all-released ()
              (x c) C-ins           15 all-released ()
              (c v) S-ins           15 all-released ()
              (x v) S-del           15 all-released ()
              (z v) C-a             15 all-released ()

              ;; Word Editing & Tmux (Right Hand Bottom Row)
              (n m) C-b             15 all-released ()
              (m ,) C-bspc          15 all-released ()
              (, .) C-del           15 all-released ()
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