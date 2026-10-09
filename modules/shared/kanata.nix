{ self, inputs, ... }: {
  flake.nixosModules.kanata = { config, lib, pkgs, ... }:
  let
    host = config.networking.hostName;

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
    extRow4Shift = if host == "hyde" then "@to_num" else "_";
    symRow4Shift = if host == "hyde" then "@to_num" else "_";

    kanataConfig = ''
      (defsrc
        esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
        caps a    s    d    f    g    h    j    k    l    scln '    ret
        lsft z    x    c    v    b    n    m    ,    .    /    rsft
        lmet lalt           spc                 ralt rctl
      )

      (defalias
        ext (tap-hold-release 200 200 (one-shot 2000 (layer-while-held ext)) (layer-while-held ext))
        sym (tap-hold-release 200 200 (one-shot 2000 (layer-while-held sym)) (layer-while-held sym))
        sft_thumb (tap-hold-release 200 200 (one-shot 2000 lsft) lsft)

        to_fn  (layer-while-held fn)
        to_num (layer-while-held num)

        os_alt   (tap-hold-release 200 200 (one-shot 2000 lalt) lalt)
        os_ctl   (tap-hold-release 200 200 (one-shot 2000 lctl) lctl)
        os_met   (tap-hold-release 200 200 (one-shot 2000 lmet) lmet)
        os_sft   (tap-hold-release 200 200 (one-shot 2000 lsft) lsft)
        os_altgr (tap-hold-release 200 200 (one-shot 2000 ralt) ralt)
      )

      (deflayer base
        esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
        esc  a    s    d    f    g    h    j    k    l    scln '    ret
        lsft z    x    c    v    b    n    m    ,    .    /    rsft
        ${row5Base}
      )

      (deflayer ext
        _    _         _       _       _        _        _      _     _     _     _    _    _    _
        _    esc       bck     C-f     fwd      ins      home   pgdn  pgup  end   caps _    _    _
        _    @os_alt   @os_ctl @os_met @os_sft  @os_altgr left  down  up    rght  tab  _    _
        _    C-z       C-x     C-c     C-v      C-y      ret    bspc  del   menu  prnt ${extRow4Shift}
        ${row5Ext}
      )

      (deflayer sym
        _    _         _       _       _        _        _      _     _     _     _    _    _    _
        _    S-1       S-2     S-3     S-4      S-5      =      `     S-scln scln S-=  _    _    _
        _    @os_alt   @os_ctl @os_met @os_sft  S-6      S-8    S-9   S-[   [     -    _    _
        _    _         _       \       S-\      S-7      S-`    S-0   S-]   ]     S--  ${symRow4Shift}
        ${row5Sym}
      )

      (deflayer num
        _    _         _       _       _        _        _      _     _     _     _    _    _    _
        _    _         _       _       _        nlck     =      7     8     9     S-=  _    _    _
        _    @os_alt   @os_ctl @os_met @os_sft  @os_altgr S-8   4     5     6     -    _    _
        _    _         menu    tab     bspc     ret      0      1     2     3     /    _
        _    _                         0                        _     _
      )

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
