# Gamepad, console, data-driven grids and accessibility

Skill Made By : Crypticplay_RBLX - Only on Youtube

## Gamepad and console
Console players can't use a shop they can't navigate. `UIKit` does most of this for you:
- Every `UIKit.button` is `Selectable`. Export a **selection ring PNG** (a glow outline in the style) and set `UIKit.Theme.SelectionImage` to its id so the highlight matches the UI instead of Roblox's default box.
- `UIKit.window` sets `SelectionGroup = true` (the D-pad can't wander out of the open window), puts focus on the first button when the window opens on console (`GuiService:IsTenFootInterface()`), and binds **B / Esc to close**.
- Order matters: build buttons in reading order (tabs top→bottom, then grid left→right, then the main action). If the D-pad jumps oddly, set `NextSelectionUp/Down/Left/Right` on the edge buttons.
- Show button hints on console (e.g. a small "B" next to Close, "A Buy"): export them as PNG icons and show them only when `UserInputService.GamepadEnabled`.
- Console safe area: keep everything inside the middle 90% of the screen.

## Data-driven grids
Inventories and indexes come from data, not hand-placed cards:
```lua
local grid = UI.grid(win.Frame.Scroll, {
	columns = 5, aspect = 0.86, gap = 16, padding = 16,
	build = function(pet, cell)
		local card = UI.piece(cell, { name = "Card", rect = {0, 0, 200, 232}, parentDesign = Vector2.new(200, 232),
			image = ids["card_" .. pet.rarity], margin = 10, button = true })
		UI.icon(card, { rect = {28, 16, 144, 144}, image = pet.icon })
		UI.label(card, { name = "Lbl_Name", text = pet.name, rect = {14, 166, 172, 34} })
		UI.label(card, { name = "Lbl_Power", text = UI.abbrev(pet.power), rect = {14, 196, 172, 26}, color = Color3.fromRGB(255, 220, 90) })
		UI.button(card, { onClick = function() select(pet) end })
	end,
})
grid.setItems(playerPets)   -- call again whenever the inventory changes
```
- Only the visible rows (+1 buffer) exist, so 500 pets scroll as smoothly as 20.
- Grids: **inventory / index = 5 columns** (long names); **shop cards = 4 columns** on desktop.
- Numbers always go through `UI.abbrev` (1.23K, 4.5M, 1.2B…) or `UI.commas` (12,500); timers through `UI.time` (9:59, 1:02:03, 2d 4h). Size the TextLabel for the longest formatted string (e.g. "999.9Qa"), not today's balance.

## Accessibility
- **Rarity is never colour only.** Every rarity card/tag also shows its label or symbol (`UIKit.Rarity[r].label` / `.symbol`) so colour-blind players can tell Rare from Epic.
- **Contrast:** coloured text always has the black outline; never light text on a light card.
- **Text:** ≥ 14 px on a phone (the audit checks it). Leave ~30% spare width in every text box for translations (German, Portuguese and Russian run long). Keep text in TextLabels so Roblox's automatic translation can reach it.
- **Motion:** `UIKit.Settings.reduceMotion` follows the player's Roblox "Reduce Motion" setting: no open tweens, no blur, no Bounce, no flashes or shake. Effects that carry meaning (a badge appearing) still show, just without the wiggle.
- **Never flash** the whole screen more than 3 times per second.
