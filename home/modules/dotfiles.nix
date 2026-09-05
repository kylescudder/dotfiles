{ config, lib, inputs, ... }:
let
  liveDotfilesRoot =
    "${config.home.homeDirectory}/Documents/Repos/dotfiles";

  linkPackage = packageName: destinationRoot:
    let
      storeRoot = inputs.self + "/${packageName}";
      files = lib.filesystem.listFilesRecursive storeRoot;
      storeRootString = toString storeRoot + "/";
    in
    builtins.listToAttrs (
      map
        (path:
          let
            relativePath = builtins.unsafeDiscardStringContext (
              lib.removePrefix storeRootString (toString path)
            );
          in
          {
            name =
              if destinationRoot == ""
              then relativePath
              else "${destinationRoot}/${relativePath}";

            value.source =
              config.lib.file.mkOutOfStoreSymlink
                "${liveDotfilesRoot}/${packageName}/${relativePath}";
          })
        files
    );

  dotfiles =
    lib.foldl' lib.recursiveUpdate { } [
      (linkPackage "hyprland" ".config/hypr")
      (linkPackage "waybar" ".config/waybar")
      (linkPackage "nvim" ".config/nvim")
      (linkPackage "lazygit" ".config/lazygit")
      (linkPackage "spotify-player" ".config/spotify-player")
      (linkPackage "spotifyd" ".config/spotifyd")
      (linkPackage "fastfetch" ".config/fastfetch")
      (linkPackage "rofi" ".config/rofi")
      (linkPackage "yazi" ".config/yazi")
      (linkPackage "ghostty" ".config/ghostty")
      (linkPackage "kitty/.config/kitty" ".config/kitty")
      (linkPackage "btop" ".config/btop")
      (linkPackage "wlogout" ".config/wlogout")
      (linkPackage "herdr" ".config/herdr")

      (linkPackage "starship" ".config")

      (linkPackage "bashrc" "")
      (linkPackage "zsh" "")

      (linkPackage "scripts" ".local/bin")
      (linkPackage "icons" ".local/share/icons")
      (linkPackage "wallpapers" ".local/share/wallpapers")
    ];
in
{
  # Keep existing dotfiles as source-of-truth during the migration. Individual
  # configs can be converted to native Home Manager modules independently.
  home.file = dotfiles;
}
