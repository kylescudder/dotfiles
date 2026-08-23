# Rofi design drafts

All six themes keep the launcher's application, window, command, media, timer,
sound, and session modes intact.

Open `preview.html` in any modern browser for a dependency-free visual comparison.
The launchers are enlarged there so their layout and selected states are easy to
inspect; they are not shown at literal 2560×1440 scale.

| Theme | Direction | Try it |
| --- | --- | --- |
| `flight-deck` | Amber avionics console | `launcher.sh --theme flight-deck` |
| `field-notes` | Warm editorial index cards | `launcher.sh --theme field-notes` |
| `phosphor` | Dense green CRT terminal | `launcher.sh --theme phosphor` |
| `bento` | Friendly two-column utility grid, best for apps | `launcher.sh --theme bento` |
| `ultraviolet` | Low-profile midnight command palette | `launcher.sh --theme ultraviolet` |
| `omarchy` | Restrained, narrow Omarchy-inspired menu | `launcher.sh --theme omarchy` |

Pass a mode after `--show`, for example:

```bash
launcher.sh --theme field-notes --show window
```

To use a draft for every invocation without editing the script:

```bash
ROFI_THEME=bento launcher.sh
```

Once a favorite is clear, change the fallback in `launcher.sh` from
`ROFI_THEME:-cockpit` to that theme's name.
