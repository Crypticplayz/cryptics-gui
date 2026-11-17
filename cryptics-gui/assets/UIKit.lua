-- UIKit (ModuleScript) — assembles exported PNGs into a working Roblox UI, the same way every time.
-- Skill Made By : Crypticplay_RBLX - Only on Youtube
--
-- Put in ReplicatedStorage as `UIKit` (next to `UIEffects`). Require it from LocalScripts.
-- UIKit never DESIGNS anything (rule 3): every visual is one of your exported PNGs. It only places them,
-- adds TextLabels for changing text, and wires behaviour: open/close, sounds, effects, gamepad,
-- purchases, number formatting and data-driven grids.
--
--   local UI = require(game.ReplicatedStorage.UIKit)
--   local screen = UI.screen("ShopGui")
--   local win = UI.window(screen, { name = "Shop", design = Vector2.new(1120, 680), width = 0.62 })
--   local buy = UI.piece(win.Frame, { name = "Btn_Buy", rect = {840, 560, 236, 72}, image = ids.btn_green, margin = 10, button = true })
--   UI.label(buy, { text = "49", rect = {0, 0, 236, 72}, parentDesign = Vector2.new(236, 72) })
--   UI.button(buy, { onClick = function() UI.buyProduct(123456) end })
--   win:open()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local UIKit = {}

UIKit.Theme = {
	Font = Font.new("rbxasset://fonts/families/FredokaOne.json"),
	TextColor = Color3.new(1, 1, 1),
	StrokeColor = Color3.new(0, 0, 0),   -- rule 11: outlines black
	StrokeThickness = 3,                 -- at design size; scaled by UIKit.scaleStrokes
	MaxTextSize = 64,
	SelectionImage = "",                 -- optional gamepad highlight PNG (exported glow ring)
}

-- Accessibility: rarity is never colour-only. Each rarity has a colour AND a word; show the word on the
-- card/tag so a colour-blind player can still tell them apart. (No unicode symbols: they read as AI-made.)
UIKit.Rarity = {
	Common    = { color = Color3.fromRGB(184, 192, 200), label = "COMMON" },
	Uncommon  = { color = Color3.fromRGB(61, 220, 90),   label = "UNCOMMON" },
	Rare      = { color = Color3.fromRGB(63, 169, 255),  label = "RARE" },
	Epic      = { color = Color3.fromRGB(164, 92, 255),  label = "EPIC" },
	Legendary = { color = Color3.fromRGB(255, 201, 60),  label = "LEGENDARY" },
	Mythic    = { color = Color3.fromRGB(255, 77, 77),   label = "MYTHIC" },
	Secret    = { color = Color3.fromRGB(255, 255, 255), label = "SECRET" },
}

-- Player-facing settings. Defaults follow the player's Roblox accessibility settings when available.
UIKit.Settings = {
	reduceMotion = false,
}
pcall(function() UIKit.Settings.reduceMotion = (GuiService :: any).ReducedMotionEnabled == true end)

----------------------------------------------------------------------------------------------------
-- Formatting (cash pills never overflow)
----------------------------------------------------------------------------------------------------
local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

-- 999 -> "999", 1234 -> "1.23K", 12345 -> "12.3K", 1500000 -> "1.5M"
function UIKit.abbrev(n: number): string
	if n ~= n then return "0" end
	local neg = n < 0
	n = math.abs(n)
	local i = 1
	while n >= 1000 and i < #SUFFIXES do
		n /= 1000
		i += 1
	end
	local s
	if i == 1 then
		s = tostring(math.floor(n))
	elseif n < 10 then
		s = string.format("%.2f", math.floor(n * 100) / 100)
	elseif n < 100 then
		s = string.format("%.1f", math.floor(n * 10) / 10)
	else
		s = tostring(math.floor(n))
	end
	if s:find(".", 1, true) then
		s = (s:gsub("0+$", ""))
		s = (s:gsub("%.$", ""))
	end
	return (neg and "-" or "") .. s .. SUFFIXES[i]
end

-- 1234567 -> "1,234,567"
function UIKit.commas(n: number): string
	local s = tostring(math.floor(math.abs(n)))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if out:sub(1, 1) == "," then out = out:sub(2) end
	return (n < 0 and "-" or "") .. out
end

-- 59 -> "0:59", 3599 -> "59:59", 3600 -> "1:00:00", 90061 -> "1d 1h"
function UIKit.time(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	local d = seconds // 86400
	local h = (seconds % 86400) // 3600
	local m = (seconds % 3600) // 60
	local s = seconds % 60
	if d > 0 then return string.format("%dd %dh", d, h) end
	if h > 0 then return string.format("%d:%02d:%02d", h, m, s) end
	return string.format("%d:%02d", m, s)
end

----------------------------------------------------------------------------------------------------
-- Content (references/content-and-placeholders.md): the game's data from the content sheets,
-- built into ReplicatedStorage.UIContent by tools/build_content.py. Never invent values in code:
-- a missing value shows the fallback (or nothing).
----------------------------------------------------------------------------------------------------
local contentCache: any = nil
function UIKit.content(): { [string]: any }
	if contentCache == nil then
		contentCache = {}
		local m = ReplicatedStorage:FindFirstChild("UIContent")
		if m and m:IsA("ModuleScript") then
			local ok, data = pcall(require, m)
			if ok and type(data) == "table" then contentCache = data end
		end
	end
	return contentCache
end

-- A label from text.csv (e.g. UIKit.text("btn_equip_best")), or the fallback, or "".
function UIKit.text(key: string, fallback: string?): string
	local t = UIKit.content().text
	return (t and t[key]) or fallback or ""
end

-- Shop rows, optionally filtered by section (e.g. UIKit.shopItems("passes")).
function UIKit.shopItems(section: string?): { any }
	local out = {}
	for _, row in ipairs(UIKit.content().shop or {}) do
		if section == nil or row.section == section then table.insert(out, row) end
	end
	return out
end

----------------------------------------------------------------------------------------------------
-- Sounds (roblox-sfx): plays through ReplicatedStorage.Sfx if the game has one, otherwise silent.
-- Roles used by UIKit: ui_click, ui_hover, window_open, window_close, tab_switch, purchase_success,
-- purchase_fail, reward_claim, rare_hatch, notification. See references/ui-sounds.md.
----------------------------------------------------------------------------------------------------
local sfxModule: any = nil
local sfxTried = false
function UIKit.sound(role: string, parent: Instance?)
	if not sfxTried then
		sfxTried = true
		local m = ReplicatedStorage:FindFirstChild("Sfx")
		if m and m:IsA("ModuleScript") then
			local ok, mod = pcall(require, m)
			if ok then sfxModule = mod end
		end
	end
	if sfxModule and sfxModule.play then
		pcall(sfxModule.play, role, parent)
	end
end

----------------------------------------------------------------------------------------------------
-- Effects (UIEffects): optional, never required
----------------------------------------------------------------------------------------------------
local fxModule: any = nil
local function FX()
	if fxModule == nil then
		local m = ReplicatedStorage:FindFirstChild("UIEffects")
		fxModule = false
		if m and m:IsA("ModuleScript") then
			local ok, mod = pcall(require, m)
			if ok then fxModule = mod end
		end
	end
	return fxModule or nil
end

----------------------------------------------------------------------------------------------------
-- Building blocks
----------------------------------------------------------------------------------------------------
local function toScale(rect: { number }, parentDesign: Vector2)
	local x, y, w, h = rect[1], rect[2], rect[3], rect[4]
	return UDim2.fromScale(x / parentDesign.X, y / parentDesign.Y), UDim2.fromScale(w / parentDesign.X, h / parentDesign.Y)
end

local function designOf(parent: Instance): Vector2
	local d = parent:GetAttribute("DesignSize")
	if typeof(d) == "Vector2" then return d end
	error("UIKit: parent '" .. parent.Name .. "' has no DesignSize attribute; pass parentDesign")
end

-- A ScreenGui with the skill's defaults.
function UIKit.screen(name: string, opts: { [string]: any }?): ScreenGui
	opts = opts or {}
	local player = Players.LocalPlayer
	local sg = Instance.new("ScreenGui")
	sg.Name = name
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.IgnoreGuiInset = opts.ignoreInset ~= false
	pcall(function() (sg :: any).ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
	sg.DisplayOrder = opts.displayOrder or 0
	sg.Parent = opts.parent or (player and player:WaitForChild("PlayerGui"))
	return sg
end

-- One exported piece: a transparent container at its design rect (Scale), with a child `Bg` ImageLabel
-- showing the PNG, offset by -margin so the black lip / glow baked into the PNG sits where it was designed.
-- spec = { name, rect = {x, y, w, h}, image, margin = 0, slice = {l, t, r, b} | nil, sliceScale,
--          button = false, zIndex, parentDesign = Vector2 | nil }
function UIKit.piece(parent: GuiObject, spec: { [string]: any }): GuiObject
	local pd = spec.parentDesign or designOf(parent)
	local container: GuiObject
	if spec.button then
		local b = Instance.new("TextButton")
		b.Text = ""
		b.AutoButtonColor = false
		container = b
	else
		container = Instance.new("Frame")
	end
	container.Name = spec.name or "Piece"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	local pos, size = toScale(spec.rect, pd)
	container.Position, container.Size = pos, size
	container.ZIndex = spec.zIndex or 1
	container:SetAttribute("DesignSize", Vector2.new(spec.rect[3], spec.rect[4]))

	if spec.image then
		local m = spec.margin or 0
		local w, h = spec.rect[3], spec.rect[4]
		local bg = Instance.new("ImageLabel")
		bg.Name = "Bg"
		bg.BackgroundTransparency = 1
		bg.Image = spec.image
		bg.Position = UDim2.fromScale(-m / w, -m / h)
		bg.Size = UDim2.fromScale(1 + 2 * m / w, 1 + 2 * m / h)
		bg.ZIndex = container.ZIndex
		if spec.slice then
			bg.ScaleType = Enum.ScaleType.Slice
			local s = spec.slice
			bg.SliceCenter = Rect.new(s[1], s[2], s[3], s[4])
			bg.SliceScale = spec.sliceScale or 1
		end
		bg:SetAttribute("BgMargin", m)
		bg.Parent = container
	end
	container.Parent = parent
	return container
end

-- An icon PNG (ScaleType Fit). spec = { name, rect, image, rotation, parentDesign }
function UIKit.icon(parent: GuiObject, spec: { [string]: any }): ImageLabel
	local pd = spec.parentDesign or designOf(parent)
	local img = Instance.new("ImageLabel")
	img.Name = spec.name or "Icon"
	img.BackgroundTransparency = 1
	img.Image = spec.image or ""
	img.ScaleType = Enum.ScaleType.Fit
	img.Position, img.Size = toScale(spec.rect, pd)
	img.Rotation = spec.rotation or 0
	img.ZIndex = spec.zIndex or 3
	img.Parent = parent
	return img
end

-- Changing text (rule: never baked into images). spec = { name, text, rect, color, gradient = {c1, c2},
-- stroke = 3, align = "Center"|"Left"|"Right", maxSize, parentDesign }
function UIKit.label(parent: GuiObject, spec: { [string]: any }): TextLabel
	local pd = spec.parentDesign or designOf(parent)
	local t = Instance.new("TextLabel")
	t.Name = spec.name or "Lbl"
	t.BackgroundTransparency = 1
	t.FontFace = spec.font or UIKit.Theme.Font
	t.Text = spec.text or ""
	t.TextColor3 = spec.color or UIKit.Theme.TextColor
	t.TextScaled = true
	t.TextXAlignment = Enum.TextXAlignment[spec.align or "Center"]
	t.Position, t.Size = toScale(spec.rect, pd)
	t.ZIndex = spec.zIndex or 4
	local c = Instance.new("UITextSizeConstraint")
	c.MaxTextSize = spec.maxSize or UIKit.Theme.MaxTextSize
	c.MinTextSize = 8
	c.Parent = t
	local stroke = Instance.new("UIStroke")
	stroke.Color = UIKit.Theme.StrokeColor
	stroke.Thickness = spec.stroke or UIKit.Theme.StrokeThickness
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke:SetAttribute("BaseThickness", stroke.Thickness)
	stroke.Parent = t
	if spec.gradient then
		local g = Instance.new("UIGradient")
		g.Rotation = 90
		g.Color = ColorSequence.new(spec.gradient[1], spec.gradient[2])
		g.Parent = t
	end
	t.Parent = parent
	return t
end

-- Keep text outlines in proportion: every UIStroke with a BaseThickness attribute is scaled by
-- root width / design width. Returns a cleanup function.
function UIKit.scaleStrokes(root: GuiObject, designWidth: number): () -> ()
	local function apply()
		local k = root.AbsoluteSize.X / designWidth
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("UIStroke") then
				local base = d:GetAttribute("BaseThickness")
				if typeof(base) == "number" then d.Thickness = math.max(1, base * k) end
			end
		end
	end
	apply()
	local c1 = root:GetPropertyChangedSignal("AbsoluteSize"):Connect(apply)
	local c2 = root.DescendantAdded:Connect(function(d) if d:IsA("UIStroke") then task.defer(apply) end end)
	return function() c1:Disconnect(); c2:Disconnect() end
end

----------------------------------------------------------------------------------------------------
-- Buttons: Bounce + sound + gamepad + one callback
----------------------------------------------------------------------------------------------------
function UIKit.button(btn: GuiButton, opts: { [string]: any }?): () -> ()
	opts = opts or {}
	local conns = {}
	local fx = FX()
	local stopBounce = (fx and not UIKit.Settings.reduceMotion) and fx.Bounce(btn) or nil
	btn.Selectable = true
	if UIKit.Theme.SelectionImage ~= "" then
		local sel = Instance.new("ImageLabel")
		sel.Name = "SelectionImage"
		sel.BackgroundTransparency = 1
		sel.Image = UIKit.Theme.SelectionImage
		sel.Size = UDim2.fromScale(1.15, 1.25)
		sel.Position = UDim2.fromScale(-0.075, -0.125)
		btn.SelectionImageObject = sel
	end
	local busy = false
	table.insert(conns, btn.Activated:Connect(function()
		if busy then return end
		busy = true
		if opts.sound ~= false then UIKit.sound(opts.sound or "ui_click", btn) end
		if opts.onClick then
			local ok, err = pcall(opts.onClick)
			if not ok then warn("UIKit button '" .. btn.Name .. "': " .. tostring(err)) end
		end
		task.delay(opts.debounce or 0.15, function() busy = false end)
	end))
	if opts.hoverSound ~= false then
		table.insert(conns, btn.MouseEnter:Connect(function() UIKit.sound("ui_hover", btn) end))
	end
	return function()
		for _, c in ipairs(conns) do c:Disconnect() end
		if stopBounce then stopBounce() end
	end
end

-- Tabs: swap each tab's Bg between its base PNG and its selected PNG (both exported).
-- tabs = { {button = GuiButton, image = id, selectedImage = id, onSelect = fn} }
function UIKit.tabs(tabs: { { [string]: any } }, startIndex: number?)
	local current = 0
	local stopGlow: (() -> ())? = nil
	local function select(i: number)
		if i == current then return end
		current = i
		if stopGlow then stopGlow(); stopGlow = nil end
		for j, t in ipairs(tabs) do
			local bg = t.button:FindFirstChild("Bg")
			if bg then (bg :: ImageLabel).Image = (j == i) and (t.selectedImage or t.image) or t.image end
		end
		local fx = FX()
		if fx and not UIKit.Settings.reduceMotion then stopGlow = fx.Glow(tabs[i].button) end
		UIKit.sound("tab_switch", tabs[i].button)
		if tabs[i].onSelect then tabs[i].onSelect() end
	end
	for i, t in ipairs(tabs) do
		UIKit.button(t.button, { onClick = function() select(i) end, sound = "ui_click" })
	end
	select(startIndex or 1)
	return { select = select, current = function() return current end }
end

----------------------------------------------------------------------------------------------------
-- Windows: dim + open/close tween + one-open-at-a-time + gamepad focus + B/Esc to close
----------------------------------------------------------------------------------------------------
local openWindow: any = nil

-- opts = { name, design = Vector2 (incl. lip), width = 0.62 (share of screen width), dim = true, blur = true }
function UIKit.window(screen: ScreenGui, opts: { [string]: any })
	local design: Vector2 = opts.design
	local dim: Frame? = nil
	if opts.dim ~= false then
		dim = Instance.new("Frame")
		dim.Name = "Dim"
		dim.BackgroundColor3 = Color3.new(0, 0, 0)
		dim.BackgroundTransparency = 1
		dim.Size = UDim2.fromScale(1, 1)
		dim.Visible = false
		dim.ZIndex = 0
		dim.Parent = screen
	end
	local frame = Instance.new("Frame")
	frame.Name = opts.name or "Window"
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.52)
	frame.Size = UDim2.fromScale(opts.width or 0.62, 1)
	frame.Visible = false
	frame.SelectionGroup = true
	frame:SetAttribute("DesignSize", design)
	local ar = Instance.new("UIAspectRatioConstraint")
	ar.AspectRatio = design.X / design.Y
	ar.Parent = frame
	local scale = Instance.new("UIScale")
	scale.Parent = frame
	frame.Parent = screen

	local blur: BlurEffect? = nil
	local self = { Frame = frame, isOpen = false, onClose = opts.onClose }
	local stopStrokes = UIKit.scaleStrokes(frame, design.X)

	local function tween(inst: Instance, t: number, props: { [string]: any })
		local info = TweenInfo.new(UIKit.Settings.reduceMotion and 0 or t, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tw = TweenService:Create(inst, info, props)
		tw:Play()
		return tw
	end

	function self:open()
		if self.isOpen then return end
		if openWindow and openWindow ~= self then openWindow:close() end
		openWindow = self
		self.isOpen = true
		frame.Visible = true
		scale.Scale = UIKit.Settings.reduceMotion and 1 or 0.8
		tween(scale, 0.22, { Scale = 1 })
		if dim then dim.Visible = true; tween(dim, 0.15, { BackgroundTransparency = 0.45 }) end
		if opts.blur ~= false and not UIKit.Settings.reduceMotion then
			blur = Instance.new("BlurEffect")
			blur.Name = "UIKitBlur"
			blur.Size = 0
			blur.Parent = Lighting
			tween(blur :: BlurEffect, 0.2, { Size = 12 })
		end
		UIKit.sound("window_open", frame)
		-- gamepad: put focus on the first selectable button
		if GuiService:IsTenFootInterface() or opts.focusGamepad then
			for _, d in ipairs(frame:GetDescendants()) do
				if d:IsA("GuiButton") and d.Selectable and d.Visible then GuiService.SelectedObject = d; break end
			end
		end
		ContextActionService:BindAction("UIKitClose_" .. frame.Name, function(_, state)
			if state == Enum.UserInputState.Begin then self:close() end
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.ButtonB, Enum.KeyCode.Escape)
	end

	function self:close()
		if not self.isOpen then return end
		self.isOpen = false
		if openWindow == self then openWindow = nil end
		ContextActionService:UnbindAction("UIKitClose_" .. frame.Name)
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then GuiService.SelectedObject = nil end
		UIKit.sound("window_close", frame)
		local tw = TweenService:Create(scale, TweenInfo.new(UIKit.Settings.reduceMotion and 0 or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.85 })
		tw:Play()
		if dim then TweenService:Create(dim, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play() end
		if blur then
			local b = blur
			blur = nil
			TweenService:Create(b, TweenInfo.new(0.12), { Size = 0 }):Play()
			task.delay(0.15, function() b:Destroy() end)
		end
		task.delay(UIKit.Settings.reduceMotion and 0 or 0.13, function()
			if not self.isOpen then
				frame.Visible = false
				if dim then dim.Visible = false end
			end
		end)
		if self.onClose then pcall(self.onClose) end
	end

	function self:toggle() if self.isOpen then self:close() else self:open() end end

	function self:destroy()
		self:close()
		stopStrokes()
		frame:Destroy()
		if dim then dim:Destroy() end
	end

	return self
end

----------------------------------------------------------------------------------------------------
-- Data-driven grid with virtualization (hundreds of pets stay smooth)
-- scroll: a ScrollingFrame (from the design). opts = { columns = 5, aspect = 1 (cell w/h),
--   gap = 16, padding = 16 (design px at the scroll's DesignSize width), build = function(item, cell, index),
--   update = function(item, cell, index) (optional, for reused cells), designWidth }
-- Cells are created only for visible rows (+1 row buffer) and reused while scrolling.
----------------------------------------------------------------------------------------------------
function UIKit.grid(scroll: ScrollingFrame, opts: { [string]: any })
	local columns = opts.columns or 5
	local aspect = opts.aspect or 1
	local designW = opts.designWidth or (function()
		local d = scroll:GetAttribute("DesignSize")
		return typeof(d) == "Vector2" and d.X or scroll.AbsoluteSize.X
	end)()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = 0 -- the design's own scrollbar PNG sits outside the content (rule 12)
	scroll:SetAttribute("UIKitManaged", true)

	local items: { any } = {}
	local pool: { GuiObject } = {}
	local live: { [number]: GuiObject } = {}
	local layout = { cellW = 0, cellH = 0, gap = 0, pad = 0 }

	local function measure()
		local k = scroll.AbsoluteSize.X / designW
		layout.gap = (opts.gap or 16) * k
		layout.pad = (opts.padding or 16) * k
		layout.cellW = (scroll.AbsoluteSize.X - 2 * layout.pad - (columns - 1) * layout.gap) / columns
		layout.cellH = layout.cellW / aspect
		local rows = math.ceil(#items / columns)
		local h = 2 * layout.pad + rows * layout.cellH + math.max(0, rows - 1) * layout.gap
		scroll.CanvasSize = UDim2.fromOffset(0, h)
	end

	local function place(cell: GuiObject, i: number)
		local r = (i - 1) // columns
		local c = (i - 1) % columns
		cell.Position = UDim2.fromOffset(layout.pad + c * (layout.cellW + layout.gap), layout.pad + r * (layout.cellH + layout.gap))
		cell.Size = UDim2.fromOffset(layout.cellW, layout.cellH)
	end

	local function refresh()
		local rowH = layout.cellH + layout.gap
		if rowH <= 0 then return end
		local top = scroll.CanvasPosition.Y - layout.pad
		local first = math.max(0, math.floor(top / rowH) - 1)
		local last = math.floor((top + scroll.AbsoluteSize.Y) / rowH) + 1
		local want: { [number]: boolean } = {}
		for r = first, last do
			for c = 1, columns do
				local i = r * columns + c
				if i >= 1 and i <= #items then want[i] = true end
			end
		end
		for i, cell in pairs(live) do
			if not want[i] then
				cell.Visible = false
				table.insert(pool, cell)
				live[i] = nil
			end
		end
		for i in pairs(want) do
			if not live[i] then
				local cell = table.remove(pool)
				if cell then
					if opts.update then opts.update(items[i], cell, i) else
						for _, ch in ipairs(cell:GetChildren()) do ch:Destroy() end
						opts.build(items[i], cell, i)
					end
				else
					cell = Instance.new("Frame")
					cell.Name = "Cell"
					cell.BackgroundTransparency = 1
					cell:SetAttribute("UIKitManaged", true)
					cell.Parent = scroll
					opts.build(items[i], cell, i)
				end
				cell.Visible = true
				place(cell, i)
				live[i] = cell
			else
				place(live[i], i)
			end
		end
	end

	local conns = {
		scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(refresh),
		scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() measure(); refresh() end),
	}

	local api = {}
	function api.setItems(newItems: { any })
		items = newItems
		for i, cell in pairs(live) do
			cell.Visible = false
			table.insert(pool, cell)
			live[i] = nil
		end
		measure()
		refresh()
	end
	function api.refresh() measure(); refresh() end
	function api.cellFor(i: number): GuiObject? return live[i] end
	function api.destroy()
		for _, c in ipairs(conns) do c:Disconnect() end
		for _, cell in pairs(live) do cell:Destroy() end
		for _, cell in ipairs(pool) do cell:Destroy() end
	end
	api.setItems(opts.items or {})
	return api
end

----------------------------------------------------------------------------------------------------
-- Flipbook: play a sprite sheet PNG on an ImageLabel (reward bursts, hatch flashes, sparkles).
-- ParticleEmitters do not draw inside 2D UI or ViewportFrames, so UI VFX are flipbooks.
-- opts = { columns = 4, rows = 4, fps = 24, loop = false, frames = columns*rows, sheetSize = Vector2(1024,1024) }
----------------------------------------------------------------------------------------------------
function UIKit.flipbook(img: ImageLabel, opts: { [string]: any }): () -> ()
	local cols, rows = opts.columns or 4, opts.rows or 4
	local sheet: Vector2 = opts.sheetSize or Vector2.new(1024, 1024)
	local fw, fh = sheet.X / cols, sheet.Y / rows
	local frames = opts.frames or cols * rows
	img.ImageRectSize = Vector2.new(fw, fh)
	local running = true
	task.spawn(function()
		repeat
			for f = 0, frames - 1 do
				if not running or img.Parent == nil then return end
				img.ImageRectOffset = Vector2.new((f % cols) * fw, (f // cols) * fh)
				task.wait(1 / (opts.fps or 24))
			end
		until not opts.loop or not running
		if opts.hideAtEnd ~= false then img.Visible = false end
	end)
	return function() running = false end
end

----------------------------------------------------------------------------------------------------
-- Purchases (client side). The server half is assets/Purchases.server.lua — the client NEVER decides
-- what a player owns; it only asks Roblox to show the prompt or asks the server to spend currency.
----------------------------------------------------------------------------------------------------
function UIKit.buyProduct(productId: number)
	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
end

function UIKit.buyPass(passId: number)
	MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, passId)
end

-- Spend in-game currency: the server checks the price and balance. Returns ok, message.
function UIKit.buyWithCurrency(itemId: string): (boolean, string?)
	local remotes = ReplicatedStorage:WaitForChild("CrypticsShop", 10)
	local fn = remotes and remotes:FindFirstChild("BuyWithCurrency")
	if not fn then return false, "Shop server not installed" end
	local ok, res, msg = pcall((fn :: RemoteFunction).InvokeServer, fn, itemId)
	if not ok then return false, "Try again" end
	UIKit.sound(res and "purchase_success" or "purchase_fail")
	return res == true, msg
end

-- Owned state for a gamepass button: the server sets Player attribute Pass_<passId> = true.
function UIKit.watchPass(passId: number, onOwned: () -> ()): () -> ()
	local player = Players.LocalPlayer
	local key = "Pass_" .. tostring(passId)
	if player:GetAttribute(key) == true then onOwned(); return function() end end
	local c
	c = player:GetAttributeChangedSignal(key):Connect(function()
		if player:GetAttribute(key) == true then c:Disconnect(); UIKit.sound("purchase_success"); onOwned() end
	end)
	return function() c:Disconnect() end
end

return UIKit
