# Arch bootstrap → NixOS conversion

This directory is intended to be copied into the root of the existing
`kylescudder/dotfiles` repository. It replaces the imperative Arch bootstrap
with NixOS + Home Manager while preserving the existing dotfile files.

## Layout

- `flake.nix` — pins NixOS 26.05, Home Manager and external package/theme inputs.
- `nixos/hosts/workstation/configuration.nix` — system configuration.
- `nixos/hosts/workstation/hardware-configuration.nix` — placeholder that MUST
  be replaced by the file generated for the actual machine during install.
- `home/kyle.nix` — user packages, 1Password SSH integration and dotfile links.
- `packages/herdr.nix` — builds Herdr from its existing Cargo.lock instead of
  downloading an opaque release binary.

## What happened to Stow?

Stow is no longer required. Home Manager treats the existing package folders as
file trees rooted at `$HOME`, which matches the useful part of Stow's behaviour.
For example, a tracked file such as:

    hyprland/.config/hypr/hyprland.conf

becomes the managed file:

    ~/.config/hypr/hyprland.conf

The existing files therefore do NOT need to be rewritten merely because the OS
changes to NixOS.

The three data packages are handled specially:

    applications/applications -> ~/.local/share/applications
    icons/icons               -> ~/.local/share/icons
    wallpapers/wallpapers     -> ~/.local/share/wallpapers

This also removes the old bootstrap's accidental first Stow into `$HOME`.

## What should eventually become native Home Manager config?

Do it gradually, not as a prerequisite for migration. Good candidates are Git,
SSH, Zsh and Starship, because Home Manager has mature modules for them. Hyprland,
Waybar, Rofi, Ghostty and Neovim can remain as their existing files indefinitely
if preferred.

Rule: a file must have ONE owner. If `programs.starship` starts generating
`~/.config/starship.toml`, remove the Starship file/tree from the migrated
Stow list at the same time.

## Install flow

1. Commit/back up the existing Arch home and dotfiles repo.
2. Boot the NixOS 26.05 installer.
3. Partition and mount the target filesystem at `/mnt` as normal.
4. Generate the machine-specific hardware file:

       sudo nixos-generate-config --root /mnt

5. Put the dotfiles repo at a temporary path accessible from the installer,
   then replace:

       nixos/hosts/workstation/hardware-configuration.nix

   with:

       /mnt/etc/nixos/hardware-configuration.nix

6. Review the generated boot loader/filesystem settings. The old Arch script's
   GRUB theme is declarative, but the actual boot loader/device selection must
   come from the generated machine config.
7. Build first, before installing:

       sudo nixos-rebuild build --flake .#workstation

   or from the installer use:

       sudo nixos-install --flake /path/to/dotfiles#workstation

8. Set the user's password before rebooting if required:

       sudo nixos-enter --root /mnt -c 'passwd kyle'

9. Boot NixOS, open 1Password, enable **Developer → Use the SSH agent**, then:

       sudo tailscale login

10. Future changes are applied with:

       sudo nixos-rebuild switch --flake ~/Documents/Repos/dotfiles#workstation

For risky changes, use `nixos-rebuild test` first; a reboot returns to the prior
booted generation if the test configuration is bad.

## Hardware-specific checks before first install

### NVIDIA

The Arch bootstrap explicitly installs `nvidia-open`, so this conversion sets:

    hardware.nvidia.open = true;

That is appropriate for supported modern NVIDIA cards. If the actual GPU is too
old for the open kernel module, change it to `false` before installing. If this
is a hybrid Intel/AMD + NVIDIA laptop, PRIME bus IDs must also be added from the
actual hardware; they cannot be inferred from the bootstrap script.

### Xbox xone

The handwritten DKMS clone/install is replaced with:

    hardware.xone.enable = true;

This keeps the kernel module under NixOS generation management rather than
mutating `/lib/modules` outside Nix.

## Package conversion notes

- `paru` / AUR: removed. Nix inputs or nixpkgs own dependencies instead.
- `base-devel`, DKMS and `linux-headers`: no longer globally installed just to
  build packages. Nix derivations declare their own build dependencies.
- `multilib`: no separate repository toggle. Steam/NVIDIA 32-bit support is
  expressed by the Steam module and `hardware.graphics.enable32Bit`.
- Cura: use current `pkgs.cura` instead of pinning the old 5.9.0 AppImage.
- Herdr: built from source via its Cargo.lock.
- Helium: consumed as a flake input because it is not relied on as a stable
  nixpkgs package.
- SwayNC Catppuccin: uses the Catppuccin Home Manager module instead of `curl`.
- GRUB Catppuccin: uses the Catppuccin NixOS module instead of cloning into
  `/usr/share/grub/themes`.

### BIDE

The Arch script installs the AUR package `bide`, which is the old Basic IDE by
Zezombye and depends specifically on Java 8. It does not have a current nixpkgs
package. I have left it out rather than pretend another package is equivalent.
If it is still genuinely needed, package it as a small local Nix derivation;
otherwise removing it from the workstation is the cleaner option.

## Secrets

Do not place PATs, Tailscale auth keys, SSH private keys, API keys or other
plaintext secrets in this flake. Flake sources are copied into the Nix store,
which is readable by local users. The 1Password agent socket/config is safe to
declare because the key material remains inside 1Password.
