#!/usr/bin/env bash
# 把 fan-hotkey.lua 装到 ~/.hammerspoon 并在 init.lua 里 require
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

HS_DIR="$HOME/.hammerspoon"
INIT_LUA="$HS_DIR/init.lua"

mkdir -p "$HS_DIR"

# ---- 依赖：Macs Fan Control（fan-hotkey 的核心依赖）----
if [ ! -d "/Applications/Macs Fan Control.app" ]; then
  if command -v brew >/dev/null 2>&1; then
    echo "→ 未检测到 Macs Fan Control，用 brew 自动安装…"
    brew install --cask macs-fan-control
  else
    echo "✗ 未检测到 Macs Fan Control，也没有 brew。" >&2
    echo "  请先装 Homebrew，再 brew install --cask macs-fan-control，" >&2
    echo "  或手动从 https://crystalidea.com/macs-fan-control 下载安装。" >&2
    exit 1
  fi
fi

# ---- 依赖：Hammerspoon ----
if [ ! -d "/Applications/Hammerspoon.app" ]; then
  echo "✗ 未检测到 Hammerspoon。请先 brew install --cask hammerspoon。" >&2
  exit 1
fi

echo "→ 复制 fan-hotkey.lua"
cp fan-hotkey.lua "$HS_DIR/fan-hotkey.lua"

# ---- 编译 readtemp（Apple Silicon 温度读取，cooldown 模式依赖）----
if ! command -v swiftc >/dev/null 2>&1; then
  echo "✗ 未检测到 swiftc。请装 Xcode Command Line Tools：xcode-select --install" >&2
  exit 1
fi
echo "→ 编译 readtemp"
swiftc readtemp.swift -framework IOKit -O -o "$HS_DIR/readtemp"

# 在 init.lua 里加 require（如果还没加）
if [ -f "$INIT_LUA" ] && grep -q 'require("fan-hotkey")' "$INIT_LUA"; then
  echo "→ init.lua 里已经有 require(\"fan-hotkey\")，跳过"
else
  echo "→ 在 $INIT_LUA 末尾追加 require(\"fan-hotkey\")"
  {
    echo ""
    echo "-- fan-hotkey-mac (https://github.com/KrisWonka/fan-hotkey-mac)"
    echo 'require("fan-hotkey")'
  } >> "$INIT_LUA"
fi

echo "→ 重载 Hammerspoon"
osascript -e 'quit app "Hammerspoon"' >/dev/null 2>&1 || true
sleep 1
open -ga Hammerspoon

echo ""
echo "→ 编译并安装 GUI"
bash app/build-app.sh

echo ""
echo "✅ 装好了。默认快捷键 ⌃⌥⌘8 切换 Macs Fan Control 全速 / Auto。"
echo "   打开 Spotlight 搜「Fan Hotkey」改设置。"
