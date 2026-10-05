{ config, lib, pkgs, ... }:
let
  kanataConfig = ''
    (defsrc
      esc  1 2 3 4 5 6 7 8 9 0 - = bspc
      tab  q w e r t y u i o p [ ] \
      caps a s d f g h j k l scln ' ret
      lsft z x c v b n m , . / rsft
      lmet lalt       spc       ralt rctl
    )

    (defvar
      tap-repress 175
      hold-time   200

      left-nonhome (
        esc  1 2 3 4 5
        tab  q w e r t
             g
        lsft z x c v b
        lmet lalt spc
      )
      left-home-a (s d f)
      left-home-s (a d f)
      left-home-d (a s f)
      left-home-f (a s d)

      right-nonhome (
        6 7 8 9 0 - = bspc
        y u i o p [ ] \
        h             ' ret
        n m , . / rsft
        ralt rctl spc
      )
      right-home-j (k l scln)
      right-home-k (j l scln)
      right-home-l (j k scln)
      right-home-scln (j k l)
    )

    (defalias
      spc_nav (tap-hold-release 200 200 spc (layer-while-held nav))
      a    (tap-hold-release-tap-keys-release $tap-repress $hold-time a lalt $left-nonhome $left-home-a)
      s    (tap-hold-release-tap-keys-release $tap-repress $hold-time s lctl $left-nonhome $left-home-s)
      d    (tap-hold-release-tap-keys-release $tap-repress $hold-time d lmet $left-nonhome $left-home-d)
      f    (tap-hold-release-tap-keys-release $tap-repress $hold-time f lsft $left-nonhome $left-home-f)
      j    (tap-hold-release-tap-keys-release $tap-repress $hold-time j rsft $right-nonhome $right-home-j)
      k    (tap-hold-release-tap-keys-release $tap-repress $hold-time k rmet $right-nonhome $right-home-k)
      l    (tap-hold-release-tap-keys-release $tap-repress $hold-time l rctl $right-nonhome $right-home-l)
      scln (tap-hold-release-tap-keys-release $tap-repress $hold-time scln ralt $right-nonhome $right-home-scln)

      tog_raw (switch
        ((base-layer raw)) (layer-switch base) break
        () (layer-switch raw) break
      )
    )

    (deflayer base
      esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
      tab    q      w      e      r      t y u      i      o      p      [      ]    \
      esc    @a     @s     @d     @f     g h @j     @k     @l     @scln  '      ret
      lsft   z      x      c      v      b n m      ,      .      /      rsft
      lmet   lalt                 @spc_nav          ralt   rctl
    )

    (deflayer nav
      _      _      _      _      _      _ _      _    _    _    _      _      _    _
      _      _      _      _      _      _ C-S-z  C-v  C-c  C-x  C-z    _      _    _
      _      _      _      _      _      _ left   down up   rght _      _      _
      _      _      _      _      _      _ home   pgdn pgup end  _      _
      _      _                    _                    _    _
    )

    (deflayer raw
      esc    1      2      3      4      5 6 7      8      9      0      -      =    bspc
      tab    q      w      e      r      t y u      i      o      p      [      ]    \
      caps   a      s      d      f      g h j      k      l      scln   '      ret
      lsft   z      x      c      v      b n m      ,      .      /      rsft
      lmet   lalt                 spc               ralt   rctl
    )

    (defchordsv2
      (lsft rsft) @tog_raw  20 all-released ()
      (a z)       C-S-z     20 all-released ()
      (z x)       C-z       20 all-released ()
      (x c)       C-ins     20 all-released ()
      (c v)       S-ins     20 all-released ()
      (x v)       S-del     20 all-released ()
      (z v)       C-a       20 all-released ()
      (n m)       C-b       20 all-released ()
      (m ,)       C-bspc    20 all-released ()
      (, .)       C-del     20 all-released ()
    )
  '';
  extraDef = ''
    process-unmapped-keys yes
    concurrent-tap-hold yes
    tap-hold-require-prior-idle 120
    chords-v2-min-idle 100
  '';
in
{
  options.hardware.kanata.enableInternalKeyboard = lib.mkEnableOption "laptop internal i8042 keyboard mapping";

  config = {
    hardware.uinput.enable = true;

    services.udev.extraRules = ''
      KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="*Spring*", SYMLINK+="input/by-id/weikav-record-alice", TAG+="uaccess", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/input/by-id/weikav-record-alice"
      KERNEL=="event*", SUBSYSTEM=="input", ATTRS{id/vendor}=="369b", ATTRS{id/product}=="0051", SYMLINK+="input/by-id/weikav-record-alice", TAG+="uaccess", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/input/by-id/weikav-record-alice"
    '';

    services.kanata = {
      enable = true;
      keyboards = {
        bluetooth = {
          devices = [ "/dev/input/by-id/lofree-flow84" ];
          extraDefCfg = extraDef;
          config = kanataConfig;
        };
        alice = {
          devices = [
            "/dev/input/by-id/weikav-record-alice"
            "/dev/input/by-id/usb-ITON_Spring_DEMO-event-kbd"
          ];
          extraDefCfg = extraDef;
          config = kanataConfig;
        };
      } // lib.optionalAttrs config.hardware.kanata.enableInternalKeyboard {
        internal = {
          devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
          extraDefCfg = extraDef;
          config = kanataConfig;
        };
      };
    };

    systemd.services.kanata-bluetooth = {
      unitConfig = {
        BindsTo = [ "dev-input-by\\x2did-lofree\\x2dflow84.device" ];
        After = [ "dev-input-by\\x2did-lofree\\x2dflow84.device" ];
      };
      serviceConfig = {
        Restart = lib.mkForce "on-failure";
        RestartSec = "2s";
      };
    };

    systemd.services.kanata-alice = {
      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";
      };
    };
  };
}
