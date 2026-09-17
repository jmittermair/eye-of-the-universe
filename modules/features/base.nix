{ inputs, ... }:
{
  flake.modules.nixos.base = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    programs.nh.enable = true;
    programs.nix-ld.enable = true;
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      git
      vim
      curl
      wget
      pciutils
      usbutils
      lshw
      dmidecode
      efibootmgr
      nixos-facter
      nix-output-monitor
      nvd
      nix-diff
      nix-tree
      nixfmt
      statix
      deadnix
      nix-index
      nix-prefetch-git
      btop
      bottom
      htop
      iotop
      sysstat
      lsof
      strace
      ltrace
      gdb
      tcpdump
      wireshark-cli
      nmap
      mtr
      iperf3
      ethtool
      inetutils
      dnsutils
      smartmontools
      nvme-cli
      hdparm
      fio
      stress-ng
      lm_sensors
      powertop
      perf
      bpftrace
      trace-cmd
      v4l-utils
      vulkan-tools
      mesa-demos
      wayland-utils
      wev
    ];
    networking.networkmanager.enable = true;
    networking.firewall.enable = true;
    time.timeZone = "Australia/Melbourne";
    i18n.defaultLocale = "en_AU.UTF-8";
    console.keyMap = "us";
    services.fstrim.enable = true;
    services.fwupd.enable = true;
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
    services.thermald.enable = true;
    services.printing.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    services.blueman.enable = true;
    hardware.enableRedistributableFirmware = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    zramSwap = {
      enable = true;
      memoryPercent = 25;
    };
    users.users.vechs = {
      isNormalUser = true;
      description = "vechs";
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "render"
      ];
      shell = pkgs.zsh;
      # Set a password with nixos-enter/passwd during installation.
      # Keep mutableUsers enabled so that password survives rebuilds.
    };
    security.sudo.extraRules = [
      {
        users = [ "vechs" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/*/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/*/bin/nh os switch";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
    };
    system.stateVersion = "26.05";
  };

  flake.modules.homeManager.base = {
    home = {
      username = "vechs";
      homeDirectory = "/home/vechs";
      stateVersion = "26.05";
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        NH_FLAKE = "/home/vechs/nixos";
        NIXOS_OZONE_WL = "1";
      };
      sessionPath = [
        "$HOME/.krew/bin"
        "$HOME/.cargo/bin"
      ];
    };
    programs.home-manager.enable = true;
    xdg.enable = true;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
    systemd.user.startServices = "sd-switch";
  };
}
