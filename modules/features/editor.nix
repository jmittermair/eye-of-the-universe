{ inputs, ... }:
{
  flake.modules.homeManager.editor = { pkgs, ... }: {
    imports = [ inputs.nixvim.homeModules.nixvim ];
    programs.nixvim = {
      nixpkgs.source = inputs.nixpkgs;
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      globals.mapleader = " ";
      opts = {
        number = true;
        relativenumber = true;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        smartindent = true;
        termguicolors = true;
        signcolumn = "yes";
        updatetime = 250;
        undofile = true;
        ignorecase = true;
        smartcase = true;
      };
      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };
      colorschemes.catppuccin = {
        enable = true;
        settings.flavour = "mocha";
      };
      plugins = {
        lualine.enable = true;
        telescope.enable = true;
        gitsigns.enable = true;
        which-key.enable = true;
        web-devicons.enable = true;
        treesitter = {
          enable = true;
          settings.highlight.enable = true;
        };
        blink-cmp.enable = true;
        lsp = {
          enable = true;
          keymaps = {
            lspBuf = {
              gd = "definition";
              gr = "references";
              K = "hover";
              "<leader>rn" = "rename";
              "<leader>ca" = "code_action";
            };
            diagnostic = {
              "[d" = "goto_prev";
              "]d" = "goto_next";
            };
          };
          servers = {
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
              settings."rust-analyzer" = {
                check.command = "clippy";
                cargo.allFeatures = true;
                procMacro.enable = true;
              };
            };
            gopls.enable = true;
            basedpyright.enable = true;
            ruff.enable = true;
            yamlls = {
              enable = true;
              settings.yaml = {
                keyOrdering = false;
                schemaStore.enable = true;
                schemas.kubernetes = [
                  "k8s/**/*.yaml"
                  "kubernetes/**/*.yaml"
                  "manifests/**/*.yaml"
                ];
              };
            };
            nixd.enable = true;
            taplo.enable = true;
            bashls.enable = true;
            jsonls.enable = true;
          };
        };
        conform-nvim = {
          enable = true;
          settings.formatters_by_ft = {
            rust = [ "rustfmt" ];
            go = [ "gofmt" ];
            python = [ "ruff_format" ];
            nix = [ "nixfmt" ];
            yaml = [ "prettier" ];
          };
        };
      };
      extraPackages = with pkgs; [
        ripgrep
        fd
        nixfmt
        ruff
        prettier
      ];
      keymaps = [
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Find files";
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Search text";
        }
        {
          mode = [
            "n"
            "v"
          ];
          key = "<leader>f";
          action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end";
          options.desc = "Format";
        }
      ];
    };
  };
}
