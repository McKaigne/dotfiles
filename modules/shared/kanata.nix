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

      ;; ------------------------------------------------------------------------
      ;; Programmer QWERTY ANSI Custom Shift/Unshift Forks
      ;; ------------------------------------------------------------------------
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

      ;; ------------------------------------------------------------------------
      ;; Timeless Home Row Modifiers (Order: Alt, Ctrl, Gui, Shift)
      ;; ------------------------------------------------------------------------
      (defalias
        ha (tap-hold-release 200 250 a lalt)
        hs (tap-hold-release 200 250 s lctl)
        hd (tap-hold-release 200 250 d lmet)
        hf (tap-hold-release 200 250 f lsft)

        hj (tap-hold-release 200 250 j rsft)
        hk (tap-hold-release 200 250 k rmet)
        hl (tap-hold-release 200 250 l rctl)
        hsc (tap-hold-release 200 250 scln ralt)
      )

      ;; ------------------------------------------------------------------------
      ;; Combos / Chords (50ms Threshold)
      ;; ------------------------------------------------------------------------
      (defchords combos 50
        (z) z
        (x) x
        (c) c
        (v) v
        (b) b
        (d) @hd
        (f) @hf
        (j) @hj
        (k) @hk
        (n) n
        (m) m
        (comm) ,
        (dot) .

        (z x) S-del
        (x c) C-ins
        (c v) S-ins
        (v b) C-a
        (f j) (caps-word 2000)
        (j k) C-bspc
        (d f) C-b
        (n m) C-y
        (m comm) C-z
        (comm dot) C-f
      )

      ;; ------------------------------------------------------------------------
      ;; Single Unified Layerless Layout
      ;; ------------------------------------------------------------------------
      (deflayer base
        @pq_grv @pq_1 @pq_2 @pq_3 @pq_4 @pq_5 @pq_6 @pq_7 @pq_8 @pq_9 @pq_0 @pq_min @pq_eql bspc
        tab     q     w     e     r     t     y     u     i     o     p     -       @pq_rbk @pq_bsh
        esc     @ha   @hs   (chord combos d) (chord combos f) g h (chord combos j) (chord combos k) @hl @hsc ' ret
        lsft    (chord combos z) (chord combos x) (chord combos c) (chord combos v) (chord combos b) (chord combos n) (chord combos m) (chord combos comm) (chord combos dot) / rsft
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
          linux-dev-names-exclude (
            "Corne"
          )
        '';
        config = kanataConfig;
      };
    };
  };
}
