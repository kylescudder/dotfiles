This is a place for all of my linux (Arch btw) dotfiles so if my machine goes tits up it doesn't take me three weeks to get set up and running again.

## Timers and alarms

Bide provides timers and alarms through Rofi. It is installed separately; these dotfiles only provide the desktop adapters.

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
