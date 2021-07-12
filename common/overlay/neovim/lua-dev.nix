{ vimUtils }:

vimUtils.buildVimPlugin rec {
  pname     = "lua-dev";
  version   = "main";
  src       = builtins.fetchGit {
    ref = version;
    url = https://github.com/folke/lua-dev.nvim.git;
  };
}
