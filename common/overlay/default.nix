self: super: with super; {
  ammonite         = ammonite // {
    predef = pkgs.fetchurl {
      url    = https://git.io/vHaKQ;
      sha256 = "1kir3j5z3drkihx1hysdcmjaiacz840qpwbz70v4k62jr95mz3jp";
    };
  };
  chromium-wayland = callPackage ./chromium-wayland {};
  fish-plugins     = import ./fish { inherit (super) callPackage; };
  k8s-test-infra   = callPackage ./kubernetes/test-infra.nix {};
  lf               = callPackage ./lf { lf = super.lf; };
  htop             = callPackage ./htop { htop = super.htop; };
  neovim-nightly   = callPackage ./neovim {};
  pragmata-pro     = callPackage ./pragmata-pro {};
  ripgrep          =
    let rg_12 = builtins.fetchurl
      https://raw.githubusercontent.com/NixOS/nixpkgs/85f96822a05180cbfd5195e7034615b427f78f01/pkgs/tools/text/ripgrep/default.nix;
    in callPackage rg_12 { inherit (darwin.apple_sdk.frameworks) Security; };
  vimPlugins       = vimPlugins // {
    compe-tabnine    = callPackage ./neovim/compe-tabnine.nix {
      inherit (vimPlugins) compe-tabnine;
      inherit (stdenv.hostPlatform) system;
    };
    google-filetypes = callPackage ./neovim/google-filetypes.nix {};
    nvim-bqf         = callPackage ./neovim/nvim-bqf.nix {
      inherit (vimPlugins) nvim-bqf;
    };
  };
}
