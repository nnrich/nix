# Edit this configuration file to define what should be installed on

# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ config, pkgs, ... }:

let
  my-python-packages = ps: with ps; [ requests ];
  vpn-netns = pkgs.writeTextFile {
    name = "vpn-netns";
    destination = "/bin/vpn-netns";
    executable = true;
    text = ''
      #!/usr/bin/env bash
      case $script_type in
          up)
                  ${pkgs.iproute}/bin/ip netns add vpn
                  ${pkgs.iproute}/bin/ip netns exec vpn ${pkgs.iproute}/bin/ip link set dev lo up
                  ${pkgs.iproute}/bin/ip link set dev "$1" up netns vpn mtu "$2"
                  ${pkgs.iproute}/bin/ip netns exec vpn ${pkgs.iproute}/bin/ip addr add dev "$1" \
                          "$4/''${ifconfig_netmask:-30}" \
                          ''${ifconfig_broadcast:+broadcast "$ifconfig_broadcast"}
                  if [ -n "$ifconfig_ipv6_local" ]; then
                          ${pkgs.iproute}/bin/ip netns exec vpn ${pkgs.iproute}/bin/ip addr add dev "$1" \
                                  "$ifconfig_ipv6_local"/112
                  fi
                  ;;
          route-up)
                  ${pkgs.iproute}/bin/ip netns exec vpn ${pkgs.iproute}/bin/ip route add default via "$route_vpn_gateway"
                  if [ -n "$ifconfig_ipv6_remote" ]; then
                          ${pkgs.iproute}/bin/ip netns exec vpn ${pkgs.iproute}/bin/ip route add default via \
                                  "$ifconfig_ipv6_remote"
                  fi
                  ;;
          down)
                  ${pkgs.iproute}/bin/ip netns delete vpn
                  ;;
      esac
    '';
  };
in {
  imports = [ # Include the results of the hardware scan.
    ./rdc-work-hardware-config.nix
    ./php.nix
    ./work.nix
  ];

  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # lowLatency = {
    #   enable = true;
    #   quantum = 64;
    #   rate = 48000;
    # };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rcook = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "disk"
      "libvirtd"
      "docker"
      "audio"
      "video"
      "input"
      "systemd-journal"
      "networkmanager"
      "network"
      "davfs2"
    ];
    shell = pkgs.zsh;
  };

  programs.light.enable = true;
  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      iosevka
      jetbrains-mono
      nerdfonts
      powerline-fonts
      roboto
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Roboto" ];
        sansSerif = [ "Roboto" ];
        monospace = [ "JetBrains Mono" ];
      };
    };

  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    arandr
    bottom
    discord
    dmenu
    feh
    ffmpeg-full
    geoclue2
    imagemagick
    jansson
    jq
    kitty
    libassuan
    libgpg-error
    lm_sensors
    lxappearance
    nodejs
    openvpn
    pavucontrol
    php
    plex-media-player
    plocate
    slop
    swaybg
    tesseract
    virt-manager
    vpn-netns
    wget
    wineWowPackages.stable
    wofi
    xclip
    (python3.withPackages my-python-packages)
    (import ./scripts/getinfo.nix { inherit pkgs; })
    (import ./scripts/sshtunnel.nix { inherit pkgs; })
  ];

  programs.mtr.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.dconf.enable = true;
  services.qemuGuest.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;
  services.dbus.enable = true;
  systemd.services.openvpn-foo.serviceConfig.ExecStart =
    "${pkgs.openvpn}/bin/openvpn --ifconfig-noexec --route-noexec --up ${vpn-netns}/bin/vpn-netns --route-up ${vpn-netns}/bin/vpn-netns --down ${vpn-netns}/bin/vpn-netns --script-security 2 --config /home/rcook/vpnconfig.ovpn";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages =
    [ "openssl-1.1.1u" "openssl-1.1.1v" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.overlays = [
    (self: super: {
      neovim = super.neovim.override {
        viAlias = true;
        vimAlias = true;
      };
    })
  ];

  programs.zsh = { enable = true; };
  programs.steam.enable = true;

  programs.git.enable = true;
  services.flatpak.enable = true;

  location.provider = "manual";
  location.latitude = 51.0;
  location.longitude = 0.0;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}

