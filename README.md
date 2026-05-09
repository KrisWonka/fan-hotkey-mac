# fan-hotkey-mac

> 🪦 **This repo is the historical Macs Fan Control–era version (single ⌃⌥⌘+8 toggle between Auto and Full Blast).**
>
> The successor — with multi-segment fan curves, named profiles (Silence / Performance / Turbo), and a hotkey that cycles through them — has moved to a new project that pairs with [TG Pro](https://www.tunabellysoftware.com/tgpro/) instead (TG Pro has a properly Apple-Developer-signed SMC helper that works on Apple Silicon).
>
> **👉 Use [tgpro-hotkey-mac](https://github.com/KrisWonka/tgpro-hotkey-mac) for new installs.**
>
> This repo is left online for reference; it still works on Macs Fan Control, but won't get further updates.

---

[English](README.md) | [中文](README.zh.md)

One-shot macOS hotkey to toggle [Macs Fan Control](https://crystalidea.com/macs-fan-control) between **Full Blast ↔ Auto**, with an auto-revert timer and a SwiftUI configurator.

- **Global hotkey** (default ⌃⌥⌘ + 8) flips the fan preset — no MFC window ever flashes
- **Auto-revert timer**: after switching to Full Blast, automatically fall back to Auto in N minutes so you don't leave fans screaming after the workload is done
- Customizable on-screen alert text and duration (Hammerspoon `hs.alert`)
- SwiftUI configurator app (`Fan Hotkey.app`) — Settings / Status / About tabs

> Verified on Apple Silicon. Tested with Macs Fan Control 1.5.21+ (relies on its `/minimized` launch flag).

## How it works

Writes MFC's `ActivePreset` via `defaults` to either `Predefined:1` (Full Blast) or `Predefined:0` (Auto), then quits MFC and re-launches it in the background with `/minimized` — the whole switch is silent and window-less.

| Component | Role |
|------|------|
| `fan-hotkey.lua` | Hammerspoon module — hotkey, toggle logic, auto-revert timer |
| `Fan Hotkey.app` (SwiftUI) | Configurator GUI — all editable options + status checks |
| `~/.hammerspoon/fan-hotkey-config.json` | Single source of truth — written by the app, read by the lua |

## Install

### Fresh-Mac one-liner (also installs [clamshell-mode-mac](https://github.com/KrisWonka/clamshell-mode-mac))

Bootstraps Xcode CLT, Homebrew, Hammerspoon, Macs Fan Control, and both projects:

```bash
curl -fsSL https://raw.githubusercontent.com/KrisWonka/clamshell-mode-mac/main/bootstrap.sh | bash
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
1. Copy `fan-hotkey.lua` to `~/.hammerspoon/`
2. Append `require("fan-hotkey")` to `~/.hammerspoon/init.lua`
3. Build `Fan Hotkey.app` and install it to `/Applications/`
4. Reload Hammerspoon

Or grab the prebuilt `.dmg` from [Releases](https://github.com/KrisWonka/fan-hotkey-mac/releases) and drag the app into Applications, then run `./install.sh` to wire up the Hammerspoon side.

## Usage

### Hotkey
Default **`⌃⌥⌘ + 8`** toggles Full Blast / Auto (rebindable in the GUI).

### Configurator (`Fan Hotkey.app`)
Open via Spotlight. Three tabs:

- **Settings**: hotkey, alert text, alert duration, auto-revert countdown
- **Status**: live check of MFC install, Hammerspoon process, current preset
- **About**: repo link

Hits "Save & Reload" to persist the config and bounce Hammerspoon.

## Uninstall

```bash
./uninstall.sh
```

## License

MIT
