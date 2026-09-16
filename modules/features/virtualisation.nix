{
  flake.modules.nixos.virtualisation = { pkgs, ... }: {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    virtualisation.containers.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;
    users.users.vechs = {
      extraGroups = [
        "libvirtd"
        "kvm"
      ];
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
      linger = true;
    };
    environment.systemPackages = with pkgs; [
      podman-desktop
      podman-compose
      buildah
      skopeo
      dive
      distrobox
      virtiofsd
      virt-viewer
      libguestfs
    ];
    # Podman's native generator reads ~/.config/containers/systemd/*.container.
    # No example workloads are automatically started on this laptop.
  };
}
