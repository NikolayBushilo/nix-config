{config, inputs, ...}:
let
  userzz = builtins.attrNames inputs.home-manager.users;
  user = "niko";
in
{

  # NixOS entrypoint
  programs.hyprland = {
    enable = true;
  };

  # Home-manager entrypoint
  home-manager.users.${user}.wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    # package = null;
    # portalPackage = null;

    settings = {
        general = {
        layout = "dwindle";
        border_size = 4;
        gaps_out = 0;
        gaps_in=0;
        resize_on_border = true;
        no_focus_fallback = true;
        # Colors
        "col.active_border" = "rgb(dc322f) rgb(dc322f)";
        "col.inactive_border" = "rgb(fdf6e3) rgb(fdf6e3)";
        # monitor = [
        #     "eDP-1,2256x1504@60,0x0,2"
        #     # Left vertical
        #     "DP-10,1080x1920@60,0x752,1" #transform,1
        #     # Right vertical
        #     # "DP-9,1080x1920@75,1080x0,1,transform,1"
        #     # Laptop below right monitor
        # ];
        };
        monitor = [
            "desc:BOE 0x0BCA,2256x1504@60,1080x1920,2"

            "desc:Iiyama North America PLE2483H,1920x1080@60,0x0,1,transform,1"

            "desc:G.VISION 27XCF,1920x1080@60,1080x0,1,transform,3"
        ];
        decoration = {
            #rounding = 8;
            #rounding_power = 3;
        };
        windowrule = [
        ];
        dwindle = {
            pseudotile = true;
            force_split = 2;
        };
        ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
        };
        cursor = {
            persistent_warps = true;
            warp_on_change_workspace = 1;
        };
        input = {
            kb_layout = "us";
            kb_variant = "euro";
            kb_options = "caps:swapescape,compose:ralt";
            accel_profile = "flat";
            natural_scroll = false;
        
                touchpad = {
                    natural_scroll = true;
                    drag_lock = 1;
                    # tap-and-drag = true;
                    # tap-to-click = true;
                };
        };
        binds = {
            workspace_center_on = 1;
        };
        "$mod" = "SUPER";
        bind = [
            # Open programs
            "$mod, RETURN, exec, kitty"
            "$mod, B, exec, firefox"
            # Close / kill Programs
            "$mod, W, killactive,"
            "$mod+SHIFT, W, forcekillactive,"
            # Fullscreen / Maximize
            "$mod+SHIFT, M, fullscreenstate, 2 2,"
            "$mod, M, fullscreenstate, 2 0,"
            # Toggle floating
            "$mod, F, togglefloating,"
            # Other Actions
            ", Print, exec, grimblast copy area"
            # Focus window
            "$mod, H, movefocus,l"
            "$mod, J, movefocus,d"
            "$mod, K, movefocus,u"
            "$mod, L, movefocus,r"
            # Move focused window
            "$mod+SHIFT, H, movewindow,l"
            "$mod+SHIFT, J, movewindow,d"
            "$mod+SHIFT, K, movewindow,u"
            "$mod+SHIFT, L, movewindow,r"
            # Split window
            # Waybar
            "$mod, SUPER_L, exec, pkill -SIGUSR1 waybar"
            "$mod, TAB, exec, pkill -SIGUSR2 waybar"
            "$mod, SPACE, exec, rofi -show drun -show-icons"
        ]
        ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (i:
                let ws = i + 1;
                in [
                    "$mod, code:1${toString i}, workspace, ${toString ws}"
                    "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
            )
            9)
        );
        binde = [
            # Resize focused window
            "$mod+CTRL, H, resizeactive,-20 0"
            "$mod+CTRL, J, resizeactive,0 20"
            "$mod+CTRL, K, resizeactive,0 -20"
            "$mod+CTRL, L, resizeactive,20 0"
        ];
        # Audio stuff
        bindel = [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
            ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];
        bindl = [
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioMedia, exec, kitty sudo framework-tool-tui"
        ];
    };
    };
}
