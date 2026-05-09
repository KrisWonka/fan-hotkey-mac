# fan-hotkey-mac

[English](README.md) | [中文](README.zh.md)

macOS global hotkey that cycles [Macs Fan Control](https://crystalidea.com/macs-fan-control) through a user-defined list of fan modes — no MFC window ever flashes.

- **Configurable cycle list** — add / remove / reorder steps. Each step is one of:
  - **Auto** — MFC's default temperature curve
  - **Full Blast** — all fans at max RPM (with optional N-minute auto-revert)
  - **Cooldown** — full blast until average CPU temp drops below a threshold (default 40°C), then auto back to Auto
- **Global hotkey** (default ⌃⌥⌘ + 8) advances the cycle one step
- **Per-step parameters**: each cycle entry can be expanded inline to rename it and tune its own thresholds (cooldown target temp / poll interval, Full Blast revert countdown, etc.)
- **Apple Silicon temperature reading** via a tiny Swift helper (`readtemp`) using the same private `IOHIDEventSystemClient` API that Macs Fan Control / Stats / iStatistica use
- SwiftUI configurator app (`Fan Hotkey.app`) — Settings / Status / About tabs

> Verified on Apple Silicon. Tested with Macs Fan Control 1.5.21+ (relies on its `/minimized` launch flag).

## How it works

Writes MFC's `ActivePreset` via `defaults` to either `Predefined:1` (Full Blast) or `Predefined:0` (Auto), then quits MFC and re-launches it in the background with `/minimized` — the whole switch is silent and window-less. Cooldown steps additionally poll `readtemp` to know when to drop back to Auto.

| Component | Role |
|------|------|
| `fan-hotkey.lua` | Hammerspoon module — hotkey, cycle-list state machine, cooldown polling |
| `readtemp` (Swift) | Reads Apple Silicon CPU temperature via `IOHIDEventSystemClient` |
| `Fan Hotkey.app` (SwiftUI) | Configurator GUI — cycle-list editor + per-step expandable params |
| `~/.hammerspoon/fan-hotkey-config.json` | Single source of truth — written by the app, read by the lua |

## Install

### Fresh-Mac one-liner

Bootstraps everything this project needs from scratch — Xcode CLT, Homebrew, Hammerspoon, Macs Fan Control, then clones and installs:

```bash
curl -fsSL https://raw.githubusercontent.com/KrisWonka/fan-hotkey-mac/main/bootstrap.sh | bash
```

### Manual

Requires:
- [Hammerspoon](https://www.hammerspoon.org/)
- [Macs Fan Control](https://crystalidea.com/macs-fan-control) (`brew install --cask macs-fan-control`)
- Xcode Command Line Tools (`xcode-select --install`)

```bash
git clone https://github.com/KrisWonka/fan-hotkey-mac.git
cd fan-hotkey-mac
./install.sh
```

The installer will:
1. Compile `readtemp` (Apple Silicon temperature reader) into `~/.hammerspoon/`
2. Copy `fan-hotkey.lua` to `~/.hammerspoon/`
3. Append `require("fan-hotkey")` to `~/.hammerspoon/init.lua`
4. Build `Fan Hotkey.app` and install it to `/Applications/`
5. Reload Hammerspoon

Or grab the prebuilt `.dmg` from [Releases](https://github.com/KrisWonka/fan-hotkey-mac/releases) and drag the app into Applications, then run `./install.sh` to wire up the Hammerspoon side.

## Usage

### Hotkey
Default **`⌃⌥⌘ + 8`** advances one step in your cycle list (rebindable in the GUI). Default cycle: Auto → Full Blast → Cooldown → Auto.

### Configurator (`Fan Hotkey.app`)
Open via Spotlight. Three tabs:

- **Settings**:
  - **Cycle list** — add (Auto / Full Blast / Cooldown), delete, reorder with ↑↓; click ▶ to expand a step and rename it / tune its params
  - **Hotkey** — global hotkey + enable toggle
  - **Alerts** — on-screen prompt toggle, cooldown-done text, display duration
- **Status**: live check of MFC install, Hammerspoon process, current preset
- **About**: repo link

Hit "Save & Reload" to persist and bounce Hammerspoon.

## Manual config

You can edit `~/.hammerspoon/fan-hotkey-config.json` directly without the GUI, then reload Hammerspoon. Schema:

```json
{
  "hotkeyEnabled": true,
  "hotkeyMods": ["ctrl", "alt", "cmd"],
  "hotkeyKey": "8",
  "alertEnabled": true,
  "alertDuration": 1.2,
  "alertCooldownDone": "Cooldown done ✓",
  "cycleSteps": [
    { "type": "auto", "name": "" },
    { "type": "fullBlast", "name": "", "autoRevertEnabled": false, "autoRevertSec": 600 },
    { "type": "cooldown",  "name": "", "cooldownTargetTemp": 40, "cooldownPollSec": 3 }
  ]
}
```

`cycleSteps` is the source of truth for the hotkey cycle. Each step's `type` is one of `auto` / `fullBlast` / `cooldown`. `name` is an optional override of the default display name. Type-specific fields (`autoRevertSec`, `cooldownTargetTemp`, etc.) are read only for matching types.

## Uninstall

```bash
./uninstall.sh
```

## Acknowledgements

- [Macs Fan Control](https://crystalidea.com/macs-fan-control) by Crystalidea — does the actual SMC fan control
- [Hammerspoon](https://www.hammerspoon.org/) — macOS automation framework powering the hotkey + state machine
- The `IOHIDEventSystemClient` temperature-reading approach is the same one used by [Stats](https://github.com/exelban/stats), [iStatistica](https://www.imagetasks.com/system-monitor-mac/), and Macs Fan Control itself

## License

MIT
