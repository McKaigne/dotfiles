{
  nixos.base =
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
                _    @un  @ct  @cp  @ps  @cret ssrq ret bspc tab  menu _
                _    _    _              _                   @mou _    @fun
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    esc  @bk  @fd  @fw  ins  home pgdn pgup end  caps _    _    _
                _    @oa  @oc  @om  @os  ralt left down up   rght del  _    _
                _    @un  @ct  @cp  @ps  @cret ret bspc tab  menu ssrq @mou
                _    _    _              _                   @fun _    _
              '';

          mouseRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    esc  @bk  @fd  @fw  ins  _    @mwl @mwd @mwu @mwr caps _    _
                _    @oa  @oc  @om  @os  ralt _    @msl @msd @msu @msr mmid _
                _    @un  @ct  @cp  @ps  @cret ssrq ret mlft mrgt menu _
                _    _    _              _                   _    _    @fun
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    esc  @bk  @fd  @fw  ins  @mwl @mwd @mwu @mwr caps _    _    _
                _    @oa  @oc  @om  @os  ralt @msl @msd @msu @msr mmid _    _
                _    @un  @ct  @cp  @ps  @cret ret mlft mrgt menu ssrq _
                _    _    _              _                   @fun _    _
              '';

          funRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    mstop prev pp  next brup _    f12  f7   f8   f9   slck _    _
                _    @oa  @oc  @om  @os  brdn _    f11  f4   f5   f6   @l0  _
                _    mute vold @tcp @tps volu @l1  f10  f1   f2   f3   _
                _    _    _              _                   _    _    _
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    mstop prev pp  next brup f12  f7   f8   f9   slck _    _    _
                _    @oa  @oc  @om  @os  brdn f11  f4   f5   f6   @l0  _    _
                _    mute vold @tcp @tps volu f10  f1   f2   f3   @l1  _
                _    _    _              _                   _    _    _
              '';

          symRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    @pl  [    @lb  @lp  @lt  _    @gt  @rp  @rb  ]    @tld _    _
                _    -    @st  @und =    @at  _    @hs  @os  @om  @oc  @oa  _
                _    @cr  @cln scln /    @pc  grv  @dl  \    @am  @pip _
                _    _    @fun           @snum               _    _    _
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    @pl  [    @lb  @lp  @lt  @gt  @rp  @rb  ]    @tld _    _    _
                _    -    @st  @und =    @at  @hs  @os  @om  @oc  @oa  _    _
                _    @cr  @cln scln /    @pc  @dl  \    @am  @pip grv  _
                _    _    @fun           @snum               _    _    _
              '';

          numRows =
            if isWide then
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    @pl  9    8    7    =    _    nlck _    _    _    _    _    _
                _    -    6    5    4    @st  _    ralt @os  @om  @oc  @oa  _
                _    /    3    2    1    0    _    ret  bspc tab  menu _
                _    _    @fun           _                   _    _    _
              ''
            else
              ''
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    @pl  9    8    7    =    nlck _    _    _    _    _    _    _
                _    -    6    5    4    @st  ralt @os  @om  @oc  @oa  _    _
                _    /    3    2    1    0    ret  bspc tab  menu _    _
                _    _    @fun           _                   _    _    _
              '';

          symChords =
            if isWide then
              ''
                (w e) @neq  55 first-release (base gaming ext fun num mouse)
                (e r) @lte  55 first-release (base gaming ext fun num mouse)
                (r t) grv   55 first-release (base gaming ext fun num mouse)
                (s d) @arw  55 first-release (base gaming ext fun num mouse)
                (d f) @dotb 55 first-release (base gaming ext fun num mouse)
                (u i) '     55 first-release (base gaming ext fun num mouse)
                (i o) @gte  55 first-release (base gaming ext fun num mouse)
              ''
            else
              ''
                (w e) @neq  55 first-release (base gaming ext fun num mouse)
                (e r) @lte  55 first-release (base gaming ext fun num mouse)
                (r t) grv   55 first-release (base gaming ext fun num mouse)
                (s d) @arw  55 first-release (base gaming ext fun num mouse)
                (d f) @dotb 55 first-release (base gaming ext fun num mouse)
                (y u) '     55 first-release (base gaming ext fun num mouse)
                (u i) @gte  55 first-release (base gaming ext fun num mouse)
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
            mou  (layer-while-held mouse)
            sym  (layer-while-held sym)
            fun  (layer-while-held fun)
            snum (tap-hold-press 200 200 spc (layer-while-held num))

            oa   (one-shot 2000 lalt)
            oc   (one-shot 2000 lctl)
            om   (one-shot 2000 lmet)
            os   (one-shot 2000 lsft)

            msl  (movemouse-accel-left 10 1000 2 10)
            msd  (movemouse-accel-down 10 1000 2 10)
            msu  (movemouse-accel-up 10 1000 2 10)
            msr  (movemouse-accel-right 10 1000 2 10)
            mwl  (mwheel-left 50 120)
            mwd  (mwheel-down 50 120)
            mwu  (mwheel-up 50 120)
            mwr  (mwheel-right 50 120)

            bk   A-left
            fw   A-rght
            fd   C-f
            un   C-z
            ct   C-x
            cret C-ret
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
            lt   S-,
            gt   S-.
            cln  S-scln
            tld  S-grv
            und  S--
            pip  S-\

            neq  (macro S-1 =)
            lte  (macro S-, =)
            gte  (macro S-. =)
            arw  (macro = S-.)
            dotb (macro . S-[)

            l0   (layer-switch base)
            l1   (layer-switch gaming)
            gex  (switch ((and lctl lalt)) (layer-switch base) break () esc break)
            cgex (switch ((and lctl lalt)) (layer-switch base) break () caps break)
          )

          (defchordsv2
            ${symChords}
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

          (deflayer mouse
            ${mouseRows}
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
              movemouse-inherit-accel-state yes
              movemouse-smooth-diagonals yes
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
              movemouse-inherit-accel-state yes
              movemouse-smooth-diagonals yes
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
