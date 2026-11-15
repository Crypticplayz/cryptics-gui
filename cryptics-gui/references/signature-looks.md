# Signature looks — UI that can't be made with plain Studio frames

The user's rule: **"I need it to be unique — stuff that can't be done in Studio."** Frames + UICorner + UIStroke + UIGradient is what every game has. Top games bake extra **texture, depth and light** into PNGs made in a design tool. Every screen must use **at least 3 signature layers** from the list below, made in Figma and exported as images (9-slice where it stretches).

## Signature layers (need a design tool)
1. **Stud texture overlay** — the Roblox stud grid printed on every surface (panels, header bar, cards, buttons, wheel segments) at 8–15% white/dark. Instantly "premium Roblox". (Studded Glass kit.)
2. **Glass glare** — big soft diagonal white sheen across the top-left half of a panel/card + a hard thin streak; plus 1–2 white highlight dots on buttons (jelly/bubble buttons).
3. **Rainbow / holographic gradients** with diagonal glare — for "OP VALUE!", Day 7, Secret rarity, best bundle.
4. **Gem-cut bevel** — square button = outer darker frame + inner lighter face + corner highlight dots (gemstone buttons).
5. **Chamfered / angled silhouettes** — cut corners, slanted header slabs, tilted panels (anime reward panel with orange slashed tab, sci-fi hex buttons).
6. **Stacked paper / offset double panel** — a second panel offset behind (+8,+8) in a darker tone or with a halftone, like the "Statistics" card.
7. **Overflowing icons** — big 3D icon breaking out of the top-left of a header bar or the top of a button (Shop basket, calendar "31", fire for Streak, globe for Worlds), with its own drop shadow.
8. **Slanted, oversized hero buttons** — the giant yellow skewed "SHOP" button with the basket bursting out; coin icons as chunky octagons.
9. **Gradient-fill text** — title text with vertical gradient (yellow→orange "OP!", "0 DAY STREAK") + thick dark outline + offset shadow; text that is colored per word.
10. **Halftone / dot patterns** in panel corners and dark panels (anime reward panel).
11. **Neon edge glow** on dark slots (blue/purple outlines that bleed light) — anime/dark style.
12. **Textured backgrounds** inside windows: dark slate with stud grid (Studded Glass shop body), checker/grid behind items.

## Layout patterns learned from the references
- **Header bar = wide gradient slab** across the full window top (rainbow/yellow/blue + studs), title left-aligned big, icon overflowing at top-left, red square X at right **inside** the bar. (Not a small centered pill.)
- **Body = darker inner panel** (slate gray with studs) under a bright header → strong contrast, items pop.
- **Left tab rail** of dark rounded buttons with icon + label; selected one bright yellow with star.
- **Featured row** first: "Starter Pack" rainbow card spanning full width — items shown as small framed tiles joined by "+" signs, "OP VALUE!" angled gradient text, big green price button with Robux icon.
- **Gamepass/item cards** in strong single colors (cyan, magenta, peach) with studs, centered big icon, title on top, price button at the bottom; owned = gray "OWNED" + green check on the corner.
- **HUD menu**: grid of square tiles (3×4), each tile a different saturated gradient with studs + big icon + label; red "!" badges on Spin/Rewards/Daily. Top-center: compact boost timers (icon + time + "x2 Cash" under). Right: wide pill buttons with icon + text + sub-reward ("Invite +10% Cash", "Updates"). Bottom-left: cash. Bottom-right: music widget.
- **Daily rewards**: 6 day cards in a row (rarity colors, "DAY n" top, icon, amount, CLAIM/LOCKED button), Day 7 = full-width rainbow card with "OP!", progress bar "0 / 7 DAYS", streak text in gradient.
- **Spin wheel**: segments in rainbow colors with studs, prize icon + amount per slice, star hub, pointer gem on top, side panels "YOUR SPINS" and "GET MORE" (price cards with POPULAR/BEST tags), bottom row %, SPIN!, X.
- **Streak / progress**: big flame icon, thick progress bar with milestone ticks (7/14/21) and reward tiles above each milestone.
- **Worlds list**: tall stacked cards (green/magenta/red), title + requirement line + one action button each.
- **Bottom offer strip**: gradient pill buttons with speed amounts and Robux price tags in corner bubbles.

## Button families (pick one per game, keep consistent)
- Jelly/bubble: very round, strong top-left highlight dots, saturated.
- Gemstone square: beveled frame + inner face + corner glints.
- Glass capsule: translucent with diagonal swirl gloss.
- Sci-fi chamfer: dark fill, cyan/purple glowing edge, hex/cut corners.
- Studded: chunky with stud texture + dark outline + bottom lip.

## How to build them
- Make each signature layer as a Figma component (e.g. `Tex/Studs`, `FX/GlassGlare`, `Frame/HeaderSlab`), clip them inside panels, export the composed backgrounds as 9-slice PNGs (corners fixed). Text, numbers, icons stay separate so they're editable in Roblox.
- Studs: ALWAYS the ui-resources.com stud textures (`assets/textures/`, Overlay blend) — never homemade. Halftones/gradients: ui-resources.com first (tags Halftone, Gradients); SVG dot grids only as a last resort.
- Then add motion with `assets/UIEffects.lua` (see `ui-effects.md`).
