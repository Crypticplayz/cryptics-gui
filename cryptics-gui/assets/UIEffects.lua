--!strict
-- Skill Made By : Crypticplay_RBLX - Only on Youtube
-- UIEffects (ModuleScript) — reusable animated effects for Roblox UI.
-- Effects: Glowing, Moving Shine, Sparkles, Stagnant Shine, Bubble Gloss, Ringing, Spin, Bounce.
-- Glow and Sparkles need an image: upload a white glow/sparkle PNG (e.g. from ui-resources.com Effects)
-- and set the ids before use:  FX.Images.Glow = "rbxassetid://..."  FX.Images.Sparkle = "rbxassetid://..."
-- Put in ReplicatedStorage, require from LocalScripts. Every function returns a cleanup function.

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

-- 1) GLOWING: pulsing glow image behind a button/card. Parent = the button.
function UIEffects.Glow(parent: GuiObject, color: Color3?, period: number?): () -> ()
	if UIEffects.Images.Glow == "" then warn("UIEffects: set UIEffects.Images.Glow first") end
	local img = Instance.new("ImageLabel")
	img.Name = "FX_Glow"
	img.BackgroundTransparency = 1
	img.Image = UIEffects.Images.Glow
	img.ImageColor3 = color or Color3.fromRGB(255, 220, 90)
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.Size = UDim2.fromScale(1.6, 1.9)
	img.ZIndex = parent.ZIndex - 1
	img.Parent = parent
	local info = TweenInfo.new(period or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tw = TweenService:Create(img, info, { ImageTransparency = 0.85 })
	img.ImageTransparency = 0.1
	tw:Play()
	return function() tw:Cancel(); img:Destroy() end
end

-- 2) MOVING SHINE: a white diagonal streak sweeping across. Parent must have ClipsDescendants = true.
function UIEffects.Shine(parent: GuiObject, every: number?, sweep: number?): () -> ()
	parent.ClipsDescendants = true
	local f = Instance.new("Frame")
	f.Name = "FX_Shine"
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Size = UDim2.fromScale(0.35, 2)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Rotation = 20
	f.ZIndex = parent.ZIndex + 5
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.45), NumberSequenceKeypoint.new(1, 1),
	})
	g.Parent = f
	f.Parent = parent
	local running = true
	task.spawn(function()
		while running and alive(f) do
			f.Position = UDim2.fromScale(-0.4, 0.5)
			local tw = TweenService:Create(f, TweenInfo.new(sweep or 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.fromScale(1.4, 0.5) })
			tw:Play(); tw.Completed:Wait()
			task.wait(every or 2.5)
		end
	end)
	return function() running = false; f:Destroy() end
end

-- 3) SPARKLES: twinkling + spinning stars at given scale positions (e.g. card corners).
function UIEffects.Sparkles(parent: GuiObject, points: { Vector2 }?, sizePx: number?): () -> ()
	if UIEffects.Images.Sparkle == "" then warn("UIEffects: set UIEffects.Images.Sparkle first") end
	local pts = points or { Vector2.new(0.9, 0.1), Vector2.new(0.08, 0.55), Vector2.new(0.85, 0.8) }
	local stars = {}
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
		s.ZIndex = parent.ZIndex + 6
		s.Parent = parent
		table.insert(stars, s)
		task.spawn(function()
			task.wait((i - 1) * 0.35)
			while running and alive(s) do
				local t1 = TweenService:Create(s, TweenInfo.new(0.6, Enum.EasingStyle.Sine), { Size = UDim2.fromOffset(0, 0) })
				t1:Play(); t1.Completed:Wait()
				local t2 = TweenService:Create(s, TweenInfo.new(0.5, Enum.EasingStyle.Sine), { Size = full })
				t2:Play(); t2.Completed:Wait()
				task.wait(0.2 + math.random() * 0.6)
			end
		end)
	end
	local conn = RunService.RenderStepped:Connect(function(dt)
		for _, s in ipairs(stars) do s.Rotation = (s.Rotation + 100 * dt) % 360 end
	end)
	return function() running = false; conn:Disconnect(); for _, s in ipairs(stars) do s:Destroy() end end
end

-- 4) STAGNANT SHINE: static soft highlight on the top half (glass look). No animation.
function UIEffects.StaticShine(parent: GuiObject, strength: number?): () -> ()
	local f = Instance.new("Frame")
	f.Name = "FX_StaticShine"
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Size = UDim2.new(1, -8, 0.45, 0)
	f.Position = UDim2.fromOffset(4, 3)
	f.ZIndex = parent.ZIndex + 4
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = f
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Transparency = NumberSequence.new(1 - (strength or 0.45), 1)
	g.Parent = f
	f.Parent = parent
	return function() f:Destroy() end
end

-- 5) BUBBLE GLOSS: rotate a UIGradient forever (glassy, liquid look). Pass an existing UIGradient.
function UIEffects.Gloss(gradient: UIGradient, cycle: number?): () -> ()
	local t = 0
	local conn = RunService.RenderStepped:Connect(function(dt)
		t = (t + dt) % (cycle or 7)
		gradient.Rotation = 180 - 360 * (t / (cycle or 7))
	end)
	return function() conn:Disconnect() end
end

-- 6) RINGING: bell-shake (great for "!" notification badges and the Shop open button).
function UIEffects.Ring(obj: GuiObject, pause: number?): () -> ()
	local running = true
	local base = obj.Rotation
	task.spawn(function()
		local offsets = { 40, -40, 25, -25, 10, -10, 5, -5, 0 }
		while running and alive(obj) do
			for _, o in ipairs(offsets) do
				local tw = TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = base + o })
				tw:Play(); tw.Completed:Wait()
			end
			task.wait(pause or 0.7)
		end
	end)
	return function() running = false; obj.Rotation = base end
end

-- Extra: slow spin (sunburst behind featured items / reward reveals).
function UIEffects.Spin(img: GuiObject, secondsPerTurn: number?): () -> ()
	local conn = RunService.RenderStepped:Connect(function(dt)
		img.Rotation = (img.Rotation + 360 * dt / (secondsPerTurn or 14)) % 360
	end)
	return function() conn:Disconnect() end
end

-- Extra: hover/press bounce for any GuiButton.
function UIEffects.Bounce(btn: GuiButton): () -> ()
	local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = btn
	local info = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local c = {
		btn.MouseEnter:Connect(function() TweenService:Create(scale, info, { Scale = 1.07 }):Play() end),
		btn.MouseLeave:Connect(function() TweenService:Create(scale, info, { Scale = 1 }):Play() end),
		btn.MouseButton1Down:Connect(function() TweenService:Create(scale, info, { Scale = 0.93 }):Play() end),
		btn.MouseButton1Up:Connect(function() TweenService:Create(scale, info, { Scale = 1.07 }):Play() end),
	}
	return function() for _, x in ipairs(c) do x:Disconnect() end end
end

return UIEffects
