# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, inputs, ... }:

{
    networking.hostName = "laptop";

    # Laptop-specific packages (the other ones are installed in `packages.nix`)
    environment.systemPackages = with pkgs; [
        acpi tlp
    ];

    # Sound
    sound.enable = true;

    # Disable bluetooth, enable pulseaudio, enable opengl (for Wayland)
    hardware = {
        bluetooth.enable = false;
        pulseaudio.enable = true;
        opengl = {
            enable = true;
            driSupport = true;
        };
    };

    # Install fonts
    fonts = {
        fonts = with pkgs; [
            jetbrains-mono
            roboto
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
        fontconfig.hinting.autohint = true;
    };

    # Wayland stuff: enable XDG integration, allow sway to use brillo
    xdg = {
        portal = {
            enable = true;
            extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
            ];
            gtkUsePortal = true;
        };
    };

    # StevenBlack hosts file to block junk
    networking.extraHosts = let
    hostsPath = https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts;
    hostsFile = builtins.fetchurl { url=hostsPath; sha256="sha256:0rz69q5xdppqjc849pgmq47dcib2s2ycpm9ym8mgh1prhkgnanxh"; };
    in builtins.readFile "${hostsFile}";

    # Hardware config
    hardware.cpu.intel.updateMicrocode = true;

    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "rtsx_pci_sdmmc" ];

    fileSystems."/" = { 
        device = "/dev/disk/by-uuid/74c98363-e127-4b3b-9840-6bfb32837807";
        fsType = "ext4";
    };

    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/99CC-4342";
        fsType = "vfat";
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/ccec80c0-6886-4534-899c-04a3a00e88b5"; } ];

    # https://discourse.nixos.org/t/how-to-switch-cpu-governor-on-battery-power/8446/4
    services.tlp = {
        enable = true;
        settings = {
            CPU_SCALING_GOVERNOR_ON_BAT="powersave";
            CPU_SCALING_GOVERNOR_ON_AC="powersave";

            # The following prevents the battery from charging fully to
            # preserve lifetime. Run `tlp fullcharge` to temporarily force
            # full charge.
            # https://linrunner.de/tlp/faq/battery.html#how-to-choose-good-battery-charge-thresholds
            START_CHARGE_THRESH_BAT0=40;
            STOP_CHARGE_THRESH_BAT0=50;

            # 100 being the maximum, limit the speed of my CPU to reduce
            # heat and increase battery usage:
            CPU_MAX_PERF_ON_AC=75;
            CPU_MAX_PERF_ON_BAT=60;
        };
    };
    services.fstrim.enable = true;
}
