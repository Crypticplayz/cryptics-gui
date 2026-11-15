# Style B — Anime Glow (dark, angular, luminous)

For anime, fighting, RPG and tower-defense games. Dark navy/charcoal surfaces with neon glowing edges and sharp angular silhouettes. Learned from Kek's "Greatest Anime UI" breakdown (built in Photoshop; reproducible in Figma with effects + blend modes).

## Fonts
- Stats/labels: **Montserrat Extra Bold**
- Headers: inverted contrast — text filled with the dark background color + bright white outer stroke

## Surfaces
- Main container: dark navy → charcoal radial/linear gradient (never flat black)
- Frame border: layered trims with Inner Glow + Outer Glow using Overlay, Color Dodge and Linear Dodge (Add) blend modes, plus angular corner accents
- Subtle diagonal light stripes clipped to panels, low opacity so they don't fight the content

## Layout
- Split pane: left scrollable grid, right showcase panel (large character/unit render, stats)
- Angular header carved with pen/warp tools (spikes, wings, tapered edges), with inner accent shards and multi-stop gradients
- Header exported separately so it sits at a higher ZIndex and overlaps the top of the window and search bar
- Grunge/claw texture clipped inside the header, duplicated: one dark (shadow), one bright (metallic reflection)

## Controls
- Search bar: black rectangle at reduced opacity (recessed look), geometric magnifier icon, muted "Search..." text
- Filter/Sort buttons: rounded rectangles with soft outer glow; icons drawn black with a stroke in Overlay mode so they look engraved
- Close X: dark angled base, glowing inner rim, crisp X glyph, soft outer glow, top-right
- Capacity counter (e.g. 45/100) near the top controls

## Primary buttons ("crystalline")
Angular cut base → Gradient Overlay → Inner Glow → carved white highlight facets in Color Dodge/Linear Dodge → soft Outer Glow.
Rule: bright, glowing, high-luminance = clickable primary action; dark high-contrast = structure.
Color variants: duplicate and shift Hue/Saturation (green Equip Best → red Unequip All) to keep glow intensity identical.

## Stat rows
- Dark solid boxes with Gradient Overlay fill, and a **gradient stroke** (not solid) for a metallic/neon edge
- Stat icons scaled larger than the box so they break out of the top and bottom edges (2.5D pop)
- Each stat row color-coded by swapping both fill and stroke gradients

## Grid cards
- Rounded square cards with inner border and rarity gradient
- Crisp white outer selection stroke, toggled on MouseEnter/selection in Studio
- **5 columns, not 6** — wider cards leave room for long unit names without colliding with the icon
- Rarity rows: Mythical prismatic/crimson, Legendary gold/amber, Epic purple, Uncommon green

## In Roblox Studio
- Everything visual (glows, angular shapes, textures, glow trims) is exported as PNG (9-slice where possible), imported, and placed with ImageLabels. No native-frame recreations.
- Text: TextLabel Montserrat (Enum.Font.Montserrat / GothamBlack as fallback) + UIStroke
