{
  flake.modules.nixos.openrgb = {pkgs, ...}: let
    setSpectrumScript = pkgs.writeShellScript "openrgb-colorspectrum" ''
      set -euo pipefail
      openrgb="${pkgs.openrgb}/bin/openrgb"

      sleep 1
      devices_out=""
      for _ in $(seq 1 30); do
        if devices_out="$("$openrgb" --client 127.0.0.1:6742 -ld 2>/dev/null)" && [ -n "$devices_out" ]; then
          break
        fi
        sleep 1
      done

      [ -n "$devices_out" ] || exit 0

      cur_id=""
      cur_mode=""
      has_dled=0

      apply_dev() {
        [ -n "$cur_id" ] && [ -n "$cur_mode" ] || return 0
        if [ "$has_dled" -eq 1 ]; then
          "$openrgb" --client 127.0.0.1:6742 -d "$cur_id" \
            -z 0 -sz 60 -z 1 -sz 60 -m "$cur_mode" || true
        else
          "$openrgb" --client 127.0.0.1:6742 -d "$cur_id" \
            -m "$cur_mode" || true
        fi
      }

      while IFS= read -r line; do
        case "$line" in
          [0-9]*:*)
            apply_dev
            cur_id="''${line%%:*}"
            cur_mode=""
            has_dled=0
            ;;
          *"Modes:"*)
            for candidate in "Color Cycle" "Spectrum Cycle" "Spectrum" "Rainbow"; do
              if printf '%s\n' "$line" | ${pkgs.gnugrep}/bin/grep -Fq "$candidate"; then
                cur_mode="$candidate"
                break
              fi
            done
            ;;
          *"Zones:"*)
            if printf '%s\n' "$line" | ${pkgs.gnugrep}/bin/grep -Fq "D_LED1"; then
              has_dled=1
            fi
            ;;
        esac
      done <<LIST_EOF
      $devices_out
      LIST_EOF
      apply_dev
    '';

    resumeScript = pkgs.writeShellScript "openrgb-resume" ''
      set -euo pipefail
      sleep 2
      ${pkgs.systemd}/bin/systemctl restart openrgb.service
      ${pkgs.systemd}/bin/systemctl start openrgb-colorspectrum.service
    '';
  in {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb;
      motherboard = "amd";
    };

    systemd.services.openrgb-colorspectrum = {
      description = "Set all OpenRGB devices to Color Cycle / Spectrum";
      after = ["openrgb.service"];
      requires = ["openrgb.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = setSpectrumScript;
      };
    };

    systemd.services.openrgb-resume = {
      description = "Re-apply OpenRGB Color Cycle after system resume";
      after = ["post-resume.target"];
      wantedBy = ["post-resume.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = resumeScript;
      };
    };
  };
}
