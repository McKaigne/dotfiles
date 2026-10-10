{ self, inputs, ... }: {
  flake.nixosModules.kanata = { config, lib, pkgs, ... }:
  let
    kanataConfig = ''
      (defsrc
        grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
        tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
        caps a    s    d    f    g    h    j    k    l    scln '    ret
        lsft z    x    c    v    b    n    m    ,    .    /    rsft
        lctl lmet lalt           spc                 ralt rmet rctl
      )

      (defalias
        pq_grv (fork S-\ S-grv (lsft rsft))
        pq_1   (fork S-= (unmod (lsft rsft) 1) (lsft rsft))
        pq_2   (fork [ (unmod (lsft rsft) 2) (lsft rsft))
        pq_3   (fork S-[ (unmod (lsft rsft) 3) (lsft rsft))
        pq_4   (fork S-9 (unmod (lsft rsft) 4) (lsft rsft))
        pq_5   (fork S-7 (unmod (lsft rsft) 5) (lsft rsft))
        pq_6   (fork = (unmod (lsft rsft) 6) (lsft rsft))
        pq_7   (fork S-0 (unmod (lsft rsft) 7) (lsft rsft))
        pq_8   (fork S-] (unmod (lsft rsft) 8) (lsft rsft))
        pq_9   (fork ] (unmod (lsft rsft) 9) (lsft rsft))
        pq_0   (fork S-8 (unmod (lsft rsft) 0) (lsft rsft))
        pq_min (fork S-1 S-5 (lsft rsft))
        pq_eql (fork S-4 (unmod (lsft rsft) grv) (lsft rsft))
        pq_rbk (fork S-2 S-6 (lsft rsft))
        pq_bsh (fork \ S-3 (lsft rsft))
      )

      (defhands
        (left  grv 1 2 3 4 5 q w e r t a s d f g z x c v b)
        (right 6 7 8 9 0 - = y u i o p [ ] \ h j k l scln ' n m , . /)
      )

      (defalias
        ha  (tap-hold-opposite-hand 200 a lalt (timeout hold) (unknown-hand hold))
        hs  (tap-hold-opposite-hand 200 s lctl (timeout hold) (unknown-hand hold))
        hd  (tap-hold-opposite-hand 200 d lmet (timeout hold) (unknown-hand hold))
        hf  (tap-hold-opposite-hand 200 f lsft (timeout hold) (unknown-hand hold))
        hj  (tap-hold-opposite-hand 200 j rsft (timeout hold) (unknown-hand hold))
        hk  (tap-hold-opposite-hand 200 k rmet (timeout hold) (unknown-hand hold))
        hl  (tap-hold-opposite-hand 200 l rctl (timeout hold) (unknown-hand hold))
        hsc (tap-hold-opposite-hand 200 scln ralt (timeout hold) (unknown-hand hold))
      )

      (defchords combos 25
        (z) z
        (x) x
        (c) c
        (v) v
        (b) b
        (f) @hf
        (j) @hj
        (n) n
        (m) m
        (,) ,
        (.) .

        (z x) S-del
        (x c) C-ins
        (c v) S-ins
        (v b) C-a
        (f j) (caps-word 2000)
        (n m) C-y
        (m ,) C-z
        (, .) C-f
      )

      (deflayer base
        @pq_grv @pq_1 @pq_2 @pq_3 @pq_4 @pq_5 @pq_6 @pq_7 @pq_8 @pq_9 @pq_0 @pq_min @pq_eql bspc
        tab     q     w     e     r     t     y     u     i     o     p     -       @pq_rbk @pq_bsh
        esc     @ha   @hs   @hd   (chord combos f) g h (chord combos j) @hk @hl @hsc ' ret
        lsft    (chord combos z) (chord combos x) (chord combos c) (chord combos v) (chord combos b) (chord combos n) (chord combos m) (chord combos ,) (chord combos .) / rsft
        lctl    lmet  lalt                    spc                       ralt  rmet    rctl
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
          tap-hold-require-prior-idle 120
          linux-dev-names-exclude (
            "Corne"
          )
        '';
        config = kanataConfig;
      };
    };
  };
}
