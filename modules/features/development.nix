{
  flake.modules.homeManager.development = { pkgs, ... }: {
    home.packages = with pkgs; [
#      rustup
#      cargo-nextest
#      cargo-audit
#      cargo-deny
#      cargo-edit
#      cargo-expand
#      cargo-outdated
#      cargo-machete
#      bacon
#      lldb
#      clang
      pkg-config
      gnumake
      cmake
      go
      gopls
      delve
      golangci-lint
      python3
      uv
      ruff
      basedpyright
      nodejs
      yaml-language-server
      actionlint
      shellcheck
      shfmt
      nil
      nixd
      taplo
    ];
    # rustup respects each project's rust-toolchain.toml. The editor's
    # rust-analyzer is separately pinned by Nixvim.
    home.sessionVariables.CARGO_NET_GIT_FETCH_WITH_CLI = "true";
  };
}
