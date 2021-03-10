self: super: rec {
  chromium-wayland = super.callPackage ./chromium-wayland/default.nix {};
  emacs-wrapped    = super.callPackage ./emacs {};
  fishPlugins      = import ./fish { inherit (super) callPackage; };
  lf               = super.callPackage ./lf { lf = super.lf; };
  lf-previewer     = super.callPackage ./lf/previewer.nix {};
  htop             = super.callPackage ./htop { htop = super.htop; };
  neovim-nightly   = super.callPackage ./neovim {};
  pragmata-pro     = super.callPackage ./pragmata-pro {};
  vimPlugins       = super.vimPlugins // {
    gruvbox-nvim = super.callPackage ./neovim/gruvbox-nvim.nix {};
  };
}
