# HTML board → Roblox (proven pipeline, used for the Shop v4)

Design happens on the board (or in Figma). Studio is only for importing the PNGs and assembling them. Never recreate the look with native frames.

## 1. Export pieces (no text, transparent, black lip/glow included)
- Board page includes `assets/templates/export.js` (`<script src="export.js">`). It defines `EXPORT.PIECES` (name → selector + margin), `EXPORT.prepare(name)` (hides everything except that piece, strips its text, makes the page transparent) and `EXPORT.layout()` (positions of every piece, icon, decoration and text relative to `.win`).
- Margin per piece: 10px for the black lip, 40px for glow (selected tab, HUD button), 12 for rotated tags.
- **Playwright in this setup renders at devicePixelRatio 0.667** — element/clip screenshots come out misaligned. What works: set `document.documentElement.style.zoom = '1.5'`, take `page.screenshot({ fullPage: true, omitBackground: true, scale: 'css' })` per piece, read the piece rect (already ×1.5), then crop in Python with factor **2/3**: box = (rect ± 1.5·margin) × 2/3. Result = exact 1:1 PNG.
- Body/html background must be transparent in export mode, and the `.decor` layer kept only where it should be baked (e.g. halftone in a card); animated parts (rays to spin, sparkles) are exported/uploaded separately.
- Check with a checkerboard contact sheet before uploading. Downscale anything > 1024px (Roblox max).
- `browser_run_code_unsafe` can't write files (no fs) — return JSON and paste the numbers into the Luau assembly script.

## 2. Import into Roblox
- Serve the folder (`python -m http.server 5180 --directory ui-board`) and call Roblox Studio MCP `upload_image` with `http://localhost:5180/...` URLs. **Max ~5 images per call** — 22 at once timed out. Returns `rbxassetid://` per URL. Duplicate images return the same id.
- No Studio MCP? Give the user the PNG folder + `layout.txt` and the steps (Asset Manager → Bulk Import → send back the IDs), then continue with step 3.

## 3. Assemble in Studio (execute_luau) — images only, no native styling
- `ShopGui` (IgnoreGuiInset, ZIndexBehavior Sibling) → `Dim` + `Window` (AnchorPoint .5, Size scale, `UIAspectRatioConstraint` = W/H of the design incl. lip, `UIScale` for open tween).
- Every piece = container (Frame / TextButton for clickables, fully transparent) at the design rect in **Scale** relative to its parent rect, with child `Bg` ImageLabel showing the exported PNG, offset by −margin and sized 1+2·margin/size. Store `BgKey`/`BgMargin` attributes so tabs can swap gold-glow ↔ base image.
- Containers stay invisible (BackgroundTransparency 1, no UIStroke/UICorner/UIGradient for looks). All visuals come from the PNGs.
- Icons = ImageLabels (ScaleType Fit). Text = TextLabels (Fredoka One `Font.new("rbxasset://fonts/families/FredokaOne.json")`, TextScaled) + UIStroke black with `BaseThickness` attribute; gradient text = UIGradient (Rotation 90) on the TextLabel. (Text is the one exception, because it has to change at runtime.)
- Decorations that must stay inside a rounded card = **CanvasGroup + UICorner** used only as a mask (e.g. spinning rays). Shine needs its own CanvasGroup mask (so the button's lip isn't clipped).
- Controller LocalScript: scale every UIStroke by `Window.AbsoluteSize.X / designWidth` on resize; open/close tween; tab select; buy placeholders (hook MarketplaceService on the server later); effects from `ReplicatedStorage.UIEffects`: Bounce on every GuiButton, Ring on badges (stop after opening), Spin rays, Shine + Glow on the hero BUY, Twinkle on sparkle stars.
- HUD open button in its own `HUD` ScreenGui with aspect 1 (DominantAxis Height).
- Playtest, screenshot, check console; remind the user to **save the place** (File → Save to Roblox / Ctrl+S).
