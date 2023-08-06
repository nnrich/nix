{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  nixpkgs.config = { allowUnfree = true; };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".npmrc".text = ''
      prefix = ''${HOME}/.npm-packages
    '';

  };

  home.sessionPath = [ "/home/rcook/.npm-packages/bin" ];

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/rcook/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
    NODE_PATH = /home/rcook/.npm-packages/lib/node_modules;
  };

  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 20;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark-B";
      package = pkgs.tokyo-night-gtk;
    };
  };

  programs.git = {
    enable = true;
    userName = "Richard Cook";
    userEmail = "rcook@flexiant.com";
    package = pkgs.gitAndTools.gitFull;
  };

  services.wlsunset = {
    enable = true;
    latitude = "52.9";
    longitude = "-1.15";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    google-chrome
    font-awesome
    gamescope
    glib
    htop
    hypnotix
    jetbrains.clion
    jetbrains.datagrip
    jetbrains.idea-ultimate
    jetbrains.webstorm
    luarocks
    (lutris.override {
      extraLibraries = pkgs: [ libassuan libgpg-error ];
      extraPkgs = pkgs: [ flatpak ];
    })
    mpv
    nixfmt
    nodejs
    pamixer
    pavucontrol
    lua-language-server
    electron
    ripgrep
    runescape
    slack
    slurp
    tigervnc
    tree
    unzip
    vscode
    winetricks
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override {
      fonts = [ "FantasqueSansMono" "JetBrainsMono" "FiraCode" ];
    })
    (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1v" ];

  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

    shellAliases = {
      "chrome-debug" =
        "google-chrome-stable --disable-web-security --user-data-dir=$HOME/tmp/chromium";
      ll = "ls -l";
      ha = "history 0 | grep ";
      nrs = "sudo nixos-rebuild switch --flake ~/nix/config";
    };

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      extended = true;
      save = 50000;
    };

  };

  programs.java = {
    package = pkgs.jdk17;
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-jdtls
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lsp
      cmp-nvim-lua
      cmp-path
      cmp_luasnip
      comment-nvim
      friendly-snippets
      gruvbox-material
      harpoon
      lsp-zero-nvim
      luasnip
      neodev-nvim
      neotest
      neotest-plenary
      neotest-vitest
      neotest-rust
      null-ls-nvim
      nvim-cmp
      nvim-dap
      nvim-dap-ui
      nvim-lspconfig
      nvim-treesitter-context
      nvim-treesitter.withAllGrammars
      playground
      plenary-nvim
      refactoring-nvim
      rose-pine
      telescope-nvim
      undotree
      vim-fugitive
    ];
  };

  xdg.configFile."nvim".source = ./config/nvim;
  xdg.configFile."hypr".source = ./config/hypr;
  xdg.configFile."kitty".source = ./config/kitty;

  programs.gh.enable = true;
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });
    settings = [{
      layer = "top";
      height = 30;
      margin = "5";
      position = "top";
      modules-left = [ "wlr/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "memory"
        "cpu"
        "battery"
        "pulseaudio"
        "pulseaudio#microphone"
        "network"
      ];

      # modules

      "battery" = {
        "states" = {
          # "good"= 95;
          "warning" = 30;
          "critical" = 15;
        };
        "format" = "{capacity}% {icon}";
        "format-charging" = " {capacity}%";
        "format-plugged" = " {capacity}%";
        # "format-good"= "", # An empty format will hide the module
        # "format-full"= "";
        "format-icons" = [ "" "" "" "" "" ];
      };

      "clock" = {
        "interval" = 10;
        "format" = "{:%e %b %Y %H:%M}";
        "tooltip-format" = "{:%e %B %Y}";
      };

      "cpu" = {
        "interval" = 5;
        "format" = " {usage}% ({load})"; # Icon= microchip
        "states" = {
          "warning" = 70;
          "critical" = 90;
        };
        "on-click" = "kitty -e 'btm'";
      };

      "memory" = {
        "interval" = 5;
        "format" = " {}%"; # Icon= memory
        "on-click" = "kitty -e 'btm'";
        "states" = {
          "warning" = 70;
          "critical" = 90;
        };
      };

      "network" = {
        "interval" = 5;
        "format-wifi" = " "; # Icon= wifi
        "format-ethernet" = " "; # Icon= ethernet
        "format-disconnected" = "⚠  Disconnected";
        "tooltip-format" = "{ifname}= {ipaddr}";
        "on-click" = "kitty -e 'nmtui'";
      };
      "network#vpn" = {
        "interface" = "tun0";
        "format" = " ";
        "format-disconnected" = "⚠  Disconnected";
        "tooltip-format" = "{ifname}= {ipaddr}/{cidr}";
      };

      "hyprland/mode" = {
        "format" = "{}";
        "tooltip" = false;
      };

      "hyprland/window" = {
        "format" = "{}";
        "max-length" = 120;
      };

      "wlr/workspaces" = {
        "disable-markup" = false;
        "all-outputs" = true;
        "format" = "{name}";
        "on-scroll-up" = "hyprctl dispatch workspae e+1";
        "on-scroll-down" = "hyprctl dispatch workspae e-1";
        "on-click" = "activate";
        #"format"="{icon}";
      };

      "pulseaudio" = {
        "scroll-step" = 1; # %, can be a float
        "format" = "{icon} {volume}%";
        "format-bluetooth" = "{volume}% {icon}  {format_source}";
        "format-bluetooth-muted" = " {icon}  {format_source}";
        "format-muted" = " ";
        "format-icons" = {
          "headphone" = "";
          "hands-free" = "וֹ";
          "headset" = "  ";
          "phone" = "";
          "portable" = "";
          "car" = "";
          "default" = [ "" ];
        };
        "on-click" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "on-click-right" = "pavucontrol";
        "on-scroll-up" = "pactl set-sink-volume @DEFAULT_SINK@ +2%";
        "on-scroll-down" = "pactl set-sink-volume @DEFAULT_SINK@ -2%";
      };

      "pulseaudio#microphone" = {
        "format" = "{format_source}";
        "format-source" = " {volume}%";
        "format-source-muted" = "";
        "on-click" = "pamixer --default-source -t";
        "on-click-right" = "pavucontrol";
        "on-scroll-up" = "pamixer --default-source -i 5";
        "on-scroll-down" = "pamixer --default-source -d 5";
        "scroll-step" = 5;
      };

      "custom/weather" = {
        "exec" = "~/.config/waybar/scripts/weather.sh tampa";
        "return-type" = "json";
        "interval" = 600;
      };

      "tray" = {
        "icon-size" = 18;
        "spacing" = 10;
      };

      "backlight#icon" = {
        "format" = "{icon}";
        "format-icons" = [ "" ];
        "on-scroll-down" = "brightnessctl -c backlight set 1%-";
        "on-scroll-up" = "brightnessctl -c backlight set +1%";
      };

      "backlight#value" = {
        "format" = "{percent}%";
        "on-scroll-down" = "brightnessctl -c backlight set 1%-";
        "on-scroll-up" = "brightnessctl -c backlight set +1%";
      };

      "custom/firefox" = {
        "format" = " ";
        "on-click" = "exec firefox";
        "tooltip" = false;
      };

      "custom/terminal" = {
        "format" = " ";
        "on-click" = "exec kitty";
        "tooltip" = false;
      };

      "custom/files" = {
        "format" = " ";
        "on-click" = "exec nautilus";
        "tooltip" = false;
      };

      "custom/launcher" = {
        "format" = " ";
        "on-click" = "exec wofi -c ~/.config/wofi/config -I";
        "tooltip" = false;
      };

      "custom/power" = {
        "format" = "⏻";
        "on-click" = "exec ~/.config/waybar/scripts/power-menu.sh";
        "tooltip" = false;
      };

    }];
    style = ''
      /* =============================================================================
       *
       * Waybar configuration
       *
       * Configuration reference: https://github.com/Alexays/Waybar/wiki/Configuration
       *
       * =========================================================================== */

      /* -----------------------------------------------------------------------------
       * Keyframes
       * -------------------------------------------------------------------------- */

      /*
      Arc-Dark Color Scheme
      */
      @keyframes blink-warning {
          70% {
              color: white;
      }

          to {
              color: white;
              background-color: orange;
          }
      }

      @keyframes blink-critical {
          70% {
            color: white;
          }

          to {
              color: white;
              background-color: red;
          }
      }

      /* -----------------------------------------------------------------------------
       * Base styles
       * -------------------------------------------------------------------------- */

      /* Reset all styles */
      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          margin: 1px;
          padding: 0;
          color: #66ACED;
      }

      /* The whole bar */
      window#waybar {
          /* color: #dfdfdf; */
          /* background-color: rgba(0,0,0,0.8); */
          /* background-color: rgba(8,0,37,0.85); */
          background-color: rgba(0,0,0,0);
          font-family: JetBrains Mono Nerd Font;
          font-size: 14px;
          /* border-radius: 22px; */
      }

      /* Every modules */
      #battery,
      #clock,
      #backlight,
      #cpu,
      #custom-keyboard-layout,
      #memory,
      #mode,
      #custom-weather,
      #network,
      #pulseaudio,
      #temperature,
      #tray,
      #idle_inhibitor,
      #window,
      #custom-power,
      #workspaces,
      #custom-media,
      #custom-PBPbattery {
          padding:0.25rem 0.75rem;
          margin: 1px 6px;
          background-color: rgba(0,0,0,0.8);
          border-radius: 20px;
      }

      /* -----------------------------------------------------------------------------
       * Modules styles
       * -------------------------------------------------------------------------- */

      #clock {
          /* color: #ff4499; */
          color: #73daca;
      }

      #custom-weather {
          color: #ff4499;
      }

      #battery {
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #battery.warning {
          color: orange;
      }

      #battery.critical {
          color: red;
      }

      #battery.warning.discharging {
          animation-name: blink-warning;
          animation-duration: 3s;
      }

      #battery.critical.discharging {
          animation-name: blink-critical;
          animation-duration: 2s;
      }

      #cpu {
          color: #f7768e;
      }

      #cpu.warning {
          color: orange;
      }

      #cpu.critical {
          color: red;
      }

      #memory {
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
          color: #f7768e;
      }

      #memory.warning {
          color: orange;
       }

      #memory.critical {
          color: red;
          animation-name: blink-critical;
          animation-duration: 2s;
          padding-left:5px;
          padding-right:5px;
      }

      #mode {
          /* background: @highlight; */
          /* background: #dfdfdf; */
          border-bottom: 3px transparent;
          color:#ff4499;
          margin-left: 5px;
          padding: 7px;
      }

      #network.disconnected {
          color: orange;
      }

      #pulseaudio {
          color: #bb9af7;
          border-left: 0px;
          border-right: 0px;
          margin-right: 0;
          border-radius: 20px 0 0 20px;
      }

      /* #pulseaudio.muted { */
      /*     color: #ff4499; */
      /* } */
      /**/
      #pulseaudio.microphone {
          border-left: 0px;
          border-right: 0px;
          margin-left: 0;
          padding-left: 0;
          border-radius: 0 20px 20px 0;
      }

      /* #pulseaudio.microphone.muted { */
      /*     color: #ff4499; */
      /* } */


      #temperature.critical {
          color: red;
      }

      #window {
          font-weight: bold;
          color: #f7768e;
      }

      #custom-media {
          color: #bb9af7;
      }

      #workspaces {
          font-size:16px;
          background-color: rgba(0,0,0,0.8);
          border-radius: 20px;
      }

      #workspaces button {
          border-bottom: 3px solid transparent;
          margin-bottom: 0px;
          color: #dfdfdf;
      }

      #workspaces button.active {
          border-bottom: 1px solid  #ff4499;
          margin-bottom: 1px;
          padding-left:0;
      }

      #workspaces button.urgent {
          border-color: #c9545d;
          color: #c9545d;
      }

      #custom-power {
          font-size:18px;
          padding-right: 1rem;
      }

      #custom-launcher {
          font-size:15px;
          margin-left:15px;
          margin-right:10px;
      }

      #backlight.icon {
          padding-right:1px;
          font-size: 13px;
      }
    '';
  };
}

