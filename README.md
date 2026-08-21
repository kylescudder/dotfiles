This is a place for all of my linux (Arch btw) dotfiles so if my machine goes tits up it doesn't take me three weeks to get set up and running again.

## Waybar Pomodoro

The Waybar timer uses [Tomat](https://github.com/jolars/tomat), with controls exposed through Rofi.

```bash
paru -S tomat-bin
stow tomat rofi waybar hyprland
```

Tomat starts with Hyprland. Click the timer in Waybar to open the Rofi menu, middle-click to pause or resume, and right-click to skip the current phase.
