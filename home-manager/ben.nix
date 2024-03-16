{ inputs, config, pkgs, lib, ... }:
{

  imports = [ 
    inputs.ags.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default
    inputs.hyprlock.homeManagerModules.default
    ];

  home.username = "ben";
  home.homeDirectory = "/home/ben";
  home.stateVersion = "23.05"; # Please read the comment before changing.
  home.packages = with pkgs; [
     (nerdfonts.override { fonts = [ "RobotoMono" "JetBrainsMono" "SpaceMono" ]; })
     roboto
     obsidian
     git-crypt
     pyprland
     socat
     gnome.gnome-control-center
    # end-4 ags config
     adw-gtk3
     ydotool
     sassc
     qt5ct
     gradience
     lexend
     material-symbols
     yazi
     fzf # for zoxide
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.activation.linkDotfiles = config.lib.dag.entryAfter [ "writeBoundary" ]
    ''
      ln -sfn /etc/nixos/home-manager/dotfiles/ranger/rc.conf         $HOME/.config/ranger/
    '';
  home.file = {
    ".config/wofi-logout".source = dotfiles/wofi-logout;
    #".config/ags".source = dotfiles/ags;
    # dir must be writable for ranger to run
    # ".config/ranger".source = dotfiles/ranger;
   # ".config/rclone".source = dotfiles/rclone;
    ".config/swaync".source = dotfiles/swaync;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISIAL = "nvim";
    PAGER = "less";
    PATH = "$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH";
    RANGER_LOAD_DEFAULT_RC="false";
  };
 
  programs.ags = {
    enable = true;
    configDir = ./dotfiles/ags;
    # additional packages to add to gjs's runtime
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };

  services.hypridle = {
    enable = true;
    lockCmd = "${inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock}/bin/hyprlock";
    unlockCmd = "";
    beforeSleepCmd =  "${inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock}/bin/hyprlock";
    afterSleepCmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on; ${pkgs.brightnessctl}/bin/brightnessctl -r; echo 2 | ${pkgs.coreutils}/bin/tee  /sys/class/leds/asus::kbd_backlight/brightness";
    listeners = [
      {
        timeout = 150;
	onTimeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10% & echo 1 | ${pkgs.coreutils}/bin/tee  /sys/class/leds/asus::kbd_backlight/brightness";
	onResume = "${pkgs.brightnessctl}/bin/brightnessctl -r & echo 2 | ${pkgs.coreutils}/bin/tee /sys/class/leds/asus::kbd_backlight/brightness";
      }
      {
        timeout = 165;
	onTimeout = "${pkgs.systemd}/bin/systemctl suspend";
	onResume = "";
      }
    ];


  };

  programs.hyprlock = {
    enable = true;
    backgrounds = [
      { 
      path = "screenshot";
      blur_size = 6;
      blur_passes = 2;
      }
    ];
    labels = [
      {
       text = "<b>Please enter your password</b>";
       font_size = 28;
       font_family = "SpaceMono";
       position.y = 80;
       halign = "center";
      }
    ];
    input-fields = [
      {
       size = {
         width = 450;
	 height = 60;
	 };
       outline_thickness = 3;
       dots_size = 0.30000;
       dots_spacing = 0.150000;
       dots_center = true;
       outer_color = "rgb(151515)";
       inner_color = "rgb(166, 18, 72)";
       font_color = "rgb(10, 10, 10)";
       fade_on_empty = true;
       placeholder_text = "<i>Input Password...</i>";
       hide_input = false;

       position.y = -20;
       halign = "center";
       valign = "center";
      }
    ];
  };

  programs.neovim = {
      defaultEditor = true;
      plugins = [
        pkgs.vimPlugins.yuck-vim
      ];
    };

  programs.kitty = {
    enable = true;
    theme = "Cherry Midnight";
    settings = {
      enable_audio_bell = false;
      editor = "nvim";
      confirm_os_window_close = -1;
      shell_integration = true;
    };
  };

  programs.wlogout = {
    enable = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
	ratio = [1 3 3];
	show_hidden = true;
	show_simlink = true;
	sort_by = "natural";
	sort_dir_first = true;
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.activation = {
    # Reload hyprland after home-manager files have been written 
    reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Reloading Hyprland...";
      ${pkgs.hyprland}/bin/hyprctl reload > /dev/null;
      echo "Hyprland reloaded successfully";
    '';
    reloadEww = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Reloading Eww...";
      ${pkgs.hyprland}/bin/hyprctl dispatch exec ${pkgs.eww-wayland}/bin/eww reload;
      echo "Eww reloaded successfully";
    '';
    };
}
