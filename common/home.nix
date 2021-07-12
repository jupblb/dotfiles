{ config, lib, pkgs, ... }:

{
  home = {
    file             = { ".ammonite/predef.sc".source = pkgs.ammonite.predef; };
    packages         = with pkgs; [ ammonite gh git-crypt gore ripgrep ];
    sessionVariables = { EDITOR = "nvim"; GOROOT = "${pkgs.go}/share/go"; };
    username         = "jupblb";
  };

  nixpkgs.config.allowUnfreePredicate = pkg: (lib.getName pkg) == "tabnine";
  nixpkgs.overlays                    = [ (import ./overlay) ];

  programs = {
    bash = {
      enable         = true;
      historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
      shellOptions   = [ "cdspell" "checkwinsize" "cmdhist" "histappend" ];
      initExtra      = builtins.readFile ../config/bashrc;
    };

    bat = {
      config = { theme = "gruvbox-light"; };
      enable = true;
    };

    exa.enable = true;

    fish = {
      enable               = true;
      functions            = {
        fish_greeting =
          "if test $SHLVL -eq 1; ${pkgs.fortune}/bin/fortune -sa; end";
        lfcd          = "${builtins.readFile pkgs.lf.lfcd-fish} lfcd $argv";
        ls            = ''
          set PATH ${pkgs.exa}/bin $PATH
          ${builtins.readFile ../config/fish/ls.fish}
        '';
      };
      plugins              = lib.mapAttrsToList
        (name: pkg: { name = name; src = pkg; }) pkgs.fish-plugins;
      interactiveShellInit = ''
        set -gx LF_ICONS "${builtins.readFile ../config/lf/lf-icons.cfg}"
        theme_gruvbox light hard
      '';
      shellAliases         = {
        cat  = "bat -p --paging=never";
        less = "bat -p --paging=always";
      };
    };

    fzf = {
      enable            = true;
      defaultCommand    = "${pkgs.fd}/bin/fd --hidden --type f";
      defaultOptions    = [ "--color=light" ];
      fileWidgetCommand = "${pkgs.fd}/bin/fd --hidden";
      fileWidgetOptions = [ "--preview 'bat --color=always -pp {}'" ];
    };

    git = {
      aliases     = {
        amend = "commit -a --amend --no-edit";
        line  = "!sh -c 'git log -L$2,+1:\${GIT_PREFIX:-./}$1' -";
        lines = "!sh -c 'git log -L$2,$3:\${GIT_PREFIX:-./}$1' -";
      };
      delta       = {
        enable  = true;
        options = {
          line-numbers            = true;
          line-numbers-zero-style = "#3c3836";
          minus-emph-style        = "syntax #fa9f86";
          minus-style             = "syntax #f9d8bc";
          plus-emph-style         = "syntax #d9d87f";
          plus-style              = "syntax #eeebba";
          side-by-side            = true;
          syntax-theme            = "gruvbox-light";
        };
      };
      enable      = true;
      extraConfig = {
        color.ui          = true;
        core.mergeoptions = "--no-edit";
        fetch.prune       = true;
        pull.rebase       = true;
        push.default      = "upstream";
        submodule.recurse = true;
      };
      signing     = { key = "1F516D495D5D8D5B"; signByDefault = true; };
      userEmail   = "mpkielbowicz@gmail.com";
      userName    = "jupblb";
    };

    go = {
      enable = true;
      goPath = "${config.xdg.dataHome}/go";
    };

    gpg.enable = true;

    htop = {
      enable   = true;
      settings = { hide_threads = true; hide_userland_threads = true; };
    };

    kitty = {
      enable      = true;
      font        = {
        name    = "PragmataPro Mono Liga";
        package = pkgs.pragmata-pro;
        size    = 10;
      };
      keybindings = {
        "ctrl+shift+'" = "launch --location=hsplit";
        "ctrl+shift+;" = "launch --location=vsplit";
        "ctrl+shift+`" = "show_scrollback";
        "ctrl+shift+h" = "move_window left";
        "ctrl+shift+j" = "move_window bottom";
        "ctrl+shift+k" = "move_window top";
        "ctrl+shift+l" = "move_window right";
        "ctrl+h"       = "neighboring_window left";
        "ctrl+j"       = "neighboring_window bottom";
        "ctrl+k"       = "neighboring_window top";
        "ctrl+l"       = "neighboring_window right";
      };
      settings    = {
        background                    = "#f9f5d7";
        clipboard_control             =
          "write-clipboard write-primary no-append";
        enabled_layouts               = "splits";
        enable_audio_bell             = "no";
        foreground                    = "#282828";
        scrollback_pager              =
          "nvim -c 'setl ft=man | call clearmatches() | autocmd VimEnter * norm G{}'";
        scrollback_pager_history_size = 4096;
        shell                         = "${pkgs.fish}/bin/fish";
      };
    };

    lf = {
      enable      = true;
      extraConfig = builtins.readFile ../config/lf/lfrc.sh;
      previewer   = { keybinding = "`"; source = pkgs.lf.previewer; };
      settings    = { hidden = true; icons = true; tabstop = 4; };
    };

    mercurial = {
      enable      = true;
      extraConfig = { pager.pager = "${pkgs.gitAndTools.delta}/bin/delta"; };
      userEmail   = "mpkielbowicz@gmail.com";
      userName    = "jupblb";
    };

    neovim = {
      extraConfig   = builtins.readFile ../config/neovim/init.vim;
      plugins       = with pkgs.vimPlugins; [ {
          config = "let $GLOW_STYLE = 'light'";
          plugin = glow-nvim;
        } {
          config = builtins.readFile ../config/neovim/gruvbox.vim;
          plugin = gruvbox-nvim;
        } {
          config = builtins.readFile ../config/neovim/hop.vim;
          plugin = hop-nvim;
        } {
          config = "luafile ${../config/neovim/lualine.lua}";
          plugin = lualine-nvim.overrideAttrs(_: {
            dependencies = [ lsp-status-nvim ];
          });
        } {
          config = "luafile ${../config/neovim/luatab.lua}";
          plugin = luatab-nvim;
        } {
          config = "lua require('bqf').setup({ preview = { wrap = true } })";
          plugin = nvim-bqf;
        } {
          config = "set termguicolors | lua require('colorizer').setup()";
          plugin = nvim-colorizer-lua;
        } {
          config = "luafile ${../config/neovim/compe.lua}";
          plugin = nvim-compe.overrideAttrs(_: {
            dependencies = [ compe-tabnine ];
          });
        } {
          config = ''
            call sign_define('LightBulbSign', { "text": " ", "texthl": "LspDiagnosticsDefaultInformation" })
            autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()
          '';
          plugin = nvim-lightbulb;
        } {
          config = "luafile ${../config/neovim/lspconfig.lua}";
          plugin = nvim-lspconfig.overrideAttrs(_: {
            dependencies = [ lsp-status-nvim ];
          });
        } {
          config = builtins.readFile ../config/neovim/tree.vim;
          plugin = nvim-tree-lua;
        } {
          config = "luafile ${../config/neovim/treesitter.lua}";
          plugin = nvim-treesitter.overrideAttrs(_: {
            dependencies = [ nvim-treesitter-refactor ];
          });
        } {
          config = "luafile ${../config/neovim/devicons.lua}";
          plugin = nvim-web-devicons;
        } {
          config = "luafile ${../config/neovim/telescope.lua}";
          plugin = telescope-nvim.overrideAttrs(old: {
            dependencies = old.dependencies ++
              [ telescope-fzf-writer-nvim telescope-fzy-native-nvim ];
          });
        } {
          config = ''
            nnoremap <Leader>r :Grepper -tool rg<CR>
            nnoremap <Leader>R :Grepper -tool rg -buffer<CR>
          '';
          plugin = vim-grepper;
        } {
          config = "let g:vimwiki_key_mappings = { 'all_maps': 0 }";
          plugin = vimwiki;
        }
        lua-dev vim-cool vim-go vim-signify vim-sleuth
      ];
      enable        = true;
      extraPackages =
        let
          packages     = with pkgs; [
            fd
            gcc glow gopls
            metals
            ripgrep rnix-lsp
            sumneko-lua-language-server
            tree-sitter
          ];
          nodePackages = with pkgs.nodePackages; [
            bash-language-server
            npm
            typescript-language-server
            vscode-css-languageserver-bin vscode-html-languageserver-bin
          ];
        in packages ++ nodePackages;
      package       = pkgs.neovim-nightly;
      vimAlias      = true;
      vimdiffAlias  = true;
      withNodeJs    = true;
      withPython3   = false;
      withRuby      = false;
    };

    nix-index.enable = true;

    ssh = {
      compression         = true;
      controlMaster       = "auto";
      controlPersist      = "yes";
      enable              = true;
      forwardAgent        = true;
      matchBlocks         =
        let key = {
          identitiesOnly = true;
          identityFile   = [ (toString ../config/ssh/id_ed25519) ];
        };
        in {
          dionysus     = key // { hostname = "jupblb.ddns.net"; port = 1995; };
          "github.com" = key;
          hades        = key // { hostname = "jupblb.ddns.net"; port = 1993; };
        };
      serverAliveInterval = 30;
    };

    starship = {
      enable   = true;
      settings = {
        add_newline = false;
        directory   = {
          read_only         = " ";
          truncation_length = 8;
          truncation_symbol = "…/";
        };
        format      =
          let
            git    = map (s: "git_" + s) [ "branch" "commit" "state" "status" ];
            line   = prefix ++ [ "hg_branch" ] ++ git  ++ [ "status" "shell" ];
            prefix = [ "shlvl" "nix_shell"  "hostname" "directory" ];
          in lib.concatMapStrings (e: "$" + e) line;
        git_branch  = { symbol = " "; };
        git_status  = {
          ahead      = " ";
          behind     = " ";
          conflicted = " ";
          deleted    = " ";
          diverged   = " ";
          modified   = " ";
          staged     = " ";
          stashed    = " ";
          untracked  = " ";
        };
        hg_branch   = { disabled = false; symbol = " "; };
        hostname    = { format = "[($hostname:)]($style)"; };
        nix_shell   = { format = "[ ]($style) "; };
        shell       = {
          bash_indicator = "\\$";
          disabled       = false;
          fish_indicator = "~>";
        };
        shlvl       = { disabled = false; symbol = " "; };
        status      = { disabled = false; symbol = " "; };
      };
    };
  };

  xdg.enable = true;
}
