# Arch bootstrap → NixOS conversion

This repository now contains the declarative NixOS + Home Manager configuration
for the `stevie` workstation.

It replaces the previous imperative Arch bootstrap while keeping the dotfiles
repository as the source of truth for user configuration.

## Layout

- `flake.nix` — pins NixOS 26.05, Home Manager and external package/theme inputs.
- `nixos/hosts/workstation/configuration.nix` — system configuration for `stevie`.
- `nixos/hosts/workstation/hardware-configuration.nix` — hardware configuration for
  the actual `stevie` machine.
- `home/kyle.nix` — user packages, 1Password SSH integration and live dotfile
  links.
- `packages/herdr.nix` — packages the published Herdr release binary.

## Dotfile management

GNU Stow is no longer used.

Home Manager manages the links into `$HOME`, but the actual configuration files
remain in the live Git checkout at:

    ~/Documents/Repos/dotfiles

For example:

    ~/Documents/Repos/dotfiles/nvim/init.lua

is exposed as:

    ~/.config/nvim/init.lua

and:

    ~/Documents/Repos/dotfiles/hyprland/hyprland.lua

is exposed as:

    ~/.config/hypr/hyprland.lua

These are out-of-store links. Editing the file through either location edits the
tracked Git file directly.

This is intentional: configuration files such as Neovim's `lazy-lock.json` need
to remain writable, and day-to-day dotfile changes should not require copying the
files into the immutable Nix store.

The current mappings include:

    hyprland     -> ~/.config/hypr
    waybar       -> ~/.config/waybar
    nvim         -> ~/.config/nvim
    spotify-player -> ~/.config/spotify-player
    spotifyd     -> ~/.config/spotifyd
    fastfetch    -> ~/.config/fastfetch
    rofi         -> ~/.config/rofi
    yazi         -> ~/.config/yazi
    ghostty      -> ~/.config/ghostty
    btop         -> ~/.config/btop
    wlogout      -> ~/.config/wlogout
    starship     -> ~/.config
    bashrc       -> ~
    zsh          -> ~
    scripts      -> ~/.local/bin
    applications -> ~/.local/share/applications
    icons        -> ~/.local/share/icons
    wallpapers   -> ~/.local/share/wallpapers

Because these are live links, the repository must exist at:

    ~/Documents/Repos/dotfiles

before Home Manager activates the user configuration.

### Existing homes previously managed by Stow

If this configuration is being applied to an existing home directory that was
previously managed with GNU Stow, remove or unstow the old managed symlinks before
the first Home Manager activation.

A fresh home directory does not require this step.

## What should eventually become native Home Manager config?

This can be done gradually and is not required for the migration.

Good candidates are Git, SSH, Zsh and Starship because Home Manager has mature
modules for them.

Hyprland, Waybar, Rofi, Ghostty and Neovim can remain as normal tracked config
files indefinitely if preferred.

Rule: a file should have one owner. If a Home Manager module starts generating a
file that is currently linked from the dotfiles repository, remove the dotfile
mapping for that file at the same time.

## Reinstalling `stevie`

The checked-in `hardware-configuration.nix` belongs to the actual `stevie`
workstation and should not be replaced during a normal reinstall of the same
machine.

1. Back up any required user data and the dotfiles repository.
2. Boot the NixOS 26.05 installer.
3. Partition and mount the target filesystem at `/mnt`.
4. Make the dotfiles repository available to the installer.
5. Install using the existing `stevie` configuration:

       sudo nixos-install --flake /path/to/dotfiles#stevie

6. Set the user's password before rebooting if required:

       sudo nixos-enter --root /mnt -c 'passwd kyle'

7. Boot NixOS.
8. Clone or place the dotfiles repository at:

       ~/Documents/Repos/dotfiles

9. Open 1Password and enable **Developer → Use the SSH agent**.
10. Authenticate Tailscale once if required:

       sudo tailscale login

Future changes are applied with:

    sudo nixos-rebuild switch --flake ~/Documents/Repos/dotfiles#stevie

For risky changes, use:

    sudo nixos-rebuild test --flake ~/Documents/Repos/dotfiles#stevie

A reboot returns to the previously booted generation if a test configuration is
bad.

## Adding another machine

Do not overwrite `stevie`'s checked-in hardware configuration when adding a
different machine.

Instead:

1. Generate that machine's hardware configuration:

       sudo nixos-generate-config --root /mnt

2. Create a new host directory:

       nixos/hosts/<hostname>/

3. Put that machine's `configuration.nix` and
   `hardware-configuration.nix` there.
4. Add a matching:

       nixosConfigurations.<hostname>

   entry to `flake.nix`.

Each machine should keep its own hardware configuration under its own host
directory.

## Hardware-specific notes

### NVIDIA

`stevie` uses an NVIDIA RTX 3080 with the open NVIDIA kernel modules:

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

32-bit graphics support is also enabled for applications such as Steam.

### Bootloader

The motherboard does not reliably honour custom EFI NVRAM boot entries, so GRUB
is installed to the standard removable/fallback EFI path:

    EFI/BOOT/BOOTX64.EFI

The relevant configuration is:

    boot.loader.efi.canTouchEfiVariables = false;
    boot.loader.grub.efiInstallAsRemovable = true;

### Xbox xone

The previous handwritten DKMS clone/install is replaced with:

    hardware.xone.enable = true;

This keeps the kernel module under NixOS generation management rather than
mutating `/lib/modules` outside Nix.

## Package conversion notes

- `paru` / AUR: removed. Nix inputs, nixpkgs or local Nix packages now own
  dependencies.
- `base-devel`, DKMS and `linux-headers`: no longer globally installed merely to
  build packages. Nix derivations declare their own build dependencies.
- `multilib`: no separate repository toggle. Steam/NVIDIA 32-bit support is
  expressed declaratively.
- Cura: installed declaratively through Nix rather than using the old manually
  managed AppImage launcher.
- Herdr: packaged from the published release binary in `packages/herdr.nix`.
- Helium: consumed as a flake input rather than relying on an imperative
  installation.
- SwayNC Catppuccin: uses the Catppuccin Home Manager module.
- GRUB Catppuccin: uses the Catppuccin NixOS module.

## Deferred migrations

The following functionality existed in the previous environment but is being
migrated separately rather than keeping broken Arch-specific assumptions in the
main configuration:

- NordVPN installation and automatic connection.
- Yap packaging and its user services.
- Minecraft Bedrock / BedrockOnLinux installation.
- T3 Code installation and `t3code://` URL handler.

The associated Hyprland startup commands were removed until each service has a
proper Nix-managed replacement.

## Bide

Bide is intentionally not packaged yet.

It should be migrated separately if it is still needed rather than being
confused with the unrelated historical AUR package of the same name.

## Secrets

Do not place PATs, Tailscale auth keys, SSH private keys, API keys or other
plaintext secrets in this flake.

Flake sources are copied into the Nix store and should not be treated as a
secret store.

The 1Password SSH agent configuration is safe to declare because private key
material remains inside 1Password.
