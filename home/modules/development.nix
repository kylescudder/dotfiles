{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs
    bun
    dotnet-sdk
    neovim
    lazygit
    python3
    python3Packages.pip
    fzf
  ];
}
