{ lib, ... }:
let
  kanataModule = { config, ... }: {
    options.hardware.kanata = {
      keyboardDevice = lib.mkOption {
        type = lib.types.str;
        default = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        description = "Input event device path for Kanata keyboard interception (laptop internal keyboard only)";
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
            tap-hold-require-prior-idle 150
            chords-v2-min-idle 100
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

            ;; Full physical hand partitions for strict Chordal Hold (Opposite-Hand Rule)
            (defvar
              left-hand-keys (
                esc  1 2 3 4 5
                tab  q w e r t
                caps a s d f g
                lsft z x c v b
                lmet lalt
              )
              right-hand-keys (
                6 7 8 9 0 - = bspc
                y u i o p [ ] \
                h j k l ; ' ret
                n m , . / rsft
                ralt rctl
              )
            )

            ;; Miryoku Layer Switch Aliases & Contralateral Home Row Mods
            (defalias
              ;; Layer switches (Permissive Hold: activates target layer on press + release of any layer key)
              ml_fun (tap-hold-release 200 200 lmet (layer-while-held fun))
              ml_nav (tap-hold-release 200 200 lalt (layer-while-held nav))
              mr_num (tap-hold-release 200 200 ralt (layer-while-held num))
              mr_sym (tap-hold-release 200 200 rctl (layer-while-held sym))

              ;; Home Row Mods (Alt - Ctrl - Mod - Shift)
              ;; Combines Permissive Hold (-release) + Chordal Hold (-keys with same-hand exclusion)
              ;; Outer fingers: 180ms | Index fingers: 140ms
              a      (tap-hold-release-keys 180 180 a lalt $left-hand-keys)
              s      (tap-hold-release-keys 180 180 s lctl $left-hand-keys)
              d      (tap-hold-release-keys 180 180 d lmet $left-hand-keys)
              f      (tap-hold-release-keys 140 140 f lsft $left-hand-keys (require-prior-idle 0))

              j      (tap-hold-release-keys 140 140 j rsft $right-hand-keys (require-prior-idle 0))
              k      (tap-hold-release-keys 180 180 k rmet $right-hand-keys)
              l      (tap-hold-release-keys 180 180 l rctl $right-hand-keys)
              scln   (tap-hold-release-keys 180 180 ; ralt $right-hand-keys)
            )

            ;; =========================================================================
            ;; LAYER 1: BASE
            ;; =========================================================================
            (deflayer base
              esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
              tab    q      w      e      r      t y u      i      o      p      [      ]    \
              esc    @a     @s     @d     @f     g h @j     @k     @l     @scln  '      ret
              lsft   z      x      c      v      b n m      ,      .      /      rsft
              @ml_fun @ml_nav             spc               @mr_num @mr_sym
            )

            ;; =========================================================================
            ;; LAYER 2: NAV (Hold Left Alt)
            ;; =========================================================================
            (deflayer nav
              _      _      _      _      _      _ _ _      _      _      _      _      _    _
              _      _      _      _      _      _ _ home   pgdn   pgup   end    _      _    _
              _      C-a    _      _      _      _ left down up    rght   _      _      ret
              _      C-z    C-x    C-c    C-v    _ bspc del  C-bspc C-del  _      _
              _      _                    _                 _      _
            )

            ;; =========================================================================
            ;; LAYER 3: NUM (Hold Right AltGr)
            ;; =========================================================================
            (deflayer num
              _      _      _      _      _      _ _ _      _      _      _      _      _    _
              _      [      7      8      9      ] _ S-=    -      S-8    /      S-6    _    _
              _      ;      4      5      6      = _ 0      .      ,      ret    _      _
              _      grv    1      2      3      \ _ _      _      _      _      _
              _      _                    0                 _      _
            )

            ;; =========================================================================
            ;; LAYER 4: SYM (Hold Right Ctrl)
            ;; =========================================================================
            (deflayer sym
              _      _      _      _      _      _ _ _      _      _      _      _      _    _
              _      S-[    S-7    S-8    S-9    S-] _ S--  -      S-8    /      S-6    _    _
              _      S-;    S-4    S-5    S-6    S-= _ S-'  '      S-,    S-.    S-/    _
              _      S-grv  S-1    S-2    S-3    S-\ _ [    ]      S-[    S-]    _
              _      _                    _                 _      _
            )

            ;; =========================================================================
            ;; LAYER 5: FUN / MEDIA (Hold Left Win)
            ;; =========================================================================
            (deflayer fun
              _      f1     f2     f3     f4     f5 f6 f7     f8     f9     f10    f11    f12  _
              _      _      _      _      _      _  _  _      _      _      _      _      _    _
              _      _      _      _      _      _  prev voldwn volu   next   _      _    _
              _      _      _      _      _      _  mute pp     _      _      _      _
              _      _                    _                 _      _
            )

            ;; =========================================================================
            ;; BILATERAL OVERRIDES: Enforces contralateral modifier usage
            ;; =========================================================================
            (defoverrides
              (lsft a) (a)
              (lsft s) (s)
              (lsft d) (d)
              (lsft f) (f)
              (lsft g) (g)
              (lsft q) (q)
              (lsft w) (w)
              (lsft e) (e)
              (lsft r) (r)
              (lsft t) (t)
              (lsft z) (z)
              (lsft x) (x)
              (lsft c) (c)
              (lsft v) (v)
              (lsft b) (b)

              (rsft y) (y)
              (rsft u) (u)
              (rsft i) (i)
              (rsft o) (o)
              (rsft p) (p)
              (rsft h) (h)
              (rsft j) (j)
              (rsft k) (k)
              (rsft l) (l)
              (rsft ;) (;)
              (rsft n) (n)
              (rsft m) (m)
            )

            ;; Universal Bigrams & Chords (15ms timer)
            (defchordsv2
              (u i) bspc  15 all-released (nav num sym fun)
              (i o) del   15 all-released (nav num sym fun)
              (a z) C-S-z 15 all-released (nav num sym fun)
              (z x) C-z   15 all-released (nav num sym fun)
              (x c) C-ins 15 all-released (nav num sym fun)
              (c v) S-ins 15 all-released (nav num sym fun)
              (x v) S-del 15 all-released (nav num sym fun)
              (z v) C-a   15 all-released (nav num sym fun)
              (n m) tab   15 all-released (nav num sym fun)
              (m ,) C-pgup 15 all-released (nav num sym fun)
              (, .) C-pgdn 15 all-released (nav num sym fun)
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