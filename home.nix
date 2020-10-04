{ config, lib, pkgs, ... }:

{
  home.packages         = with pkgs; [ gmailctl ranger screen unzip ];
  home.sessionVariables = {
    MANPAGER             = "vim -c 'set ft=man' -";
    NIXPKGS_ALLOW_UNFREE = "1";
  };
  home.username         = "jupblb";

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    ranger = callPackage ./misc/ranger { ranger = pkgs.ranger; };
  };

  programs = {
    # Remember to run `bat cache --build` before first run
    bat.enable         = true;
    bat.themes.gruvbox = builtins.readFile ./misc/gruvbox.tmTheme;

    fish = {
      enable               = true;
      interactiveShellInit = builtins.readFile ./misc/config.fish;
      plugins              = [ {
        name = "bass";
        src  = pkgs.fetchFromGitHub {
          owner  = "edc";
          repo   = "bass";
          rev    = "master";
          sha256 = "0ppmajynpb9l58xbrcnbp41b66g7p0c9l2nlsvyjwk6d16g4p4gy";
        };
      } ];
    };

    fzf.enable = true;

    git = {
      delta       = {
        enable  = true;
        options = {
          minus-emph-style = "syntax #fa9f86";
          minus-style      = "syntax #f9d8bc";
          plus-emph-style  = "syntax #d9d87f";
          plus-style       = "syntax #eeebba";
          syntax-theme     = "gruvbox";
        };
      };
      enable      = true;
      extraConfig = {
        color.ui          = true;
        core.mergeoptions = "--no-edit";
        fetch.prune       = true;
        push.default      = "upstream";
      };
      userEmail   = "jupblb@google.com";
      userName    = "jupblb";
    };

    htop.enable = true;

    kitty.enable      = true;
    kitty.extraConfig = with pkgs; ''
      ${builtins.readFile ./misc/kitty.conf}
      ${lib.optionalString stdenv.isLinux "font_size 10.0"}
      ${lib.optionalString stdenv.isDarwin "font_size 14.0"}
      ${builtins.readFile (fetchurl {
        url    = "https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/gruvbox_light.conf";
        sha256 = "1yvg98vll5yp7nadq2k2q6ri9c9jgk5a5syszbxs7bqpgb27nzha";
      })}
      startup_session ${builtins.toString (writeTextFile {
        name = "kitty-launch";
        text = "launch ${fish}/bin/fish -C '${fortune}/bin/fortune -sa'";
      })}
    '';

    neovim = {
      configure    = {
        customRC            = let
          regular = with pkgs; [ ripgrep rnix-lsp ];
          node    = with pkgs.nodePackages; [ bash-language-server ];
                              in ''
            let $PATH      .= ':${lib.makeBinPath (regular ++ node)}'
            ${builtins.readFile ./misc/init.vim}
          '';
        plug.plugins        = with pkgs.vimPlugins; [
          completion-nvim nvim-lspconfig
        ];
        packages.nvim.start = with pkgs.vimPlugins; [
          airline
          editorconfig-vim
          gruvbox-community
          fzf-vim
          ranger-vim
          vim-better-whitespace vim-jsonnet vim-nix vim-signify
        ];
      };
      enable       = true;
      package      = pkgs.neovim-unwrapped.overrideAttrs(old: {
        version = "nightly";
        src     = pkgs.fetchFromGitHub {
          owner  = "neovim";
          repo   = "neovim";
          rev    = "nightly";
          sha256 = "1zs7v2l92gmgl9dg67a4ndinnpklxgzwsyfpwy3yhm44z71zzyhf";
        };
      });
      vimAlias     = true;
      vimdiffAlias = true;
      withNodeJs   = false;
      withPython   = false;
      withPython3  = false;
      withRuby     = false;
    };

    starship.enable                = true;
    starship.enableFishIntegration = true;
    starship.settings              = {
      add_newline                         = false;
      character.symbol                    = "~>";
      directory.fish_style_pwd_dir_length = 1;
      directory.truncation_length         = 8;
      prompt_order                        = [
        "username" "hostname" "directory" "git_branch" "git_commit" "git_state"
        "git_status" "character"
      ];
    };
  };
}

