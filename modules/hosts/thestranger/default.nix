{ inputs, config, ... }:
let
  nixos = config.flake.modules.nixos;
  home = config.flake.modules.homeManager;
in
{
  flake.nixosConfigurations.thestranger = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixos.base
      nixos.desktop
      nixos.sound
      nixos.gaming
      nixos.security
      nixos.virtualisation
      nixos.vpn
      nixos.styling
      nixos.storage
      inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
      ({ lib, pkgs, ... }: {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "thestranger";
        thestranger.diskDevice = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S466NX0K420312N";
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.loader.systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        boot.loader.efi.canTouchEfiVariables = true;
        # Replace the empty report on the real laptop; never fabricate hardware data.
        hardware.facter.reportPath = lib.mkIf (builtins.readFile ./facter.json != "") ./facter.json;
        boot.initrd.systemd.enable = true;
        boot.initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "usbhid"
          "hid_generic"
        ];
        assertions = [
          {
            assertion = builtins.readFile ./facter.json != "";
            message = "thestranger: generate facter.json on the laptop before installation; see README.md.";
          }
        ];
        home-manager.users.vechs.imports = [
          home.base
          home.desktop
          home.sound
          home.shell
          home.development
          home.kubernetes
#          home.editor
          home.apps
          home.styling
        ];
      })
    ];
  };
}
