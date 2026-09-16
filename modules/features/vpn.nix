{
  flake.modules.nixos.vpn = {
    services.tailscale.enable = true;
    services.netbird.enable = true;
    services.netbird.ui.enable = true;
    # Authentication, DNS ownership and routes are selected interactively.
    # Do not put enrollment keys in the Nix store.
  };
}
