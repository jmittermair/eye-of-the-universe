{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      mango = inputs.mango.packages.x86_64-linux.mango;
      session = pkgs.writeShellScript "mango-session" ''
        export XDG_CURRENT_DESKTOP=mango
        export XDG_SESSION_DESKTOP=mango
        export XDG_SESSION_TYPE=wayland
        trap 'systemctl --user stop mango-session.target graphical-session.target' EXIT
        ${mango}/bin/mango
      '';
    in
    {
      imports = [ inputs.mango.nixosModules.mango ];
      programs.mango.enable = true;
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${session}";
          user = "greeter";
        };
      };
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.swaylock = { };
      security.polkit.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      environment.systemPackages = with pkgs; [
        nautilus
        gnome-keyring
      ];
      xdg.portal.wlr.settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };

  flake.modules.homeManager.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      noctalia = lib.getExe config.programs.noctalia.package;
      clipboard = pkgs.writeShellApplication {
        name = "clipboard-pick";
        runtimeInputs = with pkgs; [
          cliphist
          wl-clipboard
        ];
        text = ''
          entry=$(cliphist list | ${noctalia} dmenu --prompt "Clipboard") || exit 0
          [ -n "$entry" ] || exit 0
          printf '%s' "$entry" | cliphist decode | wl-copy
        '';
      };
      screenshot = pkgs.writeShellApplication {
        name = "screenshot";
        runtimeInputs = with pkgs; [
          grim
          slurp
          satty
          coreutils
          wl-clipboard
        ];
        text = ''
          geometry=$(slurp) || exit 0
          mkdir -p "$HOME/Pictures/Screenshots"
          grim -g "$geometry" - | satty --filename - --copy-command wl-copy \
            --output-filename "$HOME/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"
        '';
      };
    in
    {
      imports = [
        inputs.mango.hmModules.mango
        inputs.noctalia.homeModules.default
      ];
      home.packages = [
        screenshot
        clipboard
        pkgs.awww
        pkgs.wlr-randr
      ];
      wayland.systemd.target = "mango-session.target";
      wayland.windowManager.mango = {
        enable = true;
        systemd.enable = true;
        systemd.xdgAutostart = true;
        # Nonempty autostart is needed for the upstream module to emit exec-once.
        autostart_sh = "true";
        settings = {
          # Keep the panel's native mode; scale the interface, not its resolution.
          # Comma-separated fields are required; "name:eDP-1:width:..." never matches.
          monitorrule = "name:eDP-1,scale:1.5";
          xkb_rules_layout = "us";
          repeat_rate = 35;
          repeat_delay = 300;
          tap_to_click = 1;
          trackpad_natural_scrolling = 1;
          trackpad_disable_while_typing = 1;
          borderpx = 2;
          border_radius = 6;
          cursor_size = 32;
          focused_opacity = 1.0;
          unfocused_opacity = 1.0;
          shadows = 1;
          shadow_only_floating = 1;
          shadows_size = 5;
          shadows_blur = 5;
          gappih = 8;
          gappiv = 8;
          gappoh = 10;
          gappov = 10;
          animations = 1;
          animation_duration_open = 180;
          animation_duration_close = 150;
          animation_duration_move = 180;
          blur = 0;
          focuscolor = "0xcba6f7ff";
          bordercolor = "0x45475aff";
          rootcolor = "0x1e1e2eff";
          tagrule = map (n: "id:${toString n},layout_name:tile") (lib.range 1 9);
          bind = [
            # Application launchers and this configuration's shortcut reference.
            "SUPER,Return,spawn,ghostty"
            "SUPER,space,spawn,${noctalia} msg panel-toggle launcher"
            "ALT,space,spawn,${noctalia} msg panel-toggle launcher"
            "SUPER,e,spawn,nautilus"
            "SUPER,b,spawn,firefox"
            "SUPER,F1,spawn,ghostty -e bat --paging=always --style=plain ${../../SHORTCUTS.md}"

            # Window navigation and layout. Arrow modifiers avoid the lock binding.
            "SUPER,q,killclient"
            "SUPER,f,togglefullscreen"
            "SUPER+SHIFT,space,togglefloating"
            "SUPER,Tab,focusstack,next"
            "SUPER+SHIFT,Tab,focusstack,prev"
            "SUPER,h,focusdir,left"
            "SUPER,j,focusdir,down"
            "SUPER,k,focusdir,up"
            "SUPER,l,focusdir,right"
            "SUPER+SHIFT,Left,exchange_client,left"
            "SUPER+SHIFT,Down,exchange_client,down"
            "SUPER+SHIFT,Up,exchange_client,up"
            "SUPER+SHIFT,Right,exchange_client,right"
            "SUPER+CTRL,Left,resizewin,-50,0"
            "SUPER+CTRL,Right,resizewin,+50,0"
            "SUPER+CTRL,Up,resizewin,0,-50"
            "SUPER+CTRL,Down,resizewin,0,+50"
            "SUPER,backslash,switch_layout"
            "SUPER,o,toggleoverview"
            "SUPER,m,minimized"
            "SUPER+SHIFT,m,restore_minimized"

            # Workspaces and external monitors.
            "SUPER,Left,viewtoleft,0"
            "SUPER,Right,viewtoright,0"
            "SUPER+ALT,Left,focusmon,left"
            "SUPER+ALT,Right,focusmon,right"
            "SUPER+ALT+SHIFT,Left,tagmon,left"
            "SUPER+ALT+SHIFT,Right,tagmon,right"

            # Session and Noctalia v5 IPC. Clipboard remains owned by Cliphist.
            "SUPER+SHIFT,r,reload_config"
            "SUPER+SHIFT,e,quit"
            "SUPER+SHIFT,l,spawn,swaylock -f"
            "SUPER,Escape,spawn,${noctalia} msg panel-toggle session"
            "SUPER,v,spawn,clipboard-pick"
            "SUPER,comma,spawn,${noctalia} msg panel-toggle control-center"
            "SUPER,n,spawn,${noctalia} msg panel-toggle control-center notifications"
            "SUPER,a,spawn,${noctalia} msg panel-toggle control-center audio"
            "SUPER+CTRL,n,spawn,${noctalia} msg notification-clear-active"
            "SUPER+SHIFT,d,spawn,${noctalia} msg notification-dnd-toggle"
            "NONE,Print,spawn,screenshot"
            "SUPER+SHIFT,s,spawn,screenshot"

            # Laptop media keys.
            "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
            "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            "NONE,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            "NONE,XF86MonBrightnessUp,spawn,brightnessctl set +5%"
            "NONE,XF86MonBrightnessDown,spawn,brightnessctl set 5%-"
            "NONE,XF86AudioPlay,spawn,playerctl play-pause"
            "NONE,XF86AudioNext,spawn,playerctl next"
            "NONE,XF86AudioPrev,spawn,playerctl previous"
          ]
          ++ lib.concatMap (n: [
            "SUPER,${toString n},view,${toString n},0"
            "SUPER+SHIFT,${toString n},tag,${toString n},0"
            "SUPER+CTRL+SHIFT,${toString n},tagsilent,${toString n}"
          ]) (lib.range 1 9);
          mousebind = [
            "SUPER,btn_left,moveresize,curmove"
            "SUPER,btn_right,moveresize,curresize"
          ];
        };
      };
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          shell = {
            clipboard_enabled = false;
            font_family = "DejaVu Sans";
            corner_radius_scale = 0.8;
            popup_shadows = true;
            settings_window_translucent = false;
            # Inspired by mikuri12's solid floating panels, with larger controls.
            panel = {
              transparency_mode = "solid";
              launcher_placement = "floating";
              control_center_placement = "floating";
              session_placement = "floating";
            };
            launcher = {
              compact = true;
              categories = false;
              show_app_origin_indicator = false;
            };
          };
          accessibility.ui_scale = 1.1;
          bar.default.enabled = false;
          bar.main.enabled = false;
          dock.enabled = false;
          wallpaper.enabled = false;
          nightlight.enabled = false;
          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Catppuccin";
            templates = {
              enable_builtin_templates = false;
              enable_community_templates = false;
            };
          };
        };
      };
      programs.waybar = {
        enable = true;
        systemd = {
          enable = true;
          targets = [ "mango-session.target" ];
        };
        # Own Waybar's CSS here so spacing and contrast are consistent with Noctalia.
        style = ''
          * {
            font-family: "DejaVu Sans", "Symbols Nerd Font Mono";
            font-size: 16px;
            border: none;
            border-radius: 0;
            min-height: 0;
          }
          window#waybar {
            background: #1e1e2e;
            color: #cdd6f4;
            border: 1px solid #45475a;
            border-radius: 12px;
          }
          tooltip {
            background: #1e1e2e;
            color: #cdd6f4;
            border: 1px solid #585b70;
            border-radius: 8px;
          }
          #custom-launcher, #custom-control, #clock, #idle_inhibitor,
          #pulseaudio, #network, #battery, #tray {
            padding: 0 10px;
            margin: 4px 0;
            border-radius: 8px;
          }
          #custom-launcher { color: #cba6f7; margin-left: 4px; }
          #custom-control { margin-right: 4px; }
          #clock { font-weight: bold; }
          #taskbar button { padding: 0 8px; margin: 4px 2px; border-radius: 8px; }
          #taskbar button.active { background: #313244; }
          #taskbar button:hover, #custom-launcher:hover, #custom-control:hover,
          #pulseaudio:hover, #network:hover { background: #45475a; }
          #battery.warning { color: #f9e2af; }
          #battery.critical { background: #f38ba8; color: #1e1e2e; }
          #idle_inhibitor.activated { color: #a6e3a1; }
        '';
        settings.main = {
          layer = "top";
          position = "top";
          height = 42;
          margin-top = 8;
          margin-left = 10;
          margin-right = 10;
          spacing = 4;
          modules-left = [
            "custom/launcher"
            "wlr/taskbar"
          ];
          modules-center = [ "clock" ];
          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            "network"
            "battery"
            "tray"
            "custom/control"
          ];
          "custom/launcher" = {
            format = "󱄅  Apps";
            tooltip = false;
            on-click = "${noctalia} msg panel-toggle launcher";
          };
          "custom/control" = {
            format = "󰒓";
            tooltip = false;
            on-click = "${noctalia} msg panel-toggle control-center";
          };
          "wlr/taskbar" = {
            format = "{icon}";
            icon-size = 22;
            spacing = 2;
            tooltip-format = "{title}";
            on-click = "activate";
            on-click-middle = "close";
          };
          clock = {
            format = "{:%a %d %b  %H:%M}";
            tooltip-format = "<tt>{calendar}</tt>";
          };
          battery = {
            format = "{capacity}% {icon}";
            format-icons = [
              "󰁺"
              "󰁼"
              "󰁾"
              "󰂀"
              "󰁹"
            ];
            states = {
              warning = 25;
              critical = 10;
            };
          };
          network = {
            format-wifi = "󰖩";
            tooltip-format-wifi = "{essid} · {signalStrength}%";
            format-ethernet = "󰈀";
            format-disconnected = "Offline";
            on-click = "${noctalia} msg panel-toggle control-center";
          };
          pulseaudio = {
            format = "󰕾 {volume}%";
            format-muted = "󰖁";
            on-click = "pavucontrol";
          };
          tray = {
            spacing = 10;
            icon-size = 20;
          };
          idle_inhibitor.format = "{icon}";
          idle_inhibitor.format-icons = {
            activated = "󰅶";
            deactivated = "󰾪";
          };
        };
      };
      programs.swaylock.enable = true;
      services.swayidle = {
        enable = true;
        systemdTargets = [ "mango-session.target" ];
        timeouts = [
          {
            timeout = 600;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
        ];
        events = {
          before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
          lock = "${pkgs.swaylock}/bin/swaylock -f";
        };
      };
      services.gammastep = {
        enable = true;
        provider = "manual";
        latitude = -37.8136;
        longitude = 144.9631;
        temperature = {
          day = 6500;
          night = 4000;
        };
        settings.general.adjustment-method = "wayland";
      };
      services.cliphist = {
        enable = true;
        allowImages = true;
      };
      services.polkit-gnome.enable = true;
      systemd.user.services.awww = {
        Unit = {
          Description = "awww wallpaper daemon";
          PartOf = [ "mango-session.target" ];
          After = [ "mango-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "mango-session.target" ];
      };
    };
}
