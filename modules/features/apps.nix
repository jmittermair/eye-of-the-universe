{
  flake.modules.homeManager.apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      brave
      bitwarden-desktop
      bitwarden-cli
      rbw
      pinentry-qt
      protonmail-desktop
      discord
      slack
      element-desktop
      wl-clipboard
      cliphist
      xdg-utils
      satty
      grim
      slurp
      grimblast
      pavucontrol
      playerctl
      brightnessctl
      libnotify
    ];
    programs.firefox = {
      enable = true;
      profiles.default = {
        isDefault = true;
        settings = {
          "browser.startup.page" = 3;
          "browser.tabs.warnOnClose" = true;
          "browser.tabs.inTitlebar" = 0;
          "privacy.trackingprotection.enabled" = true;
        };
      };
    };
    programs.ghostty = {
      enable = true;
      settings = {
        confirm-close-surface = false;
        mouse-hide-while-typing = true;
      };
    };
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      };
    };
  };
}
