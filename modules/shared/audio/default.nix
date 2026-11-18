_: {
  flake.nixosModules.audio =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;

      easyeffectsWrapped = pkgs.symlinkJoin {
        name = "easyeffects-${pkgs.easyeffects.version}";
        inherit (pkgs.easyeffects) version;
        paths = [ pkgs.easyeffects ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm -f $out/bin/easyeffects
          makeWrapper ${pkgs.easyeffects}/bin/easyeffects \
            $out/bin/easyeffects \
            --unset QT_STYLE_OVERRIDE \
            --unset QT_QUICK_CONTROLS_STYLE
          if [ -d "$out/share/applications" ]; then
            rm -rf "$out/share/applications"
            mkdir -p "$out/share/applications"
            for f in ${pkgs.easyeffects}/share/applications/*.desktop; do
              substitute "$f" "$out/share/applications/$(basename "$f")" \
                --replace-quiet \
                "${pkgs.easyeffects}/bin/easyeffects" \
                "$out/bin/easyeffects"
            done
          fi
        '';
      };

      mkBand = frequency: q: gain: {
        inherit frequency q gain;
        mode = "APO (DR)";
        type = "Bell";
        slope = "x1";
        mute = false;
        solo = false;
        width = 4.0;
      };

      eqBands = {
        band0 = mkBand 20.0 1.1 2.0;
        band1 = mkBand 170.0 0.5 (-2.9);
        band2 = mkBand 590.0 0.9 5.6;
        band3 = mkBand 1600.0 2.0 (-6.2);
        band4 = mkBand 2800.0 2.0 5.8;
        band5 = mkBand 3700.0 1.9 (-2.8);
        band6 = mkBand 5400.0 1.3 (-4.4);
        band7 = mkBand 14000.0 2.0 (-6.4);
      };

      micPreset = builtins.toJSON {
        input = {
          blocklist = [ ];
          plugins_order = [
            "rnnoise#0"
            "deepfilternet#0"
            "autogain#0"
            "autotune#0"
          ];
          "rnnoise#0" = {
            bypass = false;
          };
          "deepfilternet#0" = {
            bypass = false;
          };
          "autogain#0" = {
            bypass = false;
          };
          "autotune#0" = {
            bypass = false;
          };
        };
      };

      phoenixCallPreset = builtins.toJSON {
        output = {
          blocklist = [ ];
          plugins_order = [ "equalizer#0" ];
          "equalizer#0" = {
            balance = 0.0;
            bypass = false;
            decramp = "Off";
            input-gain = -4.5;
            output-gain = 0.0;
            mode = "IIR";
            num-bands = 8;
            pitch-left = 0.0;
            pitch-right = 0.0;
            split-channels = false;
            left = eqBands;
            right = eqBands;
          };
        };
      };
    in
    {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      hardware.firmware = with pkgs; [
        sof-firmware
        alsa-firmware
      ];

      home-manager.users.${user} = {
        services.easyeffects = {
          enable = true;
          package = easyeffectsWrapped;
          settings = {
            EffectsPipelines = {
              bypass = false;
              processAllInputs = true;
              processAllOutputs = true;
            };
            StreamInputs = {
              listenToMic = false;
              plugins = "rnnoise#0,deepfilternet#0,autogain#0,autotune#0";
            };
            StreamOutputs = {
              useDefaultOutputDevice = true;
              plugins = "equalizer#0";
            };
            Window = {
              enableServiceMode = true;
              inputAutoloadingUsesFallback = true;
              inputAutoloadingFallbackPreset = "Mic";
              outputAutoloadingUsesFallback = true;
              outputAutoloadingFallbackPreset = "PhoenixCall";
              lastLoadedInputPreset = "Mic";
              lastLoadedOutputPreset = "PhoenixCall";
            };
          };
        };

        systemd.user.services.easyeffects = {
          Unit = {
            After = lib.mkForce [
              "graphical-session.target"
              "pipewire.service"
              "wireplumber.service"
            ];
            Wants = [
              "pipewire.service"
              "wireplumber.service"
            ];
          };
        };

        xdg.dataFile."easyeffects/input/Mic.json" = {
          text = micPreset;
          force = true;
        };

        xdg.dataFile."easyeffects/output/PhoenixCall.json" = {
          text = phoenixCallPreset;
          force = true;
        };

        xdg.dataFile."color-schemes/CatppuccinMocha.colors" = {
          text = ''
            [General]
            ColorScheme=CatppuccinMocha
            Name=Catppuccin Mocha

            [Colors:Window]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=24,24,37
            ForegroundInactive=108,112,134

            [Colors:View]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=49,50,68
            ForegroundInactive=108,112,134

            [Colors:Button]
            BackgroundNormal=49,50,68
            ForegroundNormal=205,214,244
            BackgroundAlternate=69,71,90

            [Colors:Selection]
            BackgroundNormal=203,166,247
            ForegroundNormal=17,17,27

            [Colors:Tooltip]
            BackgroundNormal=24,24,37
            ForegroundNormal=205,214,244
          '';
          force = true;
        };

        xdg.configFile."kdeglobals" = {
          text = ''
            [General]
            ColorScheme=CatppuccinMocha
            Name=Catppuccin Mocha

            [Colors:Window]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=24,24,37

            [Colors:View]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=49,50,68

            [Colors:Button]
            BackgroundNormal=49,50,68
            ForegroundNormal=205,214,244

            [Colors:Selection]
            BackgroundNormal=203,166,247
            ForegroundNormal=17,17,27
          '';
          force = false;
        };
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        cava
      ];
    };
}
