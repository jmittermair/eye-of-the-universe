# Evaluation only: never exposes an installable alternate host or builds disks.
let
  flake = builtins.getFlake (toString ../.);
  host = flake.nixosConfigurations.thestranger;
  lib = flake.inputs.nixpkgs.lib;
  installationRequirements = [
    "Set thestranger.diskDevice to the internal NVMe by-id path before installation."
    "thestranger: generate facter.json on the laptop before installation; see README.md."
  ];
  evaluated = host.extendModules {
    modules = [
      {
        # Only omit these two hardware-local prerequisites during offline validation.
        # All upstream NixOS/Home Manager assertions continue to run.
        assertions = lib.mkForce (
          builtins.filter (
            a: a.assertion || !(builtins.elem a.message installationRequirements)
          ) host.config.assertions
        );
      }
    ];
  };
in
{
  pendingInstallation = map (a: a.message) (builtins.filter (a: !a.assertion) host.config.assertions);
  system = evaluated.config.system.build.toplevel.drvPath;
  home = evaluated.config.home-manager.users.vechs.home.activationPackage.drvPath;
  diskNames = builtins.attrNames host.config.disko.devices.disk;
  fileSystems = builtins.attrNames host.config.fileSystems;
  hostName = host.config.networking.hostName;
  stateVersion = host.config.system.stateVersion;
}
