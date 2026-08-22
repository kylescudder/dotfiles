This is a place for all of my Linux (Arch btw) dotfiles and scripts so if my machine goes tits up it doesn't take me three weeks to get set up and running again.

## Setup

Clone the repository to `$HOME/Documents/Repos/dotfiles`, then run the rerunnable bootstrap script:

```bash
./bootstrap/install
```

## Commands

The `scripts` Stow package exposes its executables through `~/.local/bin`:

```bash
stow --target="$HOME" scripts
headphones
```

Both the Bash and Zsh configuration add `~/.local/bin` to `PATH`. The available commands are:

- `CTWorkDay`
- `change_audio`
- `create-vm-from-template`
- `headphones`
- `launchspt`
- `plex_update`
- `rofi-toggle`
- `songchange`
- `songnotification`
- `speakers`
- `stashpullpop`

Machine bootstrapping remains in `bootstrap/`, the Windows installer is in `windows/`, and non-executable working snippets are in `snippets/`.

## Timers and alarms

Bide provides timers and alarms through Rofi. The bootstrap script installs it, while these dotfiles provide the desktop adapters.

```bash
stow rofi waybar hyprland
```

Open the `Timers & Alarms` Rofi mode to create or manage entries. Waybar shows the next active countdown, hides it when no timer is running, and keeps alarms in the Rofi interface. Click the countdown to open Bide or middle-click it to pause or resume the displayed timer.

## Notifications

```bash
stow --target="$HOME" swaync
swaync-client --reload-config
```

Spotify song changes are kept in the notification center without showing a popup.
