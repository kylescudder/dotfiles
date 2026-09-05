{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  home.packages = with pkgs; [
    nodejs
    bun
    dotnet-sdk
    gh
    neovim
    lazygit
    python3
    python3Packages.pip
  ];
}
