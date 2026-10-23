{ pkgs, ... }:

let
  version = "0.1.3-nightly.20261023.3566";

  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-lpUxjpIAi1YA8AiM5yPyAGddKZiOo15kuqBUH/Uj+cI=";
  };

  contents = pkgs.appimageTools.extractType2 {
    pname = "t3code";
    inherit version src;
  };

  t3code = pkgs.appimageTools.wrapType2 {
    pname = "t3code";
    inherit version src;

    extraInstallCommands = ''
      # Install all of T3 Code's bundled icons.
      # The AppImage does not contain a desktop entry, so provide one.
      install -Dm644 ${pkgs.writeText "t3code.desktop" ''
        [Desktop Entry]
        Name=T3 Code
        Comment=Agentic IDE
        Exec=t3code
        Icon=${contents}/usr/share/icons/hicolor/512x512/apps/t3code.png
        Terminal=false
        Type=Application
        Categories=Development;
        StartupNotify=true
      ''} $out/share/applications/t3code.desktop
    '';
  };
in
{
  home.packages = [
    t3code
  ];
}
