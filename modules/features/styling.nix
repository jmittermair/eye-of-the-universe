{ inputs, ... }:
{
  flake.modules.nixos.styling = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      image = ../../assets/wallpaper.svg;
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 11;
          desktop = 11;
          terminal = 12;
          popups = 11;
        };
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
    fonts.packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
    ];
  };
  flake.modules.homeManager.styling = {
    stylix.targets.nixvim.enable = false;
    stylix.targets.firefox.profileNames = [ "default" ];
  };
}
