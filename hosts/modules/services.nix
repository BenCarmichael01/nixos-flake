{config, pkgs, ...}:
{
services = {
  accounts-daemon.enable = true;
  
  dbus.enable = true;
  
  flatpak.enable = true;
  
  pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  printing.enable = true;
  
  udev.extraRules = ''
  SUBSYSTEM=="backlight",RUN+="${pkgs.coreutils}/bin/chmod 777 /sys/class/leds/asus::kbd_backlight/brightness"
  '';
  
  upower.enable = true;

  xserver = {
    enable = true;
    xkb.layout = "gb";
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };
  
  auto-cpufreq = {
    enable = true;
    settings = {
    charger = {
      governer = "performance";
      turbo = "auto";
    };
    battery = {
      governer = "powersave";
      turbo = "auto";
    };
    };
  };
};
}
