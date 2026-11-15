# Assembling the UI in Roblox Studio

Studio is for importing the exported PNGs and putting them together. Never design the look here with native Frames + UICorner + UIStroke + UIGradient: every visual comes from the images made in Figma or the HTML board.

## Structure
```
StarterGui
  MainHUD (ScreenGui)        ResetOnSpawn=false, ZIndexBehavior=Sibling, ScreenInsets=CoreUISafeInsets
    Currency, Menu, Boosts ...
  Windows (ScreenGui)        one Frame per window, Visible=false by default
    Inventory, Shop, Index ...
  Overlays (ScreenGui)       DisplayOrder higher: Hatch, Announcements, Toasts
```
One LocalScript (or a UI controller ModuleScript) opens/closes windows so only one window is open at a time.

## Scaling rules
- Size and Position in **Scale**, AnchorPoint 0.5,0.5 for centered windows
- `UIAspectRatioConstraint` on every window, card and square button
- `UISizeConstraint` to cap huge sizes on 4K / ultrawide
- Text: `TextScaled = true` + `UITextSizeConstraint` (MaxTextSize) or fixed sizes per breakpoint
- Test with Device Emulator (Test tab): phone, tablet, desktop, console

## Buttons and panels
Each button/panel = transparent container + ImageLabel/ImageButton showing its exported PNG (face, lip, outline, gloss all baked in). Never rebuild them from Frames, UICorner, UIStroke or UIGradient.

## 9-slice images
ImageLabel: `ScaleType = Enum.ScaleType.Slice`, `SliceCenter = Rect.new(left, top, right, bottom)` in source pixels, optional `SliceScale`.

## Grids
ScrollingFrame (ScrollBarThickness small, AutomaticCanvasSize Y, CanvasSize 0) → UIGridLayout (CellSize in scale, 5 columns) + UIPadding. For many items, reuse card templates (clone from ReplicatedStorage).

## Button feel (LocalScript)
```lua
local TweenService = game:GetService("TweenService")
local function bounce(btn)
	local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
	local info = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	btn.MouseEnter:Connect(function() TweenService:Create(scale, info, {Scale = 1.06}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(scale, info, {Scale = 1}):Play() end)
	btn.MouseButton1Down:Connect(function() TweenService:Create(scale, info, {Scale = 0.94}):Play() end)
	btn.MouseButton1Up:Connect(function() TweenService:Create(scale, info, {Scale = 1.06}):Play() end)
end
```

## Window open/close
Open: set Visible, UIScale 0.8 → 1 with Back easing 0.2s, background dim fades in. Close: reverse, then Visible=false. Blur (Lighting BlurEffect Size 0→12) for big windows is a nice touch.

## Rarity effects
- Rarity looks (rainbow, gold, glow) are baked into the exported card PNGs. In Studio only animate them: UIEffects.Gloss on a rainbow overlay image, UIEffects.Glow behind legendaries, swap to a "selected" PNG on selection.

## Performance
- Reuse templates, avoid hundreds of UIGradients animating at once
- Hide closed windows (Visible=false), don't just move them off screen
- Keep image count low; prefer shared overlays tinted with ImageColor3
