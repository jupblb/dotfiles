{ fetchFromGitHub, vimUtils }:

let lush-nvim = vimUtils.buildVimPlugin {
  pname   = "lush-nvim";
  src     = fetchFromGitHub {
    owner  = "rktjmp";
    repo   = "lush.nvim";
    rev    = "main";
    sha256 = "0s5aknyj021x1d994npc0pmrzl2c7bbxyyj3yb6n741zbxrz4fjv";
  };
  version = "master";
};
in vimUtils.buildVimPlugin {
  dependencies = [ lush-nvim ];
  pname        = "gruvbox-nvim";
  src          = fetchFromGitHub {
    owner  = "npxbr";
    repo   = "gruvbox.nvim";
    rev    = "main";
    sha256 = "16984i0xa7bhkjrmjm3can0q4fjlnpzvz0074y2hhp4iqsgbrsna";
  };
  version      = "master";
}
