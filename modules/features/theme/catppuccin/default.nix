{ self, inputs, ... }: {
  flake.nixosModules.catppuccinTheme =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      p = config.palette;

      bibataCursorsFixed = pkgs.runCommand "bibata-modern-classic-fixed" { } ''
        mkdir -p $out/share/icons
        cp -r ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic $out/share/icons/Bibata-Modern-Classic
        chmod -R u+w $out/share/icons/Bibata-Modern-Classic
        cd $out/share/icons/Bibata-Modern-Classic/cursors
        [ -e hand2 ] || ln -sf pointer hand2
        [ -e sb_v_double_arrow ] || ln -sf ns-resize sb_v_double_arrow
        [ -e sb_h_double_arrow ] || ln -sf ew-resize sb_h_double_arrow
      '';
    in
    {
      home-manager.users.${user} = {
        gtk = {
          enable = true;
          theme = {
            name = "adw-gtk3-dark";
            package = pkgs.adw-gtk3;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
          font = {
            name = "Atkinson Hyperlegible";
            size = 11;
            package = pkgs.atkinson-hyperlegible;
          };
          gtk4.theme = null;
        };

        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Papirus-Dark";
          font-name = "Atkinson Hyperlegible 11";
          document-font-name = "Atkinson Hyperlegible 11";
          monospace-font-name = "AtkynsonMono Nerd Font 12";
        };

        # 1. Btop Transparent Theme
        programs.btop = {
          enable = true;
          settings = {
            color_theme = "catppuccin_mocha";
            theme_background = false;
            truecolor = true;
            vim_keys = true;
            rounded_corners = true;
            graph_symbol = "braille";
          };
        };

        xdg.configFile."btop/themes/catppuccin_mocha.theme" = {
          text = ''
            theme[main_bg]=""
            theme[main_fg]="${p.text}"
            theme[title]="${p.mauve}"
            theme[hi_fg]="${p.mauve}"
            theme[selected_bg]="${p.surface0}"
            theme[selected_fg]="${p.text}"
            theme[inactive_fg]="${p.overlay0}"
            theme[graph_text]="${p.subtext0}"
            theme[meter_bg]="${p.surface0}"
            theme[proc_misc]="${p.rosewater}"
            theme[cpu_box]="${p.mauve}"
            theme[mem_box]="${p.green}"
            theme[net_box]="${p.peach}"
            theme[proc_box]="${p.blue}"
            theme[div_line]="${p.surface0}"
            theme[temp_start]="${p.green}"
            theme[temp_mid]="${p.yellow}"
            theme[temp_end]="${p.red}"
            theme[cpu_start]="${p.teal}"
            theme[cpu_mid]="${p.yellow}"
            theme[cpu_end]="${p.red}"
            theme[free_start]="${p.mauve}"
            theme[free_mid]="${p.blue}"
            theme[free_end]="${p.sapphire}"
            theme[cached_start]="${p.sapphire}"
            theme[cached_mid]="${p.blue}"
            theme[cached_end]="${p.lavender}"
            theme[available_start]="${p.peach}"
            theme[available_mid]="${p.yellow}"
            theme[available_end]="${p.green}"
            theme[used_start]="${p.green}"
            theme[used_mid]="${p.yellow}"
            theme[used_end]="${p.red}"
            theme[download_start]="${p.teal}"
            theme[download_mid]="${p.blue}"
            theme[download_end]="${p.lavender}"
            theme[upload_start]="${p.yellow}"
            theme[upload_mid]="${p.peach}"
            theme[upload_end]="${p.red}"
            theme[process_start]="${p.blue}"
            theme[process_mid]="${p.mauve}"
            theme[process_end]="${p.pink}"
          '';
          force = true;
        };

        # 2. Television Catppuccin Mocha Configuration
        xdg.configFile."television/config.toml" = {
          text = ''
            theme = "catppuccin-mocha"
            tick_rate = 50
          '';
          force = true;
        };

        xdg.configFile."television/themes/catppuccin-mocha.toml" = {
          text = ''
            [theme]
            name = "catppuccin-mocha"

            [ui]
            background = "reset"
            border = "${p.mauve}"
            title = "${p.text}"
            prompt = "${p.mauve}"
            input = "${p.text}"
            selected = "${p.surface0}"
            match = "${p.mauve}"
            preview_border = "${p.surface2}"
            help = "${p.subtext0}"
            status = "${p.blue}"
          '';
          force = true;
        };

        # 3. Atuin Catppuccin Mocha Configuration
        xdg.configFile."atuin/themes/catppuccin-mocha.toml" = {
          text = ''
            [theme]
            name = "catppuccin-mocha"

            [colors]
            Alert = "${p.red}"
            Base = "${p.base}"
            Error = "${p.red}"
            Guidance = "${p.subtext0}"
            Important = "${p.peach}"
            Info = "${p.blue}"
            Muted = "${p.overlay0}"
            Success = "${p.green}"
            Warning = "${p.yellow}"
            Annotation = "${p.mauve}"
          '';
          force = true;
        };

        # 4. LazyGit Transparent Catppuccin Mocha
        xdg.configFile."lazygit/config.yml" = {
          text = ''
            gui:
              theme:
                activeBorderColor:
                  - '${p.mauve}'
                  - bold
                inactiveBorderColor:
                  - '${p.surface2}'
                searchingActiveBorderColor:
                  - '${p.yellow}'
                  - bold
                optionsTextColor:
                  - '${p.blue}'
                selectedLineBgColor:
                  - '${p.surface0}'
                inactiveViewSelectedLineBgColor:
                  - '${p.surface0}'
                cherryPickedCommitFgColor:
                  - '${p.blue}'
                cherryPickedCommitBgColor:
                  - '${p.surface1}'
                markedBaseCommitFgColor:
                  - '${p.blue}'
                markedBaseCommitBgColor:
                  - '${p.peach}'
                unstagedChangesColor:
                  - '${p.red}'
                defaultFgColor:
                  - '${p.text}'
          '';
          force = true;
        };

        # 5. LazyDocker Transparent Catppuccin Mocha
        xdg.configFile."lazydocker/config.yml" = {
          text = ''
            gui:
              theme:
                activeBorderColor:
                  - '${p.mauve}'
                  - bold
                inactiveBorderColor:
                  - '${p.surface2}'
                selectedLineBgColor:
                  - '${p.surface0}'
                optionsTextColor:
                  - '${p.blue}'
          '';
          force = true;
        };

        # 6. Glow Catppuccin Mocha Style
        xdg.configFile."glow/styles/catppuccin-mocha.json" = {
          text = builtins.toJSON {
            document = {
              block_prefix = "\n";
              block_suffix = "\n";
              color = p.text;
            };
            block_quote = {
              color = p.subtext0;
              indent = 1;
              indent_token = "│ ";
            };
            heading = {
              block_suffix = "\n";
              color = p.mauve;
              bold = true;
            };
            h1 = {
              prefix = "# ";
              color = p.mauve;
              bold = true;
            };
            h2 = {
              prefix = "## ";
              color = p.blue;
              bold = true;
            };
            h3 = {
              prefix = "### ";
              color = p.lavender;
              bold = true;
            };
            h4 = {
              prefix = "#### ";
              color = p.teal;
            };
            h5 = {
              prefix = "##### ";
              color = p.green;
            };
            h6 = {
              prefix = "###### ";
              color = p.yellow;
            };
            strong = {
              bold = true;
              color = p.peach;
            };
            horizontal_rule = {
              color = p.surface2;
              format = "--------\n";
            };
            code = {
              color = p.peach;
              background_color = p.crust;
            };
            code_block = {
              color = p.text;
              background_color = p.crust;
              chroma = {
                text = { color = p.text; };
                error = { color = p.red; background_color = p.crust; };
                comment = { color = p.overlay0; italic = true; };
                keyword = { color = p.mauve; bold = true; };
                operator = { color = p.sky; };
                punctuation = { color = p.overlay1; };
                name = { color = p.text; };
                name_builtin = { color = p.blue; };
                name_tag = { color = p.blue; };
                name_attribute = { color = p.peach; };
                name_class = { color = p.yellow; };
                name_constant = { color = p.peach; };
                name_function = { color = p.blue; };
                literal_number = { color = p.peach; };
                literal_string = { color = p.green; };
                literal_string_escape = { color = p.pink; };
              };
            };
            link = {
              color = p.blue;
              underline = true;
            };
            link_text = {
              color = p.sapphire;
              bold = true;
            };
          };
          force = true;
        };

        xdg.configFile."glow/glow.yml" = {
          text = ''
            style: "catppuccin-mocha"
            mouse: true
            pager: true
            width: 100
          '';
          force = true;
        };

        # 7. Procs Catppuccin Mocha Configuration
        xdg.configFile."procs/config.toml" = {
          text = ''
            [style]
            header = "BrightMagenta"
            unit = "BrightBlack"

            [[columns]]
            kind = "Pid"
            style = "BrightGreen"

            [[columns]]
            kind = "User"
            style = "BrightBlue"

            [[columns]]
            kind = "CpuTime"
            style = "BrightYellow"

            [[columns]]
            kind = "Command"
            style = "BrightWhite"
          '';
          force = true;
        };

        # 8. Cava Transparent Gradient
        xdg.configFile."cava/config" = {
          text = ''
            [general]
            framerate = 60
            autosens = 1
            bars = 0
            bar_width = 2
            bar_spacing = 1

            [color]
            gradient = 1
            gradient_color_1 = '${p.blue}'
            gradient_color_2 = '${p.mauve}'
            gradient_color_3 = '${p.pink}'
            gradient_color_4 = '${p.red}'
          '';
          force = true;
        };

        # 9. Bat Configuration
        xdg.configFile."bat/config" = {
          text = ''
            --theme="Catppuccin Mocha"
            --style="numbers,changes,header"
          '';
          force = true;
        };

        # 10. KDE / Kirigami Color Scheme
        xdg.dataFile."color-schemes/CatppuccinMocha.colors" = {
          text = ''
            [General]
            ColorScheme=CatppuccinMocha
            Name=Catppuccin Mocha
            shadeSortColumn=true

            [Colors:Window]
            BackgroundNormal=30,30,46
            BackgroundAlternate=24,24,37
            ForegroundNormal=205,214,244
            ForegroundInactive=108,112,134
            ForegroundActive=203,166,247
            ForegroundLink=137,180,250
            ForegroundVisited=180,190,254
            ForegroundNegative=243,139,168
            ForegroundNeutral=250,179,135
            ForegroundPositive=166,227,161

            [Colors:View]
            BackgroundNormal=30,30,46
            BackgroundAlternate=24,24,37
            ForegroundNormal=205,214,244
            ForegroundInactive=108,112,134
            ForegroundActive=203,166,247
            ForegroundLink=137,180,250
            ForegroundVisited=180,190,254
            ForegroundNegative=243,139,168
            ForegroundNeutral=250,179,135
            ForegroundPositive=166,227,161

            [Colors:Button]
            BackgroundNormal=49,50,68
            BackgroundAlternate=69,71,90
            ForegroundNormal=205,214,244
            ForegroundInactive=108,112,134
            ForegroundActive=203,166,247
            ForegroundLink=137,180,250
            ForegroundVisited=180,190,254
            ForegroundNegative=243,139,168
            ForegroundNeutral=250,179,135
            ForegroundPositive=166,227,161

            [Colors:Selection]
            BackgroundNormal=203,166,247
            BackgroundAlternate=180,190,254
            ForegroundNormal=17,17,27
            ForegroundInactive=17,17,27
            ForegroundActive=17,17,27

            [Colors:Tooltip]
            BackgroundNormal=24,24,37
            ForegroundNormal=205,214,244
          '';
          force = true;
        };

        xdg.configFile."gtk-3.0/gtk.css" = {
          text = ''
            @define-color accent_color ${p.mauve};
            @define-color accent_bg_color ${p.mauve};
            @define-color accent_fg_color ${p.crust};

            @define-color destructive_bg_color ${p.red};
            @define-color destructive_fg_color ${p.crust};

            @define-color error_bg_color ${p.red};
            @define-color error_fg_color ${p.crust};

            @define-color window_bg_color ${p.base};
            @define-color window_fg_color ${p.text};

            @define-color view_bg_color ${p.base};
            @define-color view_fg_color ${p.text};

            @define-color headerbar_bg_color ${p.base};
            @define-color headerbar_fg_color ${p.text};
            @define-color headerbar_backdrop_color @window_bg_color;

            @define-color popover_bg_color ${p.surface0};
            @define-color popover_fg_color ${p.text};

            @define-color card_bg_color ${p.surface0};
            @define-color card_fg_color ${p.text};

            @define-color dialog_bg_color ${p.base};
            @define-color dialog_fg_color ${p.text};

            @define-color sidebar_bg_color ${p.mantle};
            @define-color sidebar_fg_color ${p.text};

            headerbar windowcontrols,
            headerbar button.close,
            tab button.close,
            button.close {
              display: none;
              margin: 0;
              padding: 0;
            }

            .pcmanfm-sidebar,
            pcmanfm frame,
            pcmanfm treeview {
              border: none;
              box-shadow: none;
            }

            pcmanfm treeview {
              padding: 2px 4px;
            }
          '';
          force = true;
        };

        xdg.configFile."gtk-4.0/gtk.css" = {
          text = ''
            @define-color accent_color ${p.mauve};
            @define-color accent_bg_color ${p.mauve};
            @define-color accent_fg_color ${p.crust};

            @define-color destructive_bg_color ${p.red};
            @define-color destructive_fg_color ${p.crust};

            @define-color error_bg_color ${p.red};
            @define-color error_fg_color ${p.crust};

            @define-color window_bg_color ${p.base};
            @define-color window_fg_color ${p.text};

            @define-color view_bg_color ${p.base};
            @define-color view_fg_color ${p.text};

            @define-color headerbar_bg_color ${p.base};
            @define-color headerbar_fg_color ${p.text};
            @define-color headerbar_backdrop_color @window_bg_color;

            @define-color popover_bg_color ${p.surface0};
            @define-color popover_fg_color ${p.text};

            @define-color card_bg_color ${p.surface0};
            @define-color card_fg_color ${p.text};

            @define-color dialog_bg_color ${p.base};
            @define-color dialog_fg_color ${p.text};

            @define-color sidebar_bg_color ${p.mantle};
            @define-color sidebar_fg_color ${p.text};

            headerbar windowcontrols,
            headerbar button.close,
            tab button.close,
            button.close {
              display: none;
              margin: 0;
              padding: 0;
            }
          '';
          force = true;
        };

        xdg.configFile."qt6ct/qt6ct.conf" = {
          text = ''
            [Appearance]
            color_scheme_path=/home/${user}/.config/qt6ct/colors/catppuccin.conf
            custom_palette=true
            icon_theme=Papirus-Dark
            standard_dialogs=default
            style=Adwaita-Dark

            [Fonts]
            fixed="AtkynsonMono Nerd Font,12,-1,5,50,0,0,0,0,0"
            general="Atkinson Hyperlegible,11,-1,5,50,0,0,0,0,0"
          '';
          force = true;
        };

        xdg.configFile."qt5ct/qt5ct.conf" = {
          text = ''
            [Appearance]
            color_scheme_path=/home/${user}/.config/qt5ct/colors/catppuccin.conf
            custom_palette=true
            icon_theme=Papirus-Dark
            standard_dialogs=default
            style=Adwaita-Dark

            [Fonts]
            fixed="AtkynsonMono Nerd Font,12,-1,5,50,0,0,0,0,0"
            general="Atkinson Hyperlegible,11,-1,5,50,0,0,0,0,0"
          '';
          force = true;
        };

        xdg.configFile."qt6ct/colors/catppuccin.conf" = {
          text = ''
            [ColorScheme]
            active_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
            disabled_colors=${p.overlay0}, ${p.mantle}, ${p.surface0}, ${p.mantle}, ${p.crust}, ${p.surface1}, ${p.overlay0}, ${p.rosewater}, ${p.overlay0}, ${p.base}, ${p.base}, ${p.crust}, ${p.surface1}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.overlay0}, ${p.surface1}, ${p.mauve}
            inactive_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
          '';
          force = true;
        };

        xdg.configFile."qt5ct/colors/catppuccin.conf" = {
          text = ''
            [ColorScheme]
            active_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
            disabled_colors=${p.overlay0}, ${p.mantle}, ${p.surface0}, ${p.mantle}, ${p.crust}, ${p.surface1}, ${p.overlay0}, ${p.rosewater}, ${p.overlay0}, ${p.base}, ${p.base}, ${p.crust}, ${p.surface1}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.overlay0}, ${p.surface1}, ${p.mauve}
            inactive_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
          '';
          force = true;
        };
      };

      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "adwaita-dark";
      };

      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Classic";
        XCURSOR_SIZE = "16";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };

      environment.systemPackages = with pkgs; [
        adw-gtk3
        papirus-icon-theme
        bibataCursorsFixed
        atkinson-hyperlegible
        kdePackages.qt6ct
      ];
    };
}
