{ config, lib, pkgs, ... }:
let
  host = config.networking.hostName;

  # Base layer row 5 thumb configuration per machine
  # castor (Laptop): LAlt -> Ext, Space -> Space, RAlt -> One-Shot Shift, RCtrl -> Sym
  # hyde (Desktop / Alice): LAlt -> Ext, Space -> Space, RAlt -> Sym, RCtrl -> standard RCtrl
  # (On Alice, Right Space physically emits rsft via VIA firmware)
  row5Thumbs =
    if host == "castor" then
      "lmet @ext spc @sft_thumb @sym"
    else
      "lmet @ext spc @sym rctl";

  kanataConfig = ''
    (defsrc
      esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    scln '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      lmet lalt           spc                 ralt rctl
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

    (defalias
      ;; Layer Triggers: Tap = One-Shot Layer (2000ms), Hold = Momentary Layer
      ext (tap-hold 200 200 (one-shot 2000 (layer-while-held ext)) (layer-while-held ext))
      sym (tap-hold 200 200 (one-shot 2000 (layer-while-held sym)) (layer-while-held sym))
      sft_thumb (tap-hold 200 200 (one-shot 2000 lsft) lsft)

      ;; Inter-layer Combo Jumpers
      to_fn  (layer-while-held fn)
      to_num (layer-while-held num)

      ;; Base Layer Typing Chords
      b_d (chord base-chords d)
      b_f (chord base-chords f)
      b_j (chord base-chords j)
      b_k (chord base-chords k)

      ;; Home Row Modifiers (Extend, Symbols, Numbers, Function)
      os_alt   (tap-hold 200 200 (one-shot 2000 lalt) lalt)
      os_met   (tap-hold 200 200 (one-shot 2000 lmet) lmet)
      os_sft   (tap-hold 200 200 (one-shot 2000 lsft) lsft)
      os_ctl   (tap-hold 200 200 (one-shot 2000 lctl) lctl)
      os_altgr (tap-hold 200 200 (one-shot 2000 ralt) ralt)
    )

    ;; ========================================================================
    ;; Layer 0: Base Layer (QWERTY Alphas + Full ANSI Restored + Caps->Esc)
    ;; ========================================================================
    (deflayer base
      esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      esc  a    s    @b_d @b_f g    h    @b_j @b_k l    scln '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      ${row5Thumbs}
    )

    ;; ========================================================================
    ;; Layer 1: Extend Layer (DreymaR Navigation + Universal CUA Clipboard)
    ;; ========================================================================
    (deflayer ext
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    esc       bck     C-f     fwd      ins      pgup   home  up    end   caps _    _    _
      _    @os_alt   @os_met @os_sft @os_ctl  @os_altgr pgdn  left  down  rght  del  _    _
      _    C-z       S-del   C-ins   lmet     S-ins    ret    bspc  tab   menu  prnt _
      _    _                         ret                      @to_fn @to_fn
    )

    ;; ========================================================================
    ;; Layer 2: Symbols Layer (Image 6 US Verbatim Enclosure Matrix)
    ;; ========================================================================
    (deflayer sym
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    S-1       S-2     S-3     S-4      S-5      =      `     S-scln scln S-=  _    _    _
      _    @os_alt   @os_met @os_sft @os_ctl  S-6      S-8    S-9   S-[   [     -    _    _
      _    _         _       \       S-\      S-7      S-`    S-0   S-]   ]     S--  _
      _    @to_fn                    _                        @to_num @to_num
    )

    ;; ========================================================================
    ;; Layer 3: Numbers Layer (Image 7 Verbatim 3x4 Numpad Grid)
    ;; ========================================================================
    (deflayer num
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    _         _       _       _        nlck     =      7     8     9     S-=  _    _    _
      _    @os_alt   @os_met @os_sft @os_ctl  @os_altgr S-8   4     5     6     -    _    _
      _    _         menu    tab     bspc     ret      0      1     2     3     /    _
      _    _                         0                        _     _
    )

    ;; ========================================================================
    ;; Layer 4: Function Layer (Image 5 Verbatim Grid + Media Controls)
    ;; ========================================================================
    (deflayer fn
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    _         prev    pp      next     brup     f12    f7    f8    f9    slck _    _    _
      _    @os_alt   @os_met @os_sft @os_ctl  brdn     f11    f4    f5    f6    _    _    _
      _    mute      vold    C-S-c   volu     C-S-v    f10    f1    f2    f3    _    _
      _    _                         _                        _     _
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
