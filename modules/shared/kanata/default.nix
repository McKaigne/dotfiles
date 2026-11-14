_: {
  flake.nixosModules.kanata =
    _:
    let
      kanataConfig = ''
        (defsrc
          grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
          tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
          caps a    s    d    f    g    h    j    k    l    scln '    ret
          lsft z    x    c    v    b    n    m    ,    .    /    rsft
          lctl lmet lalt           spc                 ralt rmet rctl
        )

        (defhands
          (left  grv 1 2 3 4 5 q w e r t a s d f g z x c v b)
          (right 6 7 8 9 0 - = y u i o p [ ] \ h j k l scln ' n m , . /)
        )

        (defalias
          ha  (tap-hold-opposite-hand-release 200 a lalt (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
          hs  (tap-hold-opposite-hand-release 200 s lctl (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
          hd  (tap-hold-opposite-hand-release 200 d lmet (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
          hf  (tap-hold-opposite-hand-release 200 f lsft (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
          hj  (tap-hold-opposite-hand-release 200 j rsft (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
          hk  (tap-hold-opposite-hand-release 200 k rmet (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
          hl  (tap-hold-opposite-hand-release 200 l rctl (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
          hsc (tap-hold-opposite-hand-release 200 scln ralt (timeout hold) (unknown-hand hold) (neutral-keys spc ret bspc tab esc) (tap-repress-timeout 100) (require-prior-idle 90))
        )

        (deflayer base
          grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
          tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
          esc  @ha  @hs  @hd  @hf  g    h    @hj  @hk  @hl  @hsc '    ret
          lsft z    x    c    v    b    n    m    ,    .    /    rsft
          lctl lmet lalt           spc                 ralt rmet rctl
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
            tap-hold-require-prior-idle 90
            linux-device-detect-mode keyboard-only
            linux-dev-names-exclude (
              "Corne"
            )
          '';
          config = kanataConfig;
        };
      };
    };
}
