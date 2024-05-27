{pkgs, config, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  config = { 
  flakeDir = "/home/trinity/flake-config";

  boot = {
    initrd.verbose = false;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  i18n.defaultLocale = "en_GB.UTF-8";

  time = {
    timeZone = "Europe/London";
  };

  console = {
    useXkbConfig = true; # use xkbOptions in tty.
  };
 
  nix = {
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    extraOptions = ''
      # free up to 1GiB from store when less that 100MiB left
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "trinity" ];
    };
    package = pkgs.nixFlakes;
    };
    
  nixpkgs.config.allowUnfree = true;
  
  networking.networkmanager.enable = true;
  networking.hostName = "trinity";
  
  security = {
    polkit.enable = true;
    # Scheduling (used by pipewire)
    rtkit.enable = true;
  };
  
  users.users.trinity = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "networkmanager" ];
    description = "Trinity";
    initialPassword = "password";
    shell = pkgs.bash;
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
    udiskie
    ];
  
  virtualisation.docker.enable = true;
  
  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = /. + config.flakeDir;
    };
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = true; # Disable when RSA keys are setup
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  };
}  
