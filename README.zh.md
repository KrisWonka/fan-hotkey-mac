# fan-hotkey-mac

[English](README.md) | [中文](README.zh.md)

macOS 全局快捷键，按用户自定义的「档位列表」循环切换 [Macs Fan Control](https://crystalidea.com/macs-fan-control) — 全程后台无窗口闪现。

- **可配置档位列表** — 增删、用 ↑↓ 排序；每档可以是：
  - **Auto** — MFC 默认温控曲线
  - **Full Blast** — 全速（可设 N 分钟自动回 Auto）
  - **Cooldown** — 全速直到平均 CPU 温度降到目标值（默认 40°C）后自动回 Auto
- **全局快捷键**（默认 ⌃⌥⌘ + 8）按一次前进一档
- **每档独立参数**：列表里点 ▶ 三角展开能改名、调这一档专属的参数（Cooldown 目标温度/轮询、Full Blast 回切倒计时等）
- **Apple Silicon 温度读取**：自带一个小 Swift 工具 `readtemp`，走和 MFC / Stats / iStatistica 同一个私有 `IOHIDEventSystemClient` API
- **SwiftUI 配置 GUI**：Fan Hotkey.app

> Apple Silicon Mac 验证通过。Macs Fan Control 1.5.21+ 测试通过（依赖 `/minimized` 启动参数）。

## 工作原理

写 `defaults` 把 MFC 的 `ActivePreset` 切到 `Predefined:1`（Full Blast）或 `Predefined:0`（Auto），然后退出 MFC 并以 `/minimized` 参数后台重启 — 整个过程无窗口闪现。Cooldown 档位由 `readtemp` 轮询 CPU 平均温度触发回切。

| 组件 | 作用 |
|------|------|
| `fan-hotkey.lua` | Hammerspoon 主逻辑：快捷键、档位列表状态机、Cooldown 轮询 |
| `readtemp` (Swift) | 读 Apple Silicon CPU 温度（IOHIDEventSystemClient） |
| `Fan Hotkey.app` (SwiftUI) | 配置 GUI：档位列表编辑器 + 每档可展开参数 |
| `~/.hammerspoon/fan-hotkey-config.json` | 单一配置源，App 写入，lua 读取 |

## 安装

### 全新 Mac 一键装

把本项目需要的 Xcode CLT、Homebrew、Hammerspoon、Macs Fan Control 和项目本身一次性装好：

```bash
curl -fsSL https://raw.githubusercontent.com/KrisWonka/fan-hotkey-mac/main/bootstrap.sh | bash
```

### 手动

依赖：
- [Hammerspoon](https://www.hammerspoon.org/)
- [Macs Fan Control](https://crystalidea.com/macs-fan-control)（`brew install --cask macs-fan-control`）
- Xcode Command Line Tools (`xcode-select --install`)

```bash
git clone https://github.com/KrisWonka/fan-hotkey-mac.git
cd fan-hotkey-mac
./install.sh
```

安装脚本会：
1. 编译 `readtemp`（Apple Silicon 温度读取）到 `~/.hammerspoon/`
2. 拷贝 `fan-hotkey.lua` 到 `~/.hammerspoon/`
3. 在 `~/.hammerspoon/init.lua` 末尾追加 `require("fan-hotkey")`
4. 编译 `Fan Hotkey.app` 装到 `/Applications/`
5. 重载 Hammerspoon

完成后右上角菜单栏不会有图标（通过快捷键操作），Spotlight 搜「Fan Hotkey」打开 GUI 配置。

或者直接下 [Releases](https://github.com/KrisWonka/fan-hotkey-mac/releases) 里预编好的 `.dmg`，把 `Fan Hotkey.app` 拖进 Applications，再跑一次 `./install.sh` 把 Hammerspoon 那边接好。

## 使用

### 快捷键
默认 **`⌃⌥⌘ + 8`** 在档位列表里前进一档（GUI 里可改）。默认列表：Auto → Full Blast → Cooldown → Auto。

### 配置 GUI（**Fan Hotkey.app**）
Spotlight 搜「Fan Hotkey」打开。三个标签：

- **Settings**：
  - **循环档位**：增删（Auto / Full Blast / Cooldown）、↑↓ 排序；点 ▶ 展开改名 / 调本档参数
  - **快捷键**：组合键、启用开关
  - **提示**：屏幕中央提示开关、Cooldown 完成文字、显示时长
- **Status**：实时显示 MFC 是否安装、Hammerspoon 是否运行、当前预设
- **About**：仓库链接

保存后自动重载 Hammerspoon。

## 手动改配置

不开 GUI 也能改 —— 编辑 `~/.hammerspoon/fan-hotkey-config.json`，然后 reload Hammerspoon。Schema：

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

`cycleSteps` 是快捷键循环的唯一来源。每档的 `type` 必须是 `auto` / `fullBlast` / `cooldown` 之一。`name` 是可选的显示名覆盖（空串 = 用类型默认名）。类型专属字段（`autoRevertSec` / `cooldownTargetTemp` 等）只在对应 type 下生效。

## 卸载

```bash
./uninstall.sh
```

## 致谢

- [Macs Fan Control](https://crystalidea.com/macs-fan-control)（Crystalidea 出品）—— 真正干 SMC 风扇控制的活
- [Hammerspoon](https://www.hammerspoon.org/) —— macOS 自动化框架，撑起快捷键 + 状态机
- `IOHIDEventSystemClient` 温度读取的思路参考 [Stats](https://github.com/exelban/stats)、[iStatistica](https://www.imagetasks.com/system-monitor-mac/) 和 MFC 自身

## License

MIT
