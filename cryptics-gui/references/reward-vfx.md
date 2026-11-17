# Reward and hatch effects (VFX for UI)

Skill Made By : Crypticplay_RBLX - Only on Youtube

Hatch reveals, daily-reward claims and rare drops need more than a static image. The catch: **ParticleEmitters don't draw inside 2D UI, and they don't draw inside ViewportFrames either.** So UI effects come from three places, cheapest first:

## 1. UIEffects (already in the skill)
Spin a sunburst behind the reward, Sparkles on the corners, Glow behind the item, Shine on the claim button. Enough for most claim screens.

## 2. Flipbooks on an ImageLabel (bursts, flashes, swirls)
A sprite sheet PNG (e.g. 4×4 frames, 1024×1024 max) played frame by frame with `UIKit.flipbook`:
```lua
local burst = UI.icon(reveal, { name = "FX_Burst", rect = {360, 120, 400, 400}, image = ids.burst_sheet })
UI.flipbook(burst, { columns = 4, rows = 4, fps = 30, sheetSize = Vector2.new(1024, 1024) })
```
Where the sheets come from:
- The **roblox-vfx** skill, if installed, generates 2,000+ original textures including flipbooks (impacts, shockwaves, magic, sparks) in `sim/textures/lib/`. Search with `python sim/tex/lib/find_tex.py impact glow`, export the sheet as PNG, upload it (`upload_image`), tint with `ImageColor3`.
- ui-resources.com Effects (ask before downloading).
White sheets + `ImageColor3` = one sheet for every rarity colour.

## 3. World-space VFX behind a transparent overlay (big moments)
For a Secret/Mythic hatch, play a real roblox-vfx kit in the world in front of the camera (or at the player), with the reveal UI on top and the Dim at 0.2–0.3 so the effect shows through. Time the UI reveal to the effect's flash frame.

## Timing that feels good (hatch)
| t (s) | What happens |
|---|---|
| 0.0 | Dim in, egg pops in (Back easing), sound `ui_click` |
| 0.0–1.2 | Egg wiggles harder each tap ("TAP!" prompt), rays Spin |
| 1.2 | White flash (flipbook or a full-screen white ImageLabel fading 0→1→0 in 0.15 s) |
| 1.3 | Item pops in at 1.15× → 1.0×, rarity banner slides in, `rare_hatch` sound for Legendary+ |
| 1.3+ | Sparkles + Glow in the rarity colour; Secret gets Gloss on a rainbow overlay |
| end | Buttons (Equip / Keep / Auto-Delete) fade in last, so nobody skips by accident |

Rare pulls get bigger: Legendary adds the burst flipbook, Mythic/Secret add screen shake (camera, 0.2 s) and the world-space effect. Respect `UIKit.Settings.reduceMotion`: skip shake and flashes, keep the reveal.
