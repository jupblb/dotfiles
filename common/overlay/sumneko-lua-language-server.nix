{
  CoreFoundation, CoreServices, fetchFromGitHub, lib, makeWrapper, ninja, stdenv, gcc
}:

let ninja-flag =
  if stdenv.isDarwin then "-fcompile/ninja/macos.ninja" else "-fcompile/ninja/linux.ninja";
in stdenv.mkDerivation rec {
  buildInputs       = lib.optional stdenv.isDarwin
    [ CoreServices CoreFoundation ];
  installPhase      = ''
    runHook preInstall

    mkdir -p $out/bin $out/extras
    cp -r ./{locale,meta,script,*.lua} $out/extras/
    cp ./bin/Linux/{bee.so,lpeglabel.so} $out/extras
    cp ./bin/Linux/lua-language-server $out/extras/.lua-language-server-unwrapped
    makeWrapper $out/extras/.lua-language-server-unwrapped \
      $out/bin/lua-language-server \
      --add-flags "-E $out/extras/main.lua \
      --logpath='~/.cache/sumneko_lua/log' \
      --metapath='~/.cache/sumneko_lua/meta'"

    runHook postInstall
  '';
  nativeBuildInputs = [ ninja makeWrapper ];
  ninjaFlags        = [ ninja-flag ];
  postBuild         = "cd ../.. && ./3rd/luamake/luamake rebuild";
  pname             = "sumneko-lua-language-server";
  preBuild          = ''
    substituteInPlace 3rd/luamake/compile/ninja/macos.ninja \
      --replace "-mmacosx-version-min=10.12" "-mmacosx-version-min=10.15" \
      --replace "clang" "$CC"

    cd 3rd/luamake
  '';
  src               = fetchFromGitHub {
    fetchSubmodules = true;
    owner           = "sumneko";
    repo            = "lua-language-server";
    rev             = version;
    sha256          = "1jknnb6gv11rn5abrapib90b0za9iaz2dh6xas38aacxrr79a3nr";
  };
  version           = "1.20.3";
}
