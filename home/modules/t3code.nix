{ pkgs, inputs, ... }:

{
  programs.t3code = {
    enable = true;

    package =
      inputs.nixpkgs-t3.legacyPackages.${pkgs.stdenv.hostPlatform.system}.t3code;
  };
}
