{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "bedrock-on-linux";
  version = "2.2.4";

  src = fetchurl {
    url = "https://github.com/Wyze3306/BedrockOnLinux/releases/download/v${version}/BedrockOnLinux-${version}-x86_64.AppImage";
    hash = "sha256-Pmw9r1EYNbIKd8/YyK+0VZn+UsDMp3dBK71muGF4xt4=";
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${contents}/bedrock-on-linux.desktop \
      $out/share/applications/bedrock-on-linux.desktop

    install -m 444 -D ${contents}/bedrock-on-linux.png \
      $out/share/icons/hicolor/256x256/apps/bedrock-on-linux.png
  '';

  meta = {
    description = "Minecraft Bedrock Edition launcher for Linux";
    homepage = "https://github.com/Wyze3306/BedrockOnLinux";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "bedrock-on-linux";
  };
}
