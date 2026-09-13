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

            ;; Hand letters only (bspc and ret excluded so Ctrl+Bspc/Enter work on both hands)
            (defvar
              left-letters (
                q w e r t
                a s d f g
                z x c v b
              )
              right-letters (
                y u i o p
                h j k l ;
                n m , . /
              )
            )

            ;; Miryoku Layer Switch Aliases & Home Row Mods
            (defalias
              ;; Layer switches: Left Alt is NAV, Left Win is FUN, Right AltGr is NUM, Right Ctrl is SYM
              ml_fun (tap-hold 200 200 lmet (layer-while-held fun))
              ml_nav (tap-hold 200 200 lalt (layer-while-held nav))
              mr_num (tap-hold 200 200 ralt (layer-while-held num))
              mr_sym (tap-hold 200 200 rctl (layer-while-held sym))

              ;; Home Row Mods: Alt - Ctrl - GUI - Shift
              a      (tap-hold-release-keys 200 200 a lalt $left-letters)
              s      (tap-hold-release-keys 200 200 s lctl $left-letters)
              d      (tap-hold-release-keys 200 200 d lmet $left-letters)
              f      (tap-hold-release-keys 160 160 f lsft $left-letters (require-prior-idle 0))

              j      (tap-hold-release-keys 160 160 j rsft $right-letters (require-prior-idle 0))
              k      (tap-hold-release-keys 200 200 k rmet $right-letters)
              l      (tap-hold-release-keys 200 200 l rctl $right-letters)
              scln   (tap-hold-release-keys 200 200 ; ralt $right-letters)
            )

            ;; =========================================================================
            ;; LAYER 1: BASE (Left Alt = Nav, Left Win = Fun, Right AltGr = Num, Right Ctrl = Sym)
            ;; =========================================================================
            (deflayer base
              esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
              tab    q      w      e      r      t y u      i      o      p      [      ]    \
              esc    @a     @s     @d     @f     g h @j     @k     @l     @scln  '      ret
              lsft   z      x      c      v      b n m      ,      .      /      rsft
              @ml_fun @ml_nav             spc               @mr_num @mr_sym
            )

            ;; =========================================================================
            ;; LAYER 2: NAV (Hold Left Alt / lalt)
            ;; Left hand: Clipboard | Right hand: Vim Navigation, Arrows & Del
            ;; =========================================================================
            (deflayer nav
              _      _      _      _      _      _ _ _      _      _      _      _      _    _
              _      _      _      _      _      _ _ home   pgdn   pgup   end    _      _    _
              _      C-a    _      _      _      _ left down up    rght   _      _      ret
              _      C-z    C-x    C-c    C-v    _ bspc del  C-bspc C-del  _      _
              _      _                    _                 _      _
            )

            ;; =========================================================================
            ;; LAYER 3: NUM (Hold Right AltGr / ralt)
            ;; Left hand: Numpad | Right hand: Operators
            ;; =========================================================================
            (deflayer num
              _      _      _      _      _      _ _ _      _      _      _      _      _    _
              _      [      7      8      9      ] _ S-=    -      S-8    /      S-6    _    _
              _      ;      4      5      6      = _ 0      .      ,      ret    _      _
              _      grv    1      2      3      \ _ _      _      _      _      _
              _      _                    0                 _      _
            )

            ;; =========================================================================
            ;; LAYER 4: SYM (Hold Right Ctrl / rctl) - Valid Unshifted Keysyms
            ;; =========================================================================
            (deflayer sym
              _      _      _      _      _      _ _ _      _      _      _      _      _    _
              _      S-[    S-7    S-8    S-9    S-] _ S--  -      S-8    /      S-6    _    _
              _      S-;    S-4    S-5    S-6    S-= _ S-'  '      S-,    S-.    S-/    _
              _      S-grv  S-1    S-2    S-3    S-\ _ [    ]      S-[    S-]    _
              _      _                    _                 _      _
            )

            ;; =========================================================================
            ;; LAYER 5: FUN / MEDIA (Hold Left Win / lmet)
            ;; Top: F1-F12 | Right hand: Volume, Playback
            ;; =========================================================================
            (deflayer fun
              _      f1     f2     f3     f4     f5 f6 f7     f8     f9     f10    f11    f12  _
              _      _      _      _      _      _  _  _      _      _      _      _      _    _
              _      _      _      _      _      _  prev voldwn volu   next   _      _    _
              _      _      _      _      _      _  mute pp     _      _      _      _
              _      _                    _                 _      _
            )

            ;; =========================================================================
            ;; HARD BILATERAL OVERRIDES: Enforces contralateral modifier usage
            ;; =========================================================================
            (defoverrides
              ;; Left Shift cannot shift Left-Hand letters
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

              ;; Left Ctrl cannot Ctrl Left-Hand letters (c, v, x, z)
              (lctl c) (c)
              (lctl v) (v)
              (lctl x) (x)
              (lctl z) (z)
              (lctl a) (a)
              (lctl s) (s)
              (lctl d) (d)

              ;; Left Alt cannot Alt s
              (lalt s) (s)
              (lalt a) (a)
              (lalt d) (d)

              ;; Left Super cannot Super e, w, q
              (lmet e) (e)
              (lmet w) (w)
              (lmet q) (q)

              ;; Right Shift cannot shift Right-Hand letters
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

              ;; Right Ctrl cannot Ctrl Right-Hand letters
              (rctl h) (h)
              (rctl j) (j)
              (rctl k) (k)
              (rctl l) (l)
              (rctl ;) (;)
              (rctl n) (n)
              (rctl m) (m)
            )

            ;; Universal CUA clipboard & navigation chords (Active ONLY on base layer)
            (defchordsv2
              (a z) C-S-z 20 all-released (nav num sym fun)
              (z x) C-z   20 all-released (nav num sym fun)
              (x c) C-ins 20 all-released (nav num sym fun)
              (c v) S-ins 20 all-released (nav num sym fun)
              (x v) S-del 20 all-released (nav num sym fun)
              (z v) C-a   20 all-released (nav num sym fun)
              (u i) C-bspc 20 all-released (nav num sym fun)
              (i o) C-del  20 all-released (nav num sym fun)
              (n m) tab   20 all-released (nav num sym fun)
              (m ,) C-pgup 20 all-released (nav num sym fun)
              (, .) C-pgdn 20 all-released (nav num sym fun)
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