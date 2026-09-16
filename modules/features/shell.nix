{
  flake.modules.homeManager.shell = { pkgs, ... }: {
    home.packages = with pkgs; [
      dust
      duf
      procs
      sd
      tokei
      hyperfine
      watchexec
      just
      xh
      ouch
      jq
      yq-go
      moreutils
      file
      tree
      unzip
      zip
      p7zip
      rsync
      rclone
      uutils-coreutils
    ];
    # Rust coreutils uses uutils-* names; GNU coreutils remains authoritative.
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 50000;
        save = 50000;
        ignoreDups = true;
      };
      shellAliases = {
        ll = "eza -lah --git";
        lt = "eza --tree --level=2";
        k = "kubectl";
        kgp = "kubectl get pods";
        rebuild = "nh os switch";
        update = "nix flake update --flake ~/nixos";
      };
    };
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };
    programs.bat.enable = true;
    programs.fd.enable = true;
    programs.ripgrep.enable = true;
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    programs.git = {
      enable = true;
      includes = [ { path = "~/.config/git/identity"; } ];
      settings = {
        init.defaultBranch = "main";
        pull.ff = "only";
        push.autoSetupRemote = true;
        fetch.prune = true;
        rerere.enabled = true;
        merge.conflictStyle = "zdiff3";
        diff.algorithm = "histogram";
      };
      ignores = [
        ".direnv/"
        "result"
        "result-*"
        ".env"
      ];
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
    programs.lazygit.enable = true;
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
      };
    };
    services.ssh-agent.enable = true;
  };
}
