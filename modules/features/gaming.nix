{
  flake.modules.nixos.gaming = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      # Open LAN streaming/transfer ports only when actually using those features.
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
    };
    programs.gamemode.enable = true;
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
    users.users.vechs.extraGroups = [ "gamemode" ];
    hardware.steam-hardware.enable = true;
    services.udev.packages = [ pkgs.game-devices-udev-rules ];
    environment.systemPackages = with pkgs; [
      lutris
      heroic
      mangohud
      goverlay
      protontricks
      winetricks
      wineWow64Packages.staging
      vulkan-tools
    ];
  };
}
