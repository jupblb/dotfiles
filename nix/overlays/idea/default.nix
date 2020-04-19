{
  idea-ultimate, jdk, lib, openjdk11, linuxPackages_latest, makeWrapper,
  symlinkJoin
}:

symlinkJoin {
  buildInputs = [ makeWrapper ];
  name        = "idea";
  paths       = [ idea-ultimate ];
  postBuild   = ''
    wrapProgram "$out/bin/idea-ultimate" \
      --prefix PATH : ${lib.makeBinPath[ linuxPackages_latest.perf openjdk11 ]} \
      --set-default IDEA_JDK "${jdk}" \
      --set-default IDEA_PROPERTIES "${./idea.properties}" \
      --set-default IDEA_VM_OPTIONS "${./idea64.vmoptions}"
  '';
}