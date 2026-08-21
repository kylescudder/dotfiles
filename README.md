This is a place for all of my linux (Arch btw) dotfiles so if my machine goes tits up it doesn't take me three weeks to get set up and running again.

## Timers and alarms

[Bide](https://github.com/kylescudder/bide) is the standalone timer and alarm
application used by the Rofi and Waybar adapters. Install or update the pinned
release idempotently, then Stow the desktop configuration:

```bash
./scripts/install
stow rofi waybar hyprland
```

Override the release with `BIDE_VERSION=0.2.0 ./scripts/install`. The installer
downloads a versioned release binary, installs and enables the persistent user
systemd timer, reloads the user manager, and verifies the executable. Application
state remains under `$XDG_STATE_HOME/bide`; it is never written into dotfiles.

Open the `Timers & Alarms` Rofi mode to create or manage entries. Waybar shows
the next active countdown and hides it when no timer is active. Left click opens
the list, middle click pauses or resumes the displayed timer, and right click
opens that timer's action menu.
