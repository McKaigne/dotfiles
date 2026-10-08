{ config, lib, pkgs, ... }:
let
  host = config.networking.hostName;

  # Base layer row 5 thumb configuration:
  # castor (Laptop): LAlt -> Ext, Space -> Space, RAlt -> One-Shot Shift, RCtrl -> Sym
  # hyde (Desktop / Alice): LAlt -> Ext, Space -> Space, RAlt -> Sym, RCtrl -> standard RCtrl
  # (On Alice, Right Space physically emits rsft via VIA firmware)
  row5Base =
    if host == "castor" then
      "lmet @ext spc @sft_thumb @sym"
    else
      "lmet @ext spc @sym rctl";

  row5Ext =
    if host == "castor" then
      "_ _ ret @to_num @to_fn"
    else
      "_ _ ret @to_fn _";

  row5Sym = "_ @to_fn @to_num _ _";

  extRow4Shift =
    if host == "hyde" then "@to_num" else "_";

  symRow4Shift =
    if host == "hyde" then "@to_num" else "_";

  kanataConfig = ''
    (defsrc
      esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    scln '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      lmet lalt           spc                 ralt rctl
    )

    (defalias
      ;; Layer Triggers: Tap = One-Shot Layer (2000ms), Hold = Momentary Layer
      ext (tap-hold 200 200 (one-shot 2000 (layer-while-held ext)) (layer-while-held ext))
      sym (tap-hold 200 200 (one-shot 2000 (layer-while-held sym)) (layer-while-held sym))
      sft_thumb (tap-hold 200 200 (one-shot 2000 lsft) lsft)

      ;; Inter-layer Combo Jumpers
      to_fn  (layer-while-held fn)
      to_num (layer-while-held num)

      ;; Home Row Modifiers (Reordered to Alt, Ctrl, GUI, Shift, AltGr)
      os_alt   (tap-hold 200 200 (one-shot 2000 lalt) lalt)
      os_ctl   (tap-hold 200 200 (one-shot 2000 lctl) lctl)
      os_met   (tap-hold 200 200 (one-shot 2000 lmet) lmet)
      os_sft   (tap-hold 200 200 (one-shot 2000 lsft) lsft)
      os_altgr (tap-hold 200 200 (one-shot 2000 ralt) ralt)
    )

    ;; ========================================================================
    ;; Layer 0: Base Layer (Zero Chords, CapsLock -> Escape, Full ANSI Alphas)
    ;; ========================================================================
    (deflayer base
      esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      esc  a    s    d    f    g    h    j    k    l    scln '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      ${row5Base}
    )

    ;; ========================================================================
    ;; Layer 1: Extend Layer (Left: CUA Clipboard | Right: Vim Navigation)
    ;; ========================================================================
    (deflayer ext
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    esc       bck     C-f     fwd      ins      home   pgdn  pgup  end   caps _    _    _
      _    @os_alt   @os_ctl @os_met @os_sft  @os_altgr left  down  up    rght  tab  _    _
      _    C-z       C-x     C-c     C-v      C-y      ret    bspc  del   menu  prnt ${extRow4Shift}
      ${row5Ext}
    )

    ;; ========================================================================
    ;; Layer 2: Symbols Layer (Image 6 US Verbatim Enclosure Matrix)
    ;; ========================================================================
    (deflayer sym
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    S-1       S-2     S-3     S-4      S-5      =      `     S-scln scln S-=  _    _    _
      _    @os_alt   @os_ctl @os_met @os_sft  S-6      S-8    S-9   S-[   [     -    _    _
      _    _         _       \       S-\      S-7      S-`    S-0   S-]   ]     S--  ${symRow4Shift}
      ${row5Sym}
    )

    ;; ========================================================================
    ;; Layer 3: Numbers Layer (Image 7 Verbatim 3x4 Numpad Grid)
    ;; ========================================================================
    (deflayer num
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    _         _       _       _        nlck     =      7     8     9     S-=  _    _    _
      _    @os_alt   @os_ctl @os_met @os_sft  @os_altgr S-8   4     5     6     -    _    _
      _    _         menu    tab     bspc     ret      0      1     2     3     /    _
      _    _                         0                        _     _
    )

    ;; ========================================================================
    ;; Layer 4: Function Layer (Realigned Audio/Terminal Keys + F1-F12)
    ;; ========================================================================
    (deflayer fn
      _    _         _       _       _        _        _      _     _     _     _    _    _    _
      _    _         prev    pp      next     brup     f12    f7    f8    f9    slck _    _    _
      _    @os_alt   @os_ctl @os_met @os_sft  brdn     f11    f4    f5    f6    _    _    _
      _    vold      volu    C-S-c   C-S-v    mute     f10    f1    f2    f3    _    _
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
