# Animated UI effects (UIEffects module) — use on EVERY UI

Files in this skill:
- `assets/UIEffects.lua` — one ModuleScript version of all effects (+ Spin and Bounce). Put it in ReplicatedStorage as `UIEffects` and require it from LocalScripts. Every function returns a cleanup function.

Glow and Sparkles need two white PNGs (a soft glow and a 4-point sparkle, e.g. ui-resources.com → Effects: shine2.png, sparke.png). Upload them (Studio MCP `upload_image`) and set `FX.Images.Glow` / `FX.Images.Sparkle` to the ids before calling those effects. Tint with ImageColor3.

## The effects + where to use them
| Effect | What it does | Use it on | UIEffects call |
|---|---|---|---|
| **Glowing** | glow image behind the frame, fades 0↔1 (Sine, 1.5 s) | primary CTA (BUY on hero), Free Gift / Claim, selected tab | `UIEffects.Glow(btn, Color3, 1.5)` |
| **Moving Shine** | white gradient streak sweeps left→right (3 s, loop) | every important button, featured banner, legendary cards | `UIEffects.Shine(btn, 2.5, 0.9)` |
| **Sparkles** | stars shrink/grow + spin (0.5–2 s, staggered) | rare/legendary/mythic cards, Shop open button, rewards | `UIEffects.Sparkles(card, {Vector2...}, 26)` |
| **Stagnant Shine** | static white top highlight (glass) | all glossy buttons/panels (cheap, no animation) | `UIEffects.StaticShine(btn, 0.45)` |
| **Bubble Gloss** | rotates a UIGradient 180→-180 over 7 s | rainbow / "OP" cards, glass buttons, Secret rarity | `UIEffects.Gloss(uiGradient, 7)` |
| **Ringing** | bell shake 40,-40,25,-25,10,-10,5,-5,0 then pause 0.7 s | red "!" notification badges, Shop/Daily button when something is claimable | `UIEffects.Ring(badge, 0.7)` |
| Spin (extra) | slow rotation | sunburst behind featured item, reward reveal rays | `UIEffects.Spin(sunburst, 14)` |
| Bounce (extra) | hover 1.07 / press 0.93 | every button | `UIEffects.Bounce(btn)` |

## Rules (so it looks premium, not noisy)
- Strongest effects on the ONE hero element per screen (glow + shine + sparkles); rares get sparkles; commons get nothing but Bounce + StaticShine.
- Max ~3 looping effects visible at once besides Bounce/StaticShine.
- Ringing only while something is actually claimable — stop it after the player opens the menu.
- Pause loops when the window is closed (call the cleanup functions) to save performance.
- In Figma mockups, show where effects go with a small note layer ("fx: Shine", "fx: Ring") so the Studio assembly knows which effect goes where.

## Example (Shop open button + hero)
```lua
local FX = require(game.ReplicatedStorage.UIEffects)
FX.Images.Glow = "rbxassetid://YOUR_GLOW_ID"
FX.Images.Sparkle = "rbxassetid://YOUR_SPARKLE_ID"
local hud = script.Parent
FX.Bounce(hud.Btn_OpenShop)
FX.Sparkles(hud.Btn_OpenShop, { Vector2.new(0.85, 0.1), Vector2.new(0.1, 0.4) }, 22)
local stopRing = FX.Ring(hud.Btn_OpenShop.NotifBadge)
local shop = hud.Parent.ShopGui.Window
FX.Spin(shop.Hero.Sunburst, 16)
FX.Glow(shop.Hero.BuyButton, Color3.fromRGB(120, 255, 120))
FX.Shine(shop.Hero.BuyButton)
```
