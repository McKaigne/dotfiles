_: {
  flake.nixosModules.kanata =
    _:
    let
      mkSeniplyConfig =
        isWide:
        let
          baseRows =
            if isWide then
              ''
                esc  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
                tab  q    w    e    r    t    [    y    u    i    o    p    '    \
                esc  a    s    d    f    g    ]    h    j    k    l    scln ret
                lsft z    x    c    v    b    /    n    m    ,    .    rsft
                lctl lmet @ext           spc                 rsft rmet @sym
              ''
            else
              ''
                esc  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
                tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
                esc  a    s    d    f    g    h    j    k    l    scln '    ret
                lsft z    x    c    v    b    n    m    ,    .    /    rsft
                lctl lmet @ext           spc                 @sym rmet rctl
              '';

          extRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    esc  @bk  @fd  @fw  ins  _    home pgdn pgup end  caps _    _
                _    @oa  @oc  @om  @os  ralt _    left down up   rght del  _
                _    @un  @ct  @cl  @cp  @ps  ssrq ret  bspc tab  menu _
                _    _    _              ret                 _    _    @fun
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    esc  @bk  @fd  @fw  ins  home pgdn pgup end  caps _    _    _
                _    @oa  @oc  @om  @os  ralt left down up   rght del  _    _
                _    @un  @ct  @cl  @cp  @ps  ret  bspc tab  menu ssrq _
                _    _    _              ret                 @fun _    _
              '';

          funRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    mstop prev pp  next brup _    f12  f7   f8   f9   slck _    _
                _    @oa  @oc  @om  @os  brdn _    f11  f4   f5   f6   @l0  _
                _    mute vold volu @tcp @tps @l1  f10  f1   f2   f3   _
                _    _    _              ret                 _    _    _
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    mstop prev pp  next brup f12  f7   f8   f9   slck _    _    _
                _    @oa  @oc  @om  @os  brdn f11  f4   f5   f6   @l0  _    _
                _    mute vold volu @tcp @tps f10  f1   f2   f3   @l1  _
                _    _    _              ret                 _    _    _
              '';

          symRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    @ex  @at  @hs  @dl  @pc  _    =    grv  @cln scln @pl  _    _
                _    @oa  @oc  @om  @os  @cr  _    @st  @lp  @lb  [    -    _
                _    _    _    \    @pip @am  @und @tld @rp  @rb  ]    _
                _    _    @fun           @snum               _    _    _
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    @ex  @at  @hs  @dl  @pc  =    grv  @cln scln @pl  _    _    _
                _    @oa  @oc  @om  @os  @cr  @st  @lp  @lb  [    -    _    _
                _    _    _    \    @pip @am  @tld @rp  @rb  ]    @und _
                _    _    @fun           @snum               _    _    _
              '';

          numRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    _    _    _    _    nlck _    =    7    8    9    @pl  _    _
                _    @oa  @oc  @om  @os  ralt _    @st  4    5    6    -    _
                _    _    menu tab  bspc ret  /    0    1    2    3    _
                _    _    @fun           _                   _    _    _
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    _    _    _    _    nlck =    7    8    9    @pl  _    _    _
                _    @oa  @oc  @om  @os  ralt @st  4    5    6    -    _    _
                _    _    menu tab  bspc ret  0    1    2    3    /    _
                _    _    @fun           _                   _    _    _
              '';
        in
        ''
          (deflocalkeys-linux
            mstop 166
          )

          (defsrc
            esc  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    scln '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc                 ralt rmet rctl
          )

          (defalias
            ext  (layer-while-held ext)
            sym  (layer-while-held sym)
            fun  (layer-while-held fun)
            snum (tap-hold-press 200 200 spc (layer-while-held num))

            oa   (one-shot 2000 lalt)
            oc   (one-shot 2000 lctl)
            om   (one-shot 2000 lmet)
            os   (one-shot 2000 lsft)

            bk   A-left
            fw   A-rght
            fd   C-f
            un   C-z
            ct   C-x
            cl   C-w
            cp   C-c
            ps   C-v
            tcp  C-S-c
            tps  C-S-v

            ex   S-1
            at   S-2
            hs   S-3
            dl   S-4
            pc   S-5
            cr   S-6
            am   S-7
            st   S-8
            lp   S-9
            rp   S-0
            pl   S-=
            lb   S-[
            rb   S-]
            cln  S-scln
            tld  S-grv
            und  S--
            pip  S-\

            l0   (layer-switch base)
            l1   (layer-switch gaming)
            gex  (switch ((and lctl lalt)) (layer-switch base) break () esc break)
            cgex (switch ((and lctl lalt)) (layer-switch base) break () caps break)
          )

          (deflayer base
            ${baseRows}
          )

          (deflayer gaming
            @gex grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            @cgex a   s    d    f    g    h    j    k    l    scln '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc                 ralt rmet rctl
          )

          (deflayer ext
            ${extRows}
          )

          (deflayer fun
            ${funRows}
          )

          (deflayer sym
            ${symRows}
          )

          (deflayer num
            ${numRows}
          )
        '';
    in
    {
      hardware.uinput.enable = true;

      services.kanata = {
        enable = true;
        keyboards = {
          ansi = {
            devices = [ ];
            extraDefCfg = ''
              process-unmapped-keys yes
              concurrent-tap-hold yes
              linux-device-detect-mode keyboard-only
              linux-output-device-name kanata-ansi
              linux-dev-names-exclude (
                "Corne"
                "Akko Keyboard"
                "Endgame Gear Endgame Gear OP1 8k v2 Gaming Mouse Keyboard"
                "kanata-alice"
                "kanata-ansi"
              )
            '';
            config = mkSeniplyConfig true;
          };
          alice = {
            devices = [ ];
            extraDefCfg = ''
              process-unmapped-keys yes
              concurrent-tap-hold yes
              linux-device-detect-mode keyboard-only
              linux-output-device-name kanata-alice
              linux-dev-names-include (
                "Akko Keyboard"
              )
            '';
            config = mkSeniplyConfig false;
          };
        };
      };
    };
}
