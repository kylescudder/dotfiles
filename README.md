This is a place for my Linux dotfiles, scripts, and declarative NixOS workstation configuration so if my machine goes tits up it doesn't take me three weeks to get set up and running again.

## Setup

Clone the repository to `$HOME/Documents/Repos/dotfiles`, then build and switch the `stevie` configuration:

```bash
nix build .#nixosConfigurations.stevie.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#stevie
```

The NixOS configuration lives under `nixos/`, while Home Manager owns the user environment under `home/`. Existing application configs remain live-linked from this checkout so they can still be edited directly in the repository.

## Commands

Home Manager exposes the `scripts` package through `~/.local/bin`. The available commands are:

- `CTWorkDay`
- `change_audio`
- `create-vm-from-template`
- `headphones`
- `launchspt`
- `rofi-toggle`
- `songchange`
- `songnotification`
- `speakers`
- `stashpullpop`

Both the Bash and Zsh configuration add `~/.local/bin` to `PATH`.

The Windows installer remains in `windows/`, and non-executable working snippets are in `snippets/`.

## Timers and alarms

Bide provides timers and alarms through Rofi. Bide is intentionally not packaged in the current NixOS configuration yet; these dotfiles retain the desktop integrations for when it is added back.

Open the `Timers & Alarms` Rofi mode to create or manage entries. Waybar shows the next active countdown, hides it when no timer is running, and keeps alarms in the Rofi interface. Click the countdown to open Bide or middle-click it to pause or resume the displayed timer.

## Notifications

SwayNC is installed declaratively through Home Manager, with the Catppuccin Mocha theme managed by the Catppuccin Home Manager module.

Spotify song changes are kept in the notification center without showing a popup.
