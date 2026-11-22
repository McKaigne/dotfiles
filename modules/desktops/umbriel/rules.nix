let
  style = import ../../appearance/_style.nix;
in {
  flake.modules.homeManager."desktop-umbriel" = {pkgs, ...}: let
    # Unfocused windows recede: darker and more see-through. Samples are
    # premultiplied, so fading scales color and alpha together.
    fade = toString style.unfocusedOpacity;
    darken = pkgs.writeText "unfocused-darken.glsl" ''
      vec4 window(vec2 uv) {
        vec4 c = umbriel_sample(uv);
        return vec4(c.rgb * ${toString (1.0 - style.unfocusedDim)}, c.a) * ${fade};
      }
    '';
    # Helium stays solid: undo the translucency it picks up from the GTK glass
    # while keeping its theme colors. Faint pixels (shadows, antialiased
    # corners) are left alone so they don't turn into hard dark edges.
    solid = dim: alpha:
      pkgs.writeText "solid.glsl" ''
        vec4 window(vec2 uv) {
          vec4 c = umbriel_sample(uv);
          if (c.a < 0.3) return c * ${alpha};
          return vec4(c.rgb / c.a * ${toString dim}, 1.0) * ${alpha};
        }
      '';
  in {
    programs.umbriel.settings.effects.preset = {
      unfocused-darken = {
        kind = "window";
        shader = "${darken}";
      };
      solid = {
        kind = "window";
        shader = "${solid "1.0" "1.0"}";
      };
      solid-darken = {
        kind = "window";
        shader = "${solid (toString (1.0 - style.unfocusedDim)) fade}";
      };
    };

    programs.umbriel.settings = {
      layer_rule = [
        {
          match.namespace = ''^noctalia-(bar-[^"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^"]*)$'';
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_popups = true;
        }
        # Optimized blur reuses a cached blur of the wallpaper alone, so anything
        # that opens over windows would show the wallpaper instead of them. Blur
        # the live content behind panels, notifications and OSDs; the bar only
        # ever covers the wallpaper and keeps the cheap path.
        {
          match.namespace = "^noctalia-(notification|panel|attached-panel|osd)$";
          blur_optimized = false;
        }
      ];

      window_rule = [
        # Blur behind every window; it only shows where an app draws a translucent background.
        {
          match.app_id = ".*";
          blur = true;
        }
        {
          match.is_focused = false;
          window_effect = "unfocused-darken";
        }
        {
          match.app_id = "^helium$";
          window_effect = "solid";
        }
        {
          match = {
            app_id = "^helium$";
            is_focused = false;
          };
          window_effect = "solid-darken";
        }
        # {
        #   match.app_id = "^(steam_app_[0-9]+|gamescope)$";
        #   hdr = "on";
        # }
        # {
        #   match.app_id = "^Minecraft[*]$";
        #   hdr = "fullscreen";
        # }
        {
          match.app_id = "^helium$";
          default_maximize = true;
        }
        {
          match.title = "^(Picture-in-Picture|Picture in picture)$";
          default_floating = true;
          default_maximize = false;
          default_position = {
            x = 20;
            y = 20;
            anchor = "bottom_right";
          };
        }

        {
          match.app_id = "^dev\\.noctalia\\.UmbrielSharePicker$";
          default_floating = true;
          default_floating_size_px = {
            width = 800;
            height = 600;
          };
        }
      ];
    };
  };
}
