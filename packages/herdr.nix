{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "herdr";
  version = "0.8.9";

  src = fetchurl {
    url = "https://github.com/kylescudder/herdr/releases/download/v0.8.9/herdr-linux-x86_64";
    hash = "sha256-UZfK2zAC6ZQk+xWn/SwwpctdUZObOBi/+CPh9AJizFM=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/herdr
    chmod +x $out/bin/herdr

    runHook postInstall
  '';

  meta = {
    description = "Herdr CLI";
    homepage = "https://github.com/kylescudder/herdr";
    license = lib.licenses.asl20;
    mainProgram = "herdr";
    platforms = [ "x86_64-linux" ];
  };
}
