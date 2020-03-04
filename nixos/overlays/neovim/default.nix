{ all-hies', bash-language-server, lib, makeWrapper, neovim, openjdk8, rustc, stdenv, symlinkJoin, vimPlugins }:

let
  neovim' = neovim.override {
    configure   = {
      customRC = builtins.readFile(./init.vim);

      packages.myVimPackage = with vimPlugins; {
        opt   = [ ];
        start = [
          airline
          ctrlp
#         coc-json
#         coc-metals
          coc-nvim
#         coc-rust-analyzer
          easymotion
          fugitive
          gitgutter
          goyo
          gruvbox-community
          surround
          vim-nix
          vim-startify
        ];
      };
    };

    vimAlias = true;
  
    withNodeJs  = true;
    withPython  = false;
    withPython3 = false;
    withRuby    = false;
  };
in symlinkJoin {
  buildInputs = [ makeWrapper ];
  name        = "nvim";
  paths       = [ neovim' ];
  postBuild   = ''
    wrapProgram "$out/bin/nvim" --prefix PATH : ${lib.makeBinPath [ all-hies' bash-language-server openjdk8 ]}
  '';
}
