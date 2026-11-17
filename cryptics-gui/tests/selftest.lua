-- Cryptic's GUI self-test — run in Roblox Studio (edit mode) with execute_luau.
-- Skill Made By : Crypticplay_RBLX - Only on Youtube
--
-- Before running: install assets/UIKit.lua as ReplicatedStorage.UIKit and assets/AuditUI.lua as
-- ServerStorage.CrypticsAudit (ModuleScripts, Source = file). The test builds throwaway UIs under
-- StarterGui, checks them, deletes them, and returns PASS/FAIL lines. It also writes the result to
-- ServerStorage.__CrypticsTest (StringValue) — if execute_luau returns empty output because the script
-- yielded, read that value with a second call.
--
-- What it proves:
--   1. UIKit formatting gives the right strings.
--   2. AuditUI CATCHES each defect on a deliberately broken UI (a check that can't fail is no check).
--   3. A clean UI built the skill's way has 0 errors.

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

local UI = require(RS:WaitForChild("UIKit"))
local Audit = require(SS:WaitForChild("CrypticsAudit"))

local results = {}
local failed = 0
local function check(name: string, ok: boolean, detail: string?)
	if not ok then failed += 1 end
	table.insert(results, (ok and "PASS " or "FAIL ") .. name .. (detail and ("  [" .. detail .. "]") or ""))
end

-- 1) formatting ----------------------------------------------------------------------------------
local fmt = {
	{ UI.abbrev(999), "999" }, { UI.abbrev(1000), "1K" }, { UI.abbrev(1234), "1.23K" }, { UI.abbrev(12345), "12.3K" },
	{ UI.abbrev(123456), "123K" }, { UI.abbrev(1500000), "1.5M" }, { UI.abbrev(-2500), "-2.5K" }, { UI.abbrev(2e9), "2B" },
	{ UI.commas(1234567), "1,234,567" }, { UI.commas(999), "999" }, { UI.commas(-1000), "-1,000" },
	{ UI.time(59), "0:59" }, { UI.time(3599), "59:59" }, { UI.time(3600), "1:00:00" }, { UI.time(90061), "1d 1h" },
}
for _, c in ipairs(fmt) do check("format " .. c[2], c[1] == c[2], "got " .. tostring(c[1])) end

-- helpers -------------------------------------------------------------------------------------------
local function newScreen(name: string): ScreenGui
	local old = StarterGui:FindFirstChild(name)
	if old then old:Destroy() end
	local sg = Instance.new("ScreenGui")
	sg.Name = name
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = StarterGui
	return sg
end

local function rulesFound(findings): { [string]: number }
	local seen = {}
	for _, f in ipairs(findings) do
		local key = f.severity .. ":" .. f.rule
		seen[key] = (seen[key] or 0) + 1
	end
	return seen
end

-- 2) broken UI: every defect must be caught ------------------------------------------------------
local bad = newScreen("__AuditBad")
local win = Instance.new("Frame")              -- no UIAspectRatioConstraint, draws its own background
win.Name = "Window"
win.Size = UDim2.fromScale(0.5, 0.5)
win.Position = UDim2.fromScale(0.25, 0.25)
win.BackgroundColor3 = Color3.new(1, 1, 1)
win.ClipsDescendants = true
win.Parent = bad
local stroke = Instance.new("UIStroke")         -- rule 3: native outline
stroke.Parent = win
local tiny = Instance.new("TextButton")         -- offset size + too small to tap
tiny.Name = "Btn_Tiny"
tiny.Size = UDim2.fromOffset(20, 20)
tiny.Position = UDim2.fromScale(0.4, 0.4)
tiny.BackgroundTransparency = 1
tiny.Text = ""
tiny.Parent = win
local txt = Instance.new("TextLabel")           -- text does not fit
txt.Name = "Lbl_Long"
txt.Size = UDim2.fromScale(0.1, 0.05)
txt.Position = UDim2.fromScale(0.3, 0.1)
txt.BackgroundTransparency = 1
txt.TextScaled = false
txt.TextSize = 40
txt.TextWrapped = true
txt.Text = "The Ultimate Executioner of the Northern Realms"
txt.Parent = win
local empty = Instance.new("ImageLabel")        -- PNG never set
empty.Name = "Card"
empty.Size = UDim2.fromScale(0.2, 0.2)
empty.Position = UDim2.fromScale(0.05, 0.6)
empty.BackgroundTransparency = 1
empty.Parent = win
local poke = Instance.new("ImageLabel")         -- cut off by the clipping window
poke.Name = "Card2"
poke.Image = "rbxassetid://1"
poke.Size = UDim2.fromScale(0.3, 0.3)
poke.Position = UDim2.fromScale(0.85, 0.3)
poke.BackgroundTransparency = 1
poke.Parent = win
local off = Instance.new("ImageLabel")          -- off screen
off.Name = "Lost"
off.Image = "rbxassetid://1"
off.Size = UDim2.fromScale(0.1, 0.1)
off.Position = UDim2.fromScale(3, 3)
off.BackgroundTransparency = 1
off.Parent = bad
local offAr = Instance.new("UIAspectRatioConstraint")
offAr.Parent = off

task.wait()
task.wait()
local badFindings = Audit.run(bad)
local seen = rulesFound(badFindings)
check("audit catches missing aspect ratio", (seen["ERROR:quality-bar"] or 0) > 0)
check("audit catches native UIStroke (rule 3)", (seen["WARN:rule-3"] or 0) >= 2, "UIStroke + Frame background")
check("audit catches tiny tap target", (function()
	for _, f in ipairs(badFindings) do if f.path:find("Btn_Tiny") and f.message:find("tap") then return true end end
	return false
end)())
check("audit catches Offset size", (function()
	for _, f in ipairs(badFindings) do if f.path:find("Btn_Tiny") and f.message:find("Offset") then return true end end
	return false
end)())
check("audit catches text that doesn't fit", (seen["ERROR:rule-15"] or 0) > 0)
check("audit catches empty image", (seen["ERROR:import"] or 0) > 0)
check("audit catches clipped child", (seen["ERROR:rule-12"] or 0) > 0)
check("audit catches off-screen element", (function()
	for _, f in ipairs(badFindings) do if f.message:find("off screen") then return true end end
	return false
end)())
bad:Destroy()

-- 3) clean UI built with UIKit: 0 errors ----------------------------------------------------------
local good = newScreen("__AuditGood")
local w = UI.window(good, { name = "Shop", design = Vector2.new(1120, 680), width = 0.62, blur = false })
w.Frame.Visible = true
local body = UI.piece(w.Frame, { name = "Body", rect = { 0, 120, 1120, 560 }, image = "rbxassetid://1", margin = 10 })
local buy = UI.piece(body, { name = "Btn_Buy", rect = { 800, 400, 280, 136 }, image = "rbxassetid://1", margin = 10, button = true })
UI.label(buy, { name = "Lbl_Price", text = "49", rect = { 24, 20, 232, 96 } })
UI.icon(body, { name = "Icon_Hero", rect = { 40, 40, 200, 200 }, image = "rbxassetid://1" })
task.wait()
task.wait()
local goodFindings = Audit.run(good)
local errors = {}
for _, f in ipairs(goodFindings) do if f.severity == "ERROR" then table.insert(errors, f.path .. ": " .. f.message) end end
check("clean UIKit window has 0 audit errors", #errors == 0, #errors > 0 and table.concat(errors, " | ") or nil)
w:destroy()
good:Destroy()

-- 4) grid virtualization ---------------------------------------------------------------------------
local gsg = newScreen("__GridTest")
local holder = Instance.new("Frame")
holder.Size = UDim2.fromScale(0.5, 0.6)
holder.BackgroundTransparency = 1
holder.Parent = gsg
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.fromScale(1, 1)
scroll.BackgroundTransparency = 1
scroll.Parent = holder
task.wait()
local items = {}
for i = 1, 500 do items[i] = { id = i } end
local built = 0
local grid = UI.grid(scroll, { columns = 5, gap = 16, padding = 16, designWidth = 1000,
	build = function(item, cell) built += 1; cell.Name = "Cell" .. item.id end, items = items })
local liveCount = 0
for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") and c.Visible then liveCount += 1 end end
check("grid builds only visible rows (500 items)", liveCount > 0 and liveCount < 100, "live cells " .. liveCount)
check("grid canvas fits all 500 items", scroll.CanvasSize.Y.Offset > scroll.AbsoluteSize.Y * 10)
grid.destroy()
gsg:Destroy()

local summary = string.format("Cryptic's GUI self-test: %d passed, %d failed", #results - failed, failed)
table.insert(results, 1, summary)
local out = table.concat(results, "\n")
local sv = SS:FindFirstChild("__CrypticsTest") or Instance.new("StringValue")
sv.Name = "__CrypticsTest"
local svv = sv :: StringValue
svv.Value = out
sv.Parent = SS
return out
