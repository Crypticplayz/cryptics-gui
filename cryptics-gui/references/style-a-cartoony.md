# Style A — Cartoony 3D Sticker

For pet, egg, simulator, tycoon and kid-focused games. Bright, chunky, toy-like, every element looks like a glossy 3D sticker.

## Font
**Fredoka One** for everything (titles, buttons, numbers). Built into Roblox: `Enum.Font.FredokaOne` (or `Font.new("rbxasset://fonts/families/FredokaOne.json")`).

## Palette
| Role | Hex | Dark shade (3D lip) |
|---|---|---|
| Positive / buy / equip | #3DDC5A | #1E8E34 |
| Close / delete / danger | #FF4D4D | #B02020 |
| Header / info | #3FA9FF | #1C66B8 |
| Cash / legendary | #FFC93C | #C98A00 |
| Epic | #A45CFF | #6420C0 |
| Neutral / filter | #9AA3AD | #5C646C |
| Window background | #FFFFFF | — |

Rarity: Common #B8C0C8 · Uncommon #3DDC5A · Rare #3FA9FF · Epic #A45CFF · Legendary #FFC93C · Mythic #FF4D4D · Secret = rainbow gradient.

## The 5-layer 3D stack (buttons, cards, headers, tabs)
1. **Top face** — corner radius 10px; vertical linear gradient, bright tint at top → saturated main color at bottom.
2. **Inside stroke** — 4px, light tint of the main color (reads as a bevel highlight).
3. **3D lip** — duplicate the shape, move it down **Y +4 to +6px**, fill with **solid BLACK #000000** (user rule — not a darker shade), place behind the top face.
4. **Outline** — 3px solid black OUTSIDE stroke around the merged silhouette of top face + lip.
5. **Sticker border (cards/panels only)** — 6px solid white outside stroke + soft drop shadow centered (X0, Y0, blur ~12, 25%).

## Gloss and texture (clipped inside every top face)
- Two diagonal white shine stripes, one wide and one thin, 25–40% opacity, ~30° angle, near the top-left.
- Halftone dot pattern in one corner: blend **Soft Light** on cards/headers, **Overlay** on buttons.

## Text
White Fredoka One + 3px black outline + a duplicated dark copy offset 3px down behind it (3D text). On colored buttons the offset copy uses the button's dark shade.

## Main window
- White #FFFFFF, radius 10px
- 5px **inside dashed** stroke in header blue
- 6px **outside** solid white stroke
- Centered drop shadow
- Header pill (blue 3D stack) overlapping the top edge, centered, title in 3D text
- Red square 3D close button overlapping the top-right corner

## Search bar
White, radius 10px, Inner Shadow (X0 Y0, 30% black), 2–3px gray outside stroke, gray "Search..." placeholder, magnifier icon left.

## Pet / item card
3D stack in the rarity color, white sticker border, pet render centered and slightly overflowing the top, small tags (level, size, mutation) as mini pills in the corners, selected state = thick white outline + slight scale up.

## In Roblox Studio
Don't rebuild these layers with native frames. Export each piece from Figma/HTML with face, lip, outline, studs and gloss baked in, import it, and place it as an ImageLabel/ImageButton. Only the text is a TextLabel (FredokaOne + black UIStroke 3), and motion comes from UIEffects.
