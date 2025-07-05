{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Minsk";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
    };
  };
  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us,ru";
    xkb.options = "grp:win_space_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ring0 = {
    isNormalUser = true;
    description = "r0";
    extraGroups = [ "networkmanager" "wheel" "video", "docker" ];
    packages = with pkgs; [
      firefox
      flatpak
    ];
    defaultUserShell = pkgs.zsh;
  };

  # flatpak
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };


# polkit
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })
  '';

# power management (tlp)
 powerManagement.enable = true; 
 services.power-profiles-daemon.enable = false;

  services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;

       #Optional helps save long term battery health
       #thinkpad only (i leave it here 'cause if your laptop isnt a thinkpad this options will be ignored)
       START_CHARGE_THRESH_BAT0 = 70; # 70 and bellow it starts to charge
       STOP_CHARGE_THRESH_BAT0 = 90; # 90 and above it stops charging

      };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  # development
    vim
    neovim
    git
    gh
    docker
    docker-compose

  # languages
    rustup
    nodejs_24
    python3
    openjdk
    gcc
    zig
    go
    clang

  # apps
    ghostty
    htop
    telegram-desktop
    spotify

  # utils
    p7zip
    wget
    grim
    slurp
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako
    pulseaudio
    waybar
    swaybg
    swaylock
    wlogout
    thunar
    swappy
    wofi
    zsh
    tmux
    fzf
    ripgrep
    unzip
    gnumake
    lxqt.lxqt-policykit
  ];

  # theme
  # qt.style = "adwaita-dark";

  # set zsh as default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

 # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

  # If swaylock cannot be unlocked with the correct password:
  security.pam.services.swaylock = {};

 # enable light to be able to configure light
  programs.light.enable = true;

  programs.tmux = {
    enable = true;
    # delete it later
    # extraConfig = ''
    # set -g default-shell ${pkgs.zsh}/bin/zsh
    # '';
  };

  system.autoUpgrade = {
      enable = true;
      channel = "https://nixos.org/channels/nixos-unstable";
  };

  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 3d";
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
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
