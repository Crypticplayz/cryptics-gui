-- AuditUI (ModuleScript) — checks an assembled Roblox UI against the Cryptic's GUI rules.
-- Skill Made By : Crypticplay_RBLX - Only on Youtube
--
-- Install (Studio MCP execute_luau, edit mode): create ServerStorage.CrypticsAudit (ModuleScript) with this
-- file as its Source, then:
--     local Audit = require(game.ServerStorage.CrypticsAudit)
--     return Audit.report(game.StarterGui)              -- or one ScreenGui
-- Or from a plugin/command bar: print(Audit.report(game.StarterGui))
--
-- Every finding has a severity (ERROR = breaks a rule, WARN = probably wrong, INFO = check by eye), the
-- instance path and the rule it breaks. Phone numbers are ESTIMATES scaled to an 844x390 phone from the
-- current viewport; confirm in the Device Emulator. Mark intentional exceptions on the instance:
--     Attribute AllowOverlap = true    (badges, overflowing icons, close X — skips overlap/clip/edge checks)
--     Attribute AuditIgnore = true     (skip this instance and its descendants)
--     Attribute UIKitManaged = true    (laid out by UIKit at runtime, e.g. virtualized grid cells)

local AuditUI = {}

AuditUI.Options = {
	phone = Vector2.new(844, 390),   -- landscape phone to estimate against
	minTapPhonePx = 44,              -- tap targets: >= 44 px tall on the phone (Apple/Google touch guidance)
	minTextPhonePx = 14,             -- readable text: >= 14 px on the phone
	minEdgeGapDesignPx = 16,         -- rule 13c: children keep >= 16 px from their parent's edge (at 1080p)
	maxImageMarginScale = 0.6,       -- Bg images may extend this far outside their container (lip/glow margin)
}

local OVERLAP_NAMES = { "badge", "tag", "close", "icon", "fx_", "glow", "spark", "decor", "shine", "dim", "bg", "lip", "check" }

local function lower(s: string): string return string.lower(s) end

local function nameAllowsOverlap(inst: Instance): boolean
	if inst:GetAttribute("AllowOverlap") == true then return true end
	local n = lower(inst.Name)
	for _, k in ipairs(OVERLAP_NAMES) do
		if string.find(n, k, 1, true) then return true end
	end
	return false
end

local function ignored(inst: Instance): boolean
	local cur: Instance? = inst
	while cur do
		if cur:GetAttribute("AuditIgnore") == true then return true end
		cur = cur.Parent
	end
	return false
end

local function managed(inst: Instance): boolean
	local cur: Instance? = inst
	while cur and not cur:IsA("LayerCollector") do
		if cur:GetAttribute("UIKitManaged") == true then return true end
		cur = cur.Parent
	end
	return false
end

local function underLayout(inst: Instance): boolean
	local p = inst.Parent
	return p ~= nil and p:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
end

local function shortPath(inst: Instance): string
	local parts = {}
	local cur: Instance? = inst
	while cur and cur ~= game do
		table.insert(parts, 1, cur.Name)
		if cur:IsA("LayerCollector") then break end
		cur = cur.Parent
	end
	return table.concat(parts, ".")
end

local function visible(g: GuiObject): boolean
	local cur: Instance? = g
	while cur and not cur:IsA("LayerCollector") do
		if cur:IsA("GuiObject") and not (cur :: GuiObject).Visible then return false end
		cur = cur.Parent
	end
	if cur and cur:IsA("ScreenGui") and not (cur :: ScreenGui).Enabled then return false end
	return true
end

local function rect(g: GuiBase2d)
	local p, s = g.AbsolutePosition, g.AbsoluteSize
	return p.X, p.Y, p.X + s.X, p.Y + s.Y
end

local function intersects(a: GuiBase2d, b: GuiBase2d): boolean
	local ax0, ay0, ax1, ay1 = rect(a)
	local bx0, by0, bx1, by1 = rect(b)
	local ix = math.min(ax1, bx1) - math.max(ax0, bx0)
	local iy = math.min(ay1, by1) - math.max(ay0, by0)
	return ix > 2 and iy > 2
end

local function isText(g: Instance): boolean
	return g:IsA("TextLabel") or g:IsA("TextButton") or g:IsA("TextBox")
end

-- Is this element drawing a solid native background (rule 3: looks come from PNGs)?
local function drawsNativeBackground(g: GuiObject): boolean
	if g.BackgroundTransparency >= 0.99 then return false end
	local n = lower(g.Name)
	if string.find(n, "dim", 1, true) or string.find(n, "fx_", 1, true) or string.find(n, "shine", 1, true) then return false end
	if g:IsA("ScrollingFrame") then return false end
	return true
end

function AuditUI.run(root: Instance, opts: { [string]: any }?)
	local o = table.clone(AuditUI.Options)
	if opts then for k, v in pairs(opts) do o[k] = v end end

	local findings = {}
	local function add(sev: string, inst: Instance, rule: string, msg: string)
		table.insert(findings, { severity = sev, path = shortPath(inst), rule = rule, message = msg })
	end

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
	local phoneF = math.min(o.phone.X / vp.X, o.phone.Y / vp.Y)
	local designF = 1080 / vp.Y

	local guis = {}
	if root:IsA("LayerCollector") then table.insert(guis, root) end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("ScreenGui") then table.insert(guis, d) end
	end
	if #guis == 0 then
		add("INFO", root, "-", "No ScreenGui found under this root.")
	end

	for _, sg in ipairs(guis) do
		if ignored(sg) then continue end
		if sg:IsA("ScreenGui") then
			local s = sg :: ScreenGui
			if s.ResetOnSpawn then add("WARN", s, "studio-build", "ResetOnSpawn is true: the UI rebuilds (and loses state) every respawn.") end
			if s.ZIndexBehavior ~= Enum.ZIndexBehavior.Sibling then add("WARN", s, "studio-build", "ZIndexBehavior should be Sibling.") end
		end
		local screenX0, screenY0, screenX1, screenY1 = rect(sg)

		-- top-level windows need an aspect ratio so they keep their shape on every device
		for _, child in ipairs(sg:GetChildren()) do
			if child:IsA("GuiObject") and not ignored(child) then
				local full = child.Size.X.Scale >= 0.99 and child.Size.Y.Scale >= 0.99
				if not full and not child:FindFirstChildOfClass("UIAspectRatioConstraint") then
					add("ERROR", child, "quality-bar", "Top-level element has no UIAspectRatioConstraint: it stretches on other screen shapes.")
				end
			end
		end

		for _, d in ipairs(sg:GetDescendants()) do
			if ignored(d) then continue end

			-- rule 3: no native styling for looks
			if d:IsA("UIStroke") and d.Parent and not isText(d.Parent) then
				add("WARN", d, "rule-3", "UIStroke on a non-text object: outlines must be baked into the exported PNG.")
			elseif d:IsA("UIGradient") and d.Parent and d.Parent:IsA("GuiObject") and not isText(d.Parent)
				and not d.Parent:IsA("ImageLabel") and not d.Parent:IsA("ImageButton")
				and drawsNativeBackground(d.Parent :: GuiObject) then
				add("WARN", d, "rule-3", "UIGradient colouring a Frame: gradients belong in the PNG (Gloss on an image overlay is fine).")
			end

			if not d:IsA("GuiObject") then continue end
			local g = d :: GuiObject
			if not visible(g) or managed(g) then continue end
			local parent = g.Parent

			-- rule 3: solid native backgrounds on containers
			if not isText(g) and not g:IsA("ImageLabel") and not g:IsA("ImageButton") and drawsNativeBackground(g) then
				add("WARN", g, "rule-3", "Frame draws its own background: containers stay transparent, the look comes from a Bg image.")
			end

			-- scale, not offset (Bg images use a negative offset margin on purpose; layouts own their children)
			local isBg = lower(g.Name) == "bg" or string.sub(lower(g.Name), 1, 3) == "bg_"
			if not isBg and not underLayout(g) and parent and not parent:IsA("ScrollingFrame") then
				if g.Size.X.Offset ~= 0 or g.Size.Y.Offset ~= 0 then
					add("ERROR", g, "quality-bar", string.format("Size uses Offset (%d, %d): use Scale so it fits every screen.", g.Size.X.Offset, g.Size.Y.Offset))
				end
				if g.Position.X.Offset ~= 0 or g.Position.Y.Offset ~= 0 then
					add("WARN", g, "quality-bar", "Position uses Offset: use Scale.")
				end
			end

			-- images
			if g:IsA("ImageLabel") or g:IsA("ImageButton") then
				local img = (g :: any).Image :: string
				if img == "" and g.BackgroundTransparency >= 0.99 and #g:GetChildren() == 0 then
					add("ERROR", g, "import", "Image is empty: the PNG was never set (upload it and paste the id).")
				end
				local st = (g :: any).ScaleType
				if st == Enum.ScaleType.Slice then
					local sc = (g :: any).SliceCenter :: Rect
					if sc.Width == 0 and sc.Height == 0 then
						add("WARN", g, "export", "ScaleType Slice with an empty SliceCenter: set the slice margins from the export notes.")
					end
				end
			end

			-- text
			if isText(g) then
				local t = g :: any
				if t.Text ~= "" then
					if t.TextFits == false then
						add("ERROR", g, "rule-15", "Text does not fit its box (TextFits = false): shrink it or widen the box.")
					end
					local px = (t.TextScaled and t.TextBounds.Y or t.TextSize) * phoneF
					if px > 0 and px < o.minTextPhonePx then
						add("WARN", g, "quality-bar", string.format("Text is ~%.0f px on a phone (min %d).", px, o.minTextPhonePx))
					end
					if t.TextScaled and not g:FindFirstChildOfClass("UITextSizeConstraint") then
						add("INFO", g, "studio-build", "TextScaled without a UITextSizeConstraint: text can balloon on big screens.")
					end
					if t.TextStrokeTransparency < 1 then
						add("INFO", g, "style", "Uses TextStroke: the skill's text outline is a UIStroke (black, BaseThickness attribute) so it scales.")
					end
				end
			end

			-- tap targets
			if g:IsA("GuiButton") then
				local h = g.AbsoluteSize.Y * phoneF
				if h > 0 and h < o.minTapPhonePx and not nameAllowsOverlap(g) then
					add("ERROR", g, "quality-bar", string.format("Button is ~%.0f px tall on a phone (min %d): too small to tap.", h, o.minTapPhonePx))
				end
				-- mobile thumb zones: joystick bottom-left, jump bottom-right
				local x0, y0, x1, y1 = rect(g)
				local w, hgt = screenX1 - screenX0, screenY1 - screenY0
				if w > 0 and hgt > 0 then
					local cx, cy = ((x0 + x1) / 2 - screenX0) / w, ((y0 + y1) / 2 - screenY0) / hgt
					if cy > 0.6 and (cx < 0.25 or cx > 0.75) and sg:IsA("ScreenGui") and not lower(sg.Name):find("window") then
						add("WARN", g, "planning", "Button sits in a mobile thumb zone (joystick bottom-left / jump bottom-right).")
					end
					if cx < 0.07 and cy < 0.12 and sg:IsA("ScreenGui") and (sg :: ScreenGui).IgnoreGuiInset then
						add("WARN", g, "planning", "Button is under Roblox's top-left menu buttons: use ScreenInsets CoreUISafeInsets.")
					end
				end
				-- close X top-right
				local n = lower(g.Name)
				if (n == "close" or n == "btn_close" or n == "x" or n == "closebutton") and parent and parent:IsA("GuiObject") then
					local px0, py0, px1, py1 = rect(parent :: GuiObject)
					local cx = (x0 + x1) / 2
					local cy = (y0 + y1) / 2
					if cx < (px0 + px1) / 2 or cy > (py0 + py1) / 2 then
						add("WARN", g, "quality-bar", "Close button is not top-right.")
					end
				end
			end

			-- off screen
			do
				local x0, y0, x1, y1 = rect(g)
				if x1 > x0 and (x1 < screenX0 or y1 < screenY0 or x0 > screenX1 or y0 > screenY1) then
					add("ERROR", g, "quality-bar", "Completely off screen.")
				elseif not isBg and (x0 < screenX0 - 2 or y0 < screenY0 - 2 or x1 > screenX1 + 2 or y1 > screenY1 + 2) and not nameAllowsOverlap(g) then
					add("WARN", g, "quality-bar", "Partly off screen at this viewport.")
				end
			end

			-- clipping and edge gaps against the parent
			if parent and parent:IsA("GuiObject") and not isBg and not nameAllowsOverlap(g) then
				local p = parent :: GuiObject
				local x0, y0, x1, y1 = rect(g)
				local px0, py0, px1, py1 = rect(p)
				local outside = x0 < px0 - 1 or y0 < py0 - 1 or x1 > px1 + 1 or y1 > py1 + 1
				local clipper = p.ClipsDescendants or p:IsA("ScrollingFrame") or p:IsA("CanvasGroup")
				if outside and clipper and not p:IsA("ScrollingFrame") then
					add("ERROR", g, "rule-12", "Cut off: it pokes outside a parent that clips (needs ~20 px inner padding).")
				elseif not outside and not p:IsA("ScrollingFrame") and not underLayout(g) then
					local gap = math.min(x0 - px0, y0 - py0, px1 - x1, py1 - y1) * designF
					local fillsParent = g.Size.X.Scale >= 0.99 and g.Size.Y.Scale >= 0.99
					if not fillsParent and gap >= 0 and gap < o.minEdgeGapDesignPx and (p:IsA("ImageLabel") or p:IsA("ImageButton") or p:FindFirstChild("Bg")) then
						add("WARN", g, "rule-13c", string.format("Only ~%.0f px from its parent's edge (min %d at 1080p).", gap, o.minEdgeGapDesignPx))
					end
				end
			end

			-- accidental overlap between siblings
			if parent and not underLayout(g) and not nameAllowsOverlap(g) and not isBg then
				for _, sib in ipairs(parent:GetChildren()) do
					if sib ~= g and sib:IsA("GuiObject") and (sib :: GuiObject).Visible and not nameAllowsOverlap(sib)
						and lower(sib.Name) ~= "bg" and sib:GetAttribute("AuditIgnore") ~= true then
						-- report each pair once
						if g:GetFullName() < sib:GetFullName() and intersects(g, sib :: GuiObject) then
							add("WARN", g, "rule-13", "Overlaps sibling '" .. sib.Name .. "' (set AllowOverlap if it is meant to).")
						end
					end
				end
			end
		end
	end

	local order = { ERROR = 1, WARN = 2, INFO = 3 }
	table.sort(findings, function(a, b)
		if order[a.severity] ~= order[b.severity] then return order[a.severity] < order[b.severity] end
		return a.path < b.path
	end)
	return findings, { viewport = vp, phoneFactor = phoneF }
end

function AuditUI.report(root: Instance, opts: { [string]: any }?): string
	local findings, meta = AuditUI.run(root, opts)
	local counts = { ERROR = 0, WARN = 0, INFO = 0 }
	local lines = {}
	for _, f in ipairs(findings) do
		counts[f.severity] += 1
		table.insert(lines, string.format("%-5s %-12s %s — %s", f.severity, f.rule, f.path, f.message))
	end
	table.insert(lines, 1, string.format("Cryptic's GUI audit: %d error(s), %d warning(s), %d note(s)  [viewport %dx%d, phone x%.2f]",
		counts.ERROR, counts.WARN, counts.INFO, meta.viewport.X, meta.viewport.Y, meta.phoneFactor))
	if #findings == 0 then table.insert(lines, "PASS — nothing found. Still check it once in the Device Emulator.") end
	return table.concat(lines, "\n")
end

return AuditUI
