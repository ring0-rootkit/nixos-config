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

# overlays {{{

  # some dependency uses old naming, so alias old name to a new one
  nixpkgs.overlays = [
    (self: super: {
      xorg = super.xorg // {
        lndir = super.lndir;
      };
    })
  ];

# }}}

# gnome {{{

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = true;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# }}}

# home manager {{{



  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.r0 = { pkgs, ... }: {
    home.stateVersion = "25.11"; 

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

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
      settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-light";
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            luminus-desktop.extensionUuid
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Wayscriber Annotate";
          command = "wayscriber -a";
          binding = "<Super>d";
        };
      };
    };

    systemd.user.services.wayscriber = {
      Unit = {
        Description = "Wayscriber screen annotation daemon";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wayscriber}/bin/wayscriber --daemon";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };



    home.enableNixpkgsReleaseCheck = false;
  };

# }}}

# system {{{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Minsk";
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver 
      intel-compute-runtime
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  virtualisation.docker.enable = true;


# }}}

# networking {{{

  networking.hostName = "r0"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;


# }}}

# user setup {{{

  users.users.r0 = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "r0";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  users.defaultUserShell = pkgs.zsh;

#}}}

# programs {{{

  # use ld compatibility layer
  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (import ./packages.nix { inherit pkgs inputs; });

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

# }}}

# misc {{{

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

#}}}

# services {{{

  services.tailscale = {
    enable = true;
  };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

# }}}


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
