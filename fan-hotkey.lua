-- ===== fan-hotkey-mac =====
-- 按用户自定义的「档位列表」循环切换 Macs Fan Control
-- https://github.com/KrisWonka/fan-hotkey-mac

local M = {}

local HS_DIR = os.getenv("HOME") .. "/.hammerspoon"
local CONFIG_PATH = HS_DIR .. "/fan-hotkey-config.json"
local READTEMP_BIN = HS_DIR .. "/readtemp"

local cfg = {
  hotkeyEnabled = true,
  hotkeyMods = { "ctrl", "alt", "cmd" },
  hotkeyKey = "8",
  alertEnabled = true,
  alertCooldownDone = "Cooldown done ✓",
  alertDuration = 1.2,
  cycleSteps = {
    { type = "auto" },
    { type = "fullBlast", autoRevertEnabled = false, autoRevertSec = 600 },
    { type = "cooldown",  cooldownTargetTemp = 40, cooldownPollSec = 3 },
  },
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
local cooldownTimer   = nil
local cycleIndex      = 0

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

local function readTemp()
  local f = io.popen(READTEMP_BIN .. " 2>/dev/null")
  if not f then return nil end
  local out = f:read("*a"); f:close()
  return tonumber((out or ""):match("[%d%.]+"))
end

local function alert(text)
  if cfg.alertEnabled then hs.alert.show(text, cfg.alertDuration) end
end

local function defaultName(t)
  if t == "auto"      then return "Auto"
  elseif t == "fullBlast" then return "Full Blast"
  elseif t == "cooldown"  then return "Cooldown"
  end
  return t or "?"
end

local function effectiveName(step)
  local n = step.name
  if type(n) == "string" then
    n = n:gsub("^%s*(.-)%s*$", "%1")  -- trim
    if #n > 0 then return n end
  end
  return defaultName(step.type)
end

local function cancelAutoRevert()
  if autoRevertTimer then autoRevertTimer:stop(); autoRevertTimer = nil end
end

local function cancelCooldown()
  if cooldownTimer then cooldownTimer:stop(); cooldownTimer = nil end
end

local function scheduleAutoRevert(step)
  cancelAutoRevert()
  if not step.autoRevertEnabled then return end
  local sec = step.autoRevertSec or 600
  autoRevertTimer = hs.timer.doAfter(sec, function()
    autoRevertTimer = nil
    applyPreset("Predefined:0")
    alert(defaultName("auto") .. " ⏱")
  end)
end

local function startCooldown(step)
  cancelCooldown()
  applyPreset("Predefined:1")
  alert(effectiveName(step))
  local target = step.cooldownTargetTemp or 40
  local poll   = step.cooldownPollSec or 3
  cooldownTimer = hs.timer.doEvery(poll, function()
    local t = readTemp()
    if t and t < target then
      cancelCooldown()
      applyPreset("Predefined:0")
      alert(cfg.alertCooldownDone)
    end
  end)
end

local function applyStep(step)
  cancelAutoRevert()
  cancelCooldown()
  local t = step and step.type
  if t == "auto" then
    applyPreset("Predefined:0")
    alert(effectiveName(step))
  elseif t == "fullBlast" then
    applyPreset("Predefined:1")
    scheduleAutoRevert(step)
    alert(effectiveName(step))
  elseif t == "cooldown" then
    startCooldown(step)
  end
end

local function cycle()
  local steps = cfg.cycleSteps or {}
  if #steps == 0 then
    alert("循环列表为空")
    return
  end
  cycleIndex = cycleIndex % #steps + 1
  applyStep(steps[cycleIndex])
end

if cfg.hotkeyEnabled and cfg.hotkeyKey and #cfg.hotkeyMods > 0 then
  hs.hotkey.bind(cfg.hotkeyMods, cfg.hotkeyKey, cycle)
end

return M
