-- ===== fan-hotkey-mac =====
-- 一键 Macs Fan Control「全速 ↔ 自动」+ 自动回切
-- https://github.com/KrisWonka/fan-hotkey-mac

local M = {}

local HS_DIR = os.getenv("HOME") .. "/.hammerspoon"
local CONFIG_PATH = HS_DIR .. "/fan-hotkey-config.json"

-- 默认配置（被 fan-hotkey-config.json 覆盖；JSON 是 FanHotkey.app 写的）
local cfg = {
  hotkeyEnabled = true,
  hotkeyMods = { "ctrl", "alt", "cmd" },
  hotkeyKey = "8",
  alertEnabled = true,
  alertAuto = "Fan: Auto",
  alertFullBlast = "Fan: Full Blast",
  alertDuration = 1.2,
  autoRevertEnabled = false,
  autoRevertSec = 600,
}

local function loadConfig()
  local f = io.open(CONFIG_PATH, "r")
  if not f then return end
  local raw = f:read("*a"); f:close()
  local ok, parsed = pcall(hs.json.decode, raw)
  if not ok or type(parsed) ~= "table" then return end
  for k, v in pairs(parsed) do cfg[k] = v end
end
loadConfig()

local autoRevertTimer = nil

local function readActivePreset()
  local out = hs.execute("/usr/bin/defaults read com.crystalidea.macsfancontrol ActivePreset 2>/dev/null") or ""
  return out:gsub("%s+", "")
end

local function isFullBlast()
  return readActivePreset() == "Predefined:1"
end

local function applyPreset(preset)
  hs.execute(string.format([[
    osascript -e 'quit app "Macs Fan Control"' >/dev/null 2>&1
    for i in $(seq 1 25); do
      pgrep -f "Macs Fan Control.app/Contents/MacOS" >/dev/null || break
      sleep 0.1
    done
    /usr/bin/defaults write com.crystalidea.macsfancontrol ActivePreset -string %q
    /usr/bin/open -gja "Macs Fan Control" --args /minimized
  ]], preset))
end

local function cancelAutoRevert()
  if autoRevertTimer then autoRevertTimer:stop(); autoRevertTimer = nil end
end

local function scheduleAutoRevert()
  cancelAutoRevert()
  if not cfg.autoRevertEnabled then return end
  autoRevertTimer = hs.timer.doAfter(cfg.autoRevertSec, function()
    autoRevertTimer = nil
    if isFullBlast() then
      applyPreset("Predefined:0")
      if cfg.alertEnabled then
        hs.alert.show(cfg.alertAuto .. " ⏱", cfg.alertDuration)
      end
    end
  end)
end

local function toggleFan()
  if isFullBlast() then
    applyPreset("Predefined:0")
    cancelAutoRevert()
    if cfg.alertEnabled then
      hs.alert.show(cfg.alertAuto, cfg.alertDuration)
    end
  else
    applyPreset("Predefined:1")
    scheduleAutoRevert()
    if cfg.alertEnabled then
      hs.alert.show(cfg.alertFullBlast, cfg.alertDuration)
    end
  end
end

if cfg.hotkeyEnabled and cfg.hotkeyKey and #cfg.hotkeyMods > 0 then
  hs.hotkey.bind(cfg.hotkeyMods, cfg.hotkeyKey, toggleFan)
end

return M
