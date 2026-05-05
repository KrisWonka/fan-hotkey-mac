# fan-hotkey-mac

macOS 一键 [Macs Fan Control](https://crystalidea.com/macs-fan-control) 「全速 ↔ 自动」切换 + 自动回切定时器 + 屏幕中央提示。

- **全局快捷键**（默认 ⌃⌥⌘ + 8）切换风扇预设，无需打开 MFC 主窗
- **自动回切**：切到全速后 N 分钟自动回 Auto，免得跑完任务忘了关
- **屏幕中央提示**（Hammerspoon `hs.alert`），文字、时长可自定义
- **SwiftUI 配置 GUI**：Fan Hotkey.app

> Apple Silicon Mac 验证通过。Macs Fan Control 1.5.21+ 测试通过（依赖 `/minimized` 启动参数）。

## 工作原理

写 `defaults` 把 MFC 的 `ActivePreset` 切到 `Predefined:1`（Full Blast）或 `Predefined:0`（Auto），然后退出 MFC 并以 `/minimized` 参数后台重启 — 整个过程无窗口闪现。

| 组件 | 作用 |
|------|------|
| `fan-hotkey.lua` | Hammerspoon 主逻辑：快捷键、切换、自动回切定时器 |
| `Fan Hotkey.app` (SwiftUI) | 配置 GUI：所有可调项、状态检测 |
| `~/.hammerspoon/fan-hotkey-config.json` | 单一配置源，App 写入，lua 读取 |

## 安装

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
1. 拷贝 `fan-hotkey.lua` 到 `~/.hammerspoon/`
2. 在 `~/.hammerspoon/init.lua` 末尾追加 `require("fan-hotkey")`
3. 编译 `Fan Hotkey.app` 装到 `/Applications/`
4. 重载 Hammerspoon

## 使用

### 快捷键
默认 **`⌃⌥⌘ + 8`** 切换全速 / Auto（在 GUI Settings 里可改）。

### 配置 GUI（**Fan Hotkey.app**）
Spotlight 搜「Fan Hotkey」打开。三个标签：

- **Settings**：快捷键、提示文字、显示时长、自动回切倒计时
- **Status**：实时显示 MFC 是否安装、Hammerspoon 是否运行、当前预设
- **About**：仓库链接

保存后自动重载 Hammerspoon。

## 卸载

```bash
./uninstall.sh
```

## License

MIT
