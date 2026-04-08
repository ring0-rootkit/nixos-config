# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz"; 
    sha256 = "16mcnqpcgl3s2frq9if6vb8rpnfkmfxkz5kkkjwlf769wsqqg3i9";
  };
in
{
  imports =
    [
      (import "${home-manager}/nixos")
      ./hardware-configuration.nix
    ];

    nixpkgs.overlays = [
      (self: super: {
        xorg = super.xorg // {
          lndir = super.lndir;
        };
      })
    ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = true;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.r0 = { pkgs, ... }: {
    home.stateVersion = "25.11"; 

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Dmitry Dubina";
          email = "git.ring0.rootkit@gmail.com";
        };
        push = {
          autoSetupRemote = true;
        };
      };
    };

    programs.neovim = {
      enable = true;

      extraPackages = with pkgs; [
        gofumpt
        goimports-reviser
        golines
        gopls
        go
        gcc
      ];
    };

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
    };

    dconf = {
      enable = true;
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          luminus-desktop.extensionUuid
        ];
      };
    };

    home.enableNixpkgsReleaseCheck = false;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "r0"; # Define your hostname.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.r0 = {
    isNormalUser = true;
    description = "r0";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    clang
    gcc
    zig
    ghostty
    git
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    tmux

    unzip
    nodejs
    python3
    cargo

    tree-sitter

    xdg-desktop-portal-gtk
    wl-clipboard
    wireplumber
    foot
    fastfetch
    btop
    jq
    eza
    telegram-desktop
    fzf
    ripgrep
    gnomeExtensions.appindicator

    tuigreet
    greetd
    go
    adwaita-icon-theme
    bun
    gnome-tweaks
  ];



  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

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
  system.stateVersion = "25.11"; # Did you read the comment?
}
