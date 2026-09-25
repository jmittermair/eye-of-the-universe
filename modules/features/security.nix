{
  flake.modules.nixos.security = {pkgs, ...}: {
    users.users.vechs = {
      extraGroups = [
        "input"
      ];
    };
    security.polkit.extraConfig = ''
      polkit.addRule(function (action, subject) {
        if (action.id.indexOf("net.reactivated.fprint.") == 0) {
          if (subject.isInGroup("input")) {
            return polkit.Result.YES;
          }
        }
      });
    '';
    security.pam.services.sudo.fprintAuth = true;
    security.pam.services.swaylock.rules.auth.fprintd.order = config.security.pam.services.swaylock.rules.auth.unix.order + 50;
    security.pam.services.swaylock.rules.auth.fprintd.settings.timeout = 10;
    services.fprintd.enable = true;
    services.logind.settings.Login.HandlePowerKey = "ignore";
  };
}
