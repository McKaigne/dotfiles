{ config, lib, pkgs, ... }:
let
  kanataConfig = ''
    (defsrc
      esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    scln '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      lmet lalt           spc                 ralt rctl
    )

    (defoverrides
      ;; Unshifted number row outputs Programmer Symbols
      (1) (lsft =)
      (2) ([)
      (3) (lsft [)
      (4) (lsft 9)
      (5) (lsft 7)
      (6) (=)
      (7) (lsft 0)
      (8) (lsft ])
      (9) (])
      (0) (lsft 8)
      (-) (lsft 1)
      (=) (lsft 3)
      (]) (lsft 2)

      ;; Shifted number row inverts back to clean Digits and Symbols
      (lsft 1) (1)
      (rsft 1) (1)
      (lsft 2) (2)
      (rsft 2) (2)
      (lsft 3) (3)
      (rsft 3) (3)
      (lsft 4) (4)
      (rsft 4) (4)
      (lsft 5) (5)
      (rsft 5) (5)
      (lsft 6) (6)
      (rsft 6) (6)
      (lsft 7) (7)
      (rsft 7) (7)
      (lsft 8) (8)
      (rsft 8) (8)
      (lsft 9) (9)
      (rsft 9) (9)
      (lsft 0) (0)
      (rsft 0) (0)
      (lsft -) (lsft 5)
      (rsft -) (lsft 5)
      (lsft =) (lsft 4)
      (rsft =) (lsft 4)
      (lsft ]) (lsft 6)
      (rsft ]) (lsft 6)
    )

    ;; ------------------------------------------------------------------------
    ;; Base Layer Chords: df -> tab, jk -> C-bspc
    ;; ------------------------------------------------------------------------
    (defchords base-chords 50
      (d) d
      (f) f
      (d f) tab

      (j) j
      (k) k
      (j k) C-bspc
    )

    ;; ------------------------------------------------------------------------
    ;; Nav Layer Left-Hand Chords (a, s, d, f)
    ;; ------------------------------------------------------------------------
    (defchords nav-chords 50
      ;; Singles: Dispatched via dedicated dual-action aliases
      (a) @os_alt
      (s) @os_ctl
      (d) @os_met
      (f) @os_sft

      ;; Doubles: Zero-hold composite OSMs returning cleanly to base
      (d f) (multi (layer-switch base) (release-layer nav) (one-shot 2000 M-lsft))
      (s d) (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-lmet))
      (s f) (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-lsft))
      (a s) (multi (layer-switch base) (release-layer nav) (one-shot 2000 A-lctl))
      (a d) (multi (layer-switch base) (release-layer nav) (one-shot 2000 A-lmet))
      (a f) (multi (layer-switch base) (release-layer nav) (one-shot 2000 A-lsft))

      ;; Triples
      (a s f) (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-A-lsft))
      (a d f) (multi (layer-switch base) (release-layer nav) (one-shot 2000 A-M-lsft))
      (s d f) (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-M-lsft))
      (a s d) (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-A-lmet))

      ;; Quadruple
      (a s d f) (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-A-M-lsft))
    )

    ;; ------------------------------------------------------------------------
    ;; Num Layer Right-Hand Chords (j, k, l, scln)
    ;; ------------------------------------------------------------------------
    (defchords num-chords 50
      ;; Singles: Dispatched via dedicated dual-action aliases
      (j)    @os_r_sft
      (k)    @os_r_met
      (l)    @os_r_ctl
      (scln) @os_r_alt

      ;; Doubles: Zero-hold composite OSMs returning cleanly to base
      (j k)    (multi (layer-switch base) (release-layer num) (one-shot 2000 M-lsft))
      (k l)    (multi (layer-switch base) (release-layer num) (one-shot 2000 C-lmet))
      (j l)    (multi (layer-switch base) (release-layer num) (one-shot 2000 C-lsft))
      (l scln) (multi (layer-switch base) (release-layer num) (one-shot 2000 A-lctl))
      (k scln) (multi (layer-switch base) (release-layer num) (one-shot 2000 A-lmet))
      (j scln) (multi (layer-switch base) (release-layer num) (one-shot 2000 A-lsft))

      ;; Triples
      (j l scln) (multi (layer-switch base) (release-layer num) (one-shot 2000 C-A-lsft))
      (j k scln) (multi (layer-switch base) (release-layer num) (one-shot 2000 A-M-lsft))
      (j k l)    (multi (layer-switch base) (release-layer num) (one-shot 2000 C-M-lsft))
      (k l scln) (multi (layer-switch base) (release-layer num) (one-shot 2000 C-A-lmet))

      ;; Quadruple
      (j k l scln) (multi (layer-switch base) (release-layer num) (one-shot 2000 C-A-M-lsft))
    )

    (defalias
      ;; Dual-Action Layer Triggers: Tap = One-Shot Layer (2000ms), Hold = Momentary Layer
      osl_nav (tap-hold 200 200 (one-shot 2000 (layer-toggle nav)) (layer-while-held nav))
      osl_num (tap-hold 200 200 (one-shot 2000 (layer-toggle num)) (layer-while-held num))

      ;; Base Layer Typing Chord Aliases
      b_d (chord base-chords d)
      b_f (chord base-chords f)
      b_j (chord base-chords j)
      b_k (chord base-chords k)

      ;; Nav Layer Left-Hand OSM Chord Aliases
      n_a (chord nav-chords a)
      n_s (chord nav-chords s)
      n_d (chord nav-chords d)
      n_f (chord nav-chords f)

      ;; Nav Dual-Action Modifiers: Tap = OSM to base; Hold = native mod staying on nav
      os_alt (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 lalt)) lalt)
      os_ctl (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 lctl)) lctl)
      os_met (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 lmet)) lmet)
      os_sft (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 lsft)) lsft)

      ;; Dedicated Nav Composite Modifiers
      os_meh   (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-A-lsft)) C-A-lsft)
      os_cs    (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-lsft)) C-lsft)
      os_ms    (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 M-lsft)) M-lsft)
      os_ams   (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 A-M-lsft)) A-M-lsft)
      os_cms   (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-M-lsft)) C-M-lsft)
      os_hyper (tap-hold-press 200 200 (multi (layer-switch base) (release-layer nav) (one-shot 2000 C-A-M-lsft)) C-A-M-lsft)

      ;; Num Layer Right-Hand OSM Chord Aliases
      m_j    (chord num-chords j)
      m_k    (chord num-chords k)
      m_l    (chord num-chords l)
      m_scln (chord num-chords scln)

      ;; Num Dual-Action Modifiers: Tap = OSM to base; Hold = native mod staying on num
      os_r_sft (tap-hold-press 200 200 (multi (layer-switch base) (release-layer num) (one-shot 2000 lsft)) lsft)
      os_r_met (tap-hold-press 200 200 (multi (layer-switch base) (release-layer num) (one-shot 2000 lmet)) lmet)
      os_r_ctl (tap-hold-press 200 200 (multi (layer-switch base) (release-layer num) (one-shot 2000 lctl)) lctl)
      os_r_alt (tap-hold-press 200 200 (multi (layer-switch base) (release-layer num) (one-shot 2000 lalt)) lalt)
      os_r_meh (tap-hold-press 200 200 (multi (layer-switch base) (release-layer num) (one-shot 2000 C-A-lsft)) C-A-lsft)

      ;; Number Layer Keypad + Shifted Function Keys (F1-F12)
      n_pls (fork S-= f11 (lsft rsft))
      n_min (fork - f12 (lsft rsft))
      n_ast S-8
      n_sls /
      n_dot .
      n_eql =

      n9 (fork 9 f9 (lsft rsft))
      n8 (fork 8 f8 (lsft rsft))
      n7 (fork 7 f7 (lsft rsft))
      n6 (fork 6 f6 (lsft rsft))
      n5 (fork 5 f5 (lsft rsft))
      n4 (fork 4 f4 (lsft rsft))
      n3 (fork 3 f3 (lsft rsft))
      n2 (fork 2 f2 (lsft rsft))
      n1 (fork 1 f1 (lsft rsft))
      n0 (fork 0 f10 (lsft rsft))
    )

    (deflayer base
      esc  1    2    3     4     5  6  7     8     9  0    -    =    bspc
      tab  q    w    e     r     t  y  u     i     o  p    [    ]    \
      esc  a    s    @b_d  @b_f  g  h  @b_j  @b_k  l  scln '    ret
      lsft z    x    c     v     b  n  m     ,     .  /    rsft
      lmet @osl_nav        spc                 @osl_num  rctl
    )

    (deflayer nav
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    @os_hyper @os_cs  @os_ms  @os_ams  @os_cms  C-S-z  S-ins C-ins S-del C-z  _    _    _
      _    @n_a      @n_s    @n_d    @n_f     @os_meh  left   down  up    rght  _    _    _
      _    C-p       C-t     C-s     C-r      C-o      home   pgdn  pgup  end   ret  _
      _    _                         spc                            del   _
    )

    (deflayer num
      _    _      _   _    _     _        _        _      _     _     _       _ _ _
      _    @n_pls @n9 @n8  @n7   @n_min   @n_sls   _      _     _     _       _ _ _
      _    @n_ast @n3 @n2  @n1   @n_eql   @os_r_meh @m_j  @m_k  @m_l  @m_scln _ _
      _    @n_dot @n6 @n5  @n4   @n_sls   M-x      C-x    C-c   C-h   C-u     _
      _    .               @n0                     _      _
    )
  '';
in
{
  options.hardware.kanata.enableInternalKeyboard = lib.mkEnableOption "laptop internal i8042 keyboard mapping";

  config = {
    hardware.uinput.enable = true;

    services.kanata = {
      enable = true;
      keyboards.default = {
        devices = [ ];
        extraDefCfg = ''
          process-unmapped-keys yes
          concurrent-tap-hold yes
          linux-dev-names-exclude (
            "Corne"
          )
        '';
        config = kanataConfig;
      };
    };
  };
}