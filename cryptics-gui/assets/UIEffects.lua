--!strict
-- Skill Made By : Crypticplay_RBLX - Only on Youtube
-- UIEffects (ModuleScript) — reusable animated effects for Roblox UI.
-- Effects: Glowing, Moving Shine, Sparkles, Stagnant Shine, Bubble Gloss, Ringing, Spin, Bounce.
-- Glow and Sparkles need an image: upload a white glow/sparkle PNG (e.g. from ui-resources.com Effects)
-- and set the ids before use:  FX.Images.Glow = "rbxassetid://..."  FX.Images.Sparkle = "rbxassetid://..."
-- Put in ReplicatedStorage, require from LocalScripts.
-- Every function returns a cleanup function (safe to call more than once). Effects also clean themselves
-- up when their target is :Destroy()ed, so closing/destroying a window never leaks RenderStepped loops.
-- Glow + Shine + Sparkles can be stacked on the same button: Glow draws BEHIND it as a sibling, and Shine
-- uses its own rounded CanvasGroup mask, so nothing sets ClipsDescendants on your button.

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local UIEffects = {}

UIEffects.Images = {
	Glow = "",    -- set to your uploaded soft glow image (white PNG, tinted with ImageColor3)
	Sparkle = "", -- set to your uploaded 4-point sparkle image (white PNG)
}

local function alive(inst: Instance): boolean
	return inst.Parent ~= nil
end

-- Wraps a cleanup so it runs once, either when called or when `inst` is destroyed.
local function lifetime(inst: Instance, cleanup: () -> ()): () -> ()
	local done = false
	local conn: RBXScriptConnection? = nil
	local function run()
		if done then return end
		done = true
		if conn then conn:Disconnect() end
		cleanup()
	end
	conn = inst.Destroying:Connect(run)
	return run
end

local function hasLayout(inst: Instance): boolean
	return inst:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
end

-- 1) GLOWING: pulsing glow image BEHIND a button/card.
-- With ZIndexBehavior.Sibling a child always draws above its parent, so the glow is placed as a sibling
-- (same parent, ZIndex - 1) and follows the target's position, size, scale, rotation and visibility.
-- If the parent auto-arranges children (UIGridLayout/UIListLayout), a sibling would be laid out too, so the
-- glow falls back to being a child of the target (drawn over its background — give the card a transparent
-- background with a "Face" child, or put the card in a non-layout holder frame, to keep it behind).
function UIEffects.Glow(target: GuiObject, color: Color3?, period: number?): () -> ()
	if UIEffects.Images.Glow == "" then warn("UIEffects: set UIEffects.Images.Glow first") end
	local img = Instance.new("ImageLabel")
	img.Name = "FX_Glow"
	img.BackgroundTransparency = 1
	img.Image = UIEffects.Images.Glow
	img.ImageColor3 = color or Color3.fromRGB(255, 220, 90)
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.ImageTransparency = 0.1

	local conns: { RBXScriptConnection } = {}
	local parent = target.Parent
	if parent and parent:IsA("GuiBase2d") and not hasLayout(parent) then
		local host = parent :: GuiBase2d
		img.ZIndex = target.ZIndex - 1
		local function sync()
			local hostSize = host.AbsoluteSize
			local rel = target.AbsolutePosition - host.AbsolutePosition
			if host:IsA("ScrollingFrame") then
				local sf = host :: ScrollingFrame
				rel += sf.CanvasPosition
				hostSize = sf.AbsoluteCanvasSize
			end
			if hostSize.X <= 0 or hostSize.Y <= 0 then return end
			local size = target.AbsoluteSize
			-- Scale (not Offset) units, so a UIScale on the window (open tween) can't distort the glow.
			img.Position = UDim2.fromScale((rel.X + size.X / 2) / hostSize.X, (rel.Y + size.Y / 2) / hostSize.Y)
			img.Size = UDim2.fromScale(size.X * 1.6 / hostSize.X, size.Y * 1.9 / hostSize.Y)
			img.Rotation = target.Rotation
			img.Visible = target.Visible
		end
		sync()
		table.insert(conns, target:GetPropertyChangedSignal("AbsolutePosition"):Connect(sync))
		table.insert(conns, target:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync))
		table.insert(conns, target:GetPropertyChangedSignal("Rotation"):Connect(sync))
		table.insert(conns, target:GetPropertyChangedSignal("Visible"):Connect(sync))
		table.insert(conns, host:GetPropertyChangedSignal("AbsolutePosition"):Connect(sync))
		table.insert(conns, host:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync))
		if host:IsA("ScrollingFrame") then
			table.insert(conns, host:GetPropertyChangedSignal("CanvasPosition"):Connect(sync))
		end
		table.insert(conns, target:GetPropertyChangedSignal("Parent"):Connect(function()
			if target.Parent ~= host then img:Destroy() end
		end))
		img.Parent = host
	else
		img.Position = UDim2.fromScale(0.5, 0.5)
		img.Size = UDim2.fromScale(1.6, 1.9)
		img.ZIndex = 0
		img.Parent = target
	end

	local info = TweenInfo.new(period or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tw = TweenService:Create(img, info, { ImageTransparency = 0.85 })
	tw:Play()
	return lifetime(target, function()
		for _, c in ipairs(conns) do c:Disconnect() end
		tw:Cancel()
		img:Destroy()
	end)
end

-- 2) MOVING SHINE: a white diagonal streak sweeping across.
-- The streak lives in its own CanvasGroup mask (copying the target's UICorner), so it stays inside the
-- rounded face without clipping the target's lip, outline, glow or sparkles.
-- Note: if the target itself has a UIListLayout/UIGridLayout, put the shine on an inner "Face" frame instead.
function UIEffects.Shine(parent: GuiObject, every: number?, sweep: number?): () -> ()
	local mask = Instance.new("CanvasGroup")
	mask.Name = "FX_ShineMask"
	mask.BackgroundTransparency = 1
	mask.BorderSizePixel = 0
	mask.Size = UDim2.fromScale(1, 1)
	mask.ZIndex = 20
	local corner = parent:FindFirstChildOfClass("UICorner")
	if corner then corner:Clone().Parent = mask end

	local f = Instance.new("Frame")
	f.Name = "FX_Shine"
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Size = UDim2.fromScale(0.35, 2)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(-0.4, 0.5)
	f.Rotation = 20
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.45), NumberSequenceKeypoint.new(1, 1),
	})
	g.Parent = f
	f.Parent = mask
	mask.Parent = parent

	local running = true
	local current: Tween? = nil
	task.spawn(function()
		while running and alive(f) do
			f.Position = UDim2.fromScale(-0.4, 0.5)
			local tw = TweenService:Create(f, TweenInfo.new(sweep or 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.fromScale(1.4, 0.5) })
			current = tw
			tw:Play(); tw.Completed:Wait()
			if not running then break end
			task.wait(every or 2.5)
		end
	end)
	return lifetime(parent, function()
		running = false
		if current then current:Cancel() end
		mask:Destroy()
	end)
end

-- 3) SPARKLES: twinkling + spinning stars at given scale positions (e.g. card corners).
function UIEffects.Sparkles(parent: GuiObject, points: { Vector2 }?, sizePx: number?): () -> ()
	if UIEffects.Images.Sparkle == "" then warn("UIEffects: set UIEffects.Images.Sparkle first") end
	local pts = points or { Vector2.new(0.9, 0.1), Vector2.new(0.08, 0.55), Vector2.new(0.85, 0.8) }
	local stars: { ImageLabel } = {}
	local running = true
	for i, p in ipairs(pts) do
		local s = Instance.new("ImageLabel")
		s.Name = "FX_Sparkle" .. i
		s.BackgroundTransparency = 1
		s.Image = UIEffects.Images.Sparkle
		s.AnchorPoint = Vector2.new(0.5, 0.5)
		s.Position = UDim2.fromScale(p.X, p.Y)
		local full = UDim2.fromOffset(sizePx or 26, sizePx or 26)
		s.Size = full
		s.ZIndex = 21
		s.Parent = parent
		table.insert(stars, s)
		task.spawn(function()
			task.wait((i - 1) * 0.35)
			while running and alive(s) do
				local t1 = TweenService:Create(s, TweenInfo.new(0.6, Enum.EasingStyle.Sine), { Size = UDim2.fromOffset(0, 0) })
				t1:Play(); t1.Completed:Wait()
				if not (running and alive(s)) then break end
				local t2 = TweenService:Create(s, TweenInfo.new(0.5, Enum.EasingStyle.Sine), { Size = full })
				t2:Play(); t2.Completed:Wait()
				task.wait(0.2 + math.random() * 0.6)
			end
		end)
	end
	local conn = RunService.RenderStepped:Connect(function(dt)
		for _, s in ipairs(stars) do s.Rotation = (s.Rotation + 100 * dt) % 360 end
	end)
	return lifetime(parent, function()
		running = false
		conn:Disconnect()
		for _, s in ipairs(stars) do s:Destroy() end
	end)
end

-- 4) STAGNANT SHINE: static soft highlight on the top half (glass look). No animation.
-- Uses the target's own UICorner radius when it has one (else 10px).
function UIEffects.StaticShine(parent: GuiObject, strength: number?): () -> ()
	local f = Instance.new("Frame")
	f.Name = "FX_StaticShine"
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Size = UDim2.new(1, -8, 0.45, 0)
	f.Position = UDim2.fromOffset(4, 3)
	f.ZIndex = 19
	local c = Instance.new("UICorner")
	local own = parent:FindFirstChildOfClass("UICorner")
	c.CornerRadius = if own then own.CornerRadius else UDim.new(0, 10)
	c.Parent = f
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Transparency = NumberSequence.new(1 - (strength or 0.45), 1)
	g.Parent = f
	f.Parent = parent
	return lifetime(parent, function() f:Destroy() end)
end

-- 5) BUBBLE GLOSS: rotate a UIGradient forever (glassy, liquid look). Pass an existing UIGradient.
function UIEffects.Gloss(gradient: UIGradient, cycle: number?): () -> ()
	local period = cycle or 7
	local t = 0
	local conn = RunService.RenderStepped:Connect(function(dt)
		t = (t + dt) % period
		gradient.Rotation = 180 - 360 * (t / period)
	end)
	return lifetime(gradient, function() conn:Disconnect() end)
end

-- 6) RINGING: bell-shake (great for "!" notification badges and the Shop open button).
function UIEffects.Ring(obj: GuiObject, pause: number?): () -> ()
	local running = true
	local base = obj.Rotation
	local current: Tween? = nil
	task.spawn(function()
		local offsets = { 40, -40, 25, -25, 10, -10, 5, -5, 0 }
		while running and alive(obj) do
			for _, o in ipairs(offsets) do
				if not running then break end
				local tw = TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = base + o })
				current = tw
				tw:Play(); tw.Completed:Wait()
			end
			if running then task.wait(pause or 0.7) end
		end
	end)
	return lifetime(obj, function()
		running = false
		if current then current:Cancel() end
		obj.Rotation = base
	end)
end

-- Extra: slow spin (sunburst behind featured items / reward reveals).
function UIEffects.Spin(img: GuiObject, secondsPerTurn: number?): () -> ()
	local conn = RunService.RenderStepped:Connect(function(dt)
		img.Rotation = (img.Rotation + 360 * dt / (secondsPerTurn or 14)) % 360
	end)
	return lifetime(img, function() conn:Disconnect() end)
end

-- Extra: hover/press bounce for any GuiButton.
-- Touch has no real hover, so after a tap the button returns to 1 instead of staying at the hover size.
function UIEffects.Bounce(btn: GuiButton): () -> ()
	local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = btn
	local info = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local function to(v: number) TweenService:Create(scale, info, { Scale = v }):Play() end
	local touching = false
	local c = {
		btn.InputBegan:Connect(function(input: InputObject)
			local t = input.UserInputType
			if t == Enum.UserInputType.Touch then touching = true
			elseif t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.MouseMovement then touching = false end
		end),
		btn.InputEnded:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.Touch then to(1) end
		end),
		btn.MouseEnter:Connect(function() if not touching then to(1.07) end end),
		btn.MouseLeave:Connect(function() to(1) end),
		btn.MouseButton1Down:Connect(function() to(0.93) end),
		btn.MouseButton1Up:Connect(function() to(if touching then 1 else 1.07) end),
	}
	return lifetime(btn, function() for _, x in ipairs(c) do x:Disconnect() end end)
end

return UIEffects
