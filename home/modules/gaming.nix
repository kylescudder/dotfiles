{ pkgs, ... }:
let
  bedrockOnLinux = pkgs.callPackage ../../packages/bedrock-on-linux.nix { };
in
{
  home.packages = with pkgs; [
    prismlauncher
    bedrockOnLinux
  ];
}
