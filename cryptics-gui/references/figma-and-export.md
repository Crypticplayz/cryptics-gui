# Figma workflow and export for Roblox

## File structure
- Page "00 Style" — palette, type styles, effect styles, the 5-layer stack demo
- Page "01 Components" — Button, Card, Window, Header, Tab, CloseButton, CurrencyPill, ProgressBar, Toggle
- One page per screen: "HUD", "Inventory", "Hatch", "Shop", "Index", "Gamepasses", "Popups"
- Frames: 1920×1080 desktop, plus 844×390 phone check frame for each screen

## Components and variants
- Button: Color (Green/Red/Blue/Gray/Gold) × State (Default/Hover/Pressed/Disabled)
- Card: Rarity (Common…Secret) × State (Default/Selected/Locked)
- Use auto layout so labels can grow; set text to "Fredoka One"
- Use color/effect styles (or variables) so a palette change updates everything

## Layer naming (matches Roblox instances)
`Frame_Inventory`, `Btn_EquipBest`, `Card_Pet`, `Icon_Cash`, `Lbl_PetName`, `Img_Gloss`, `Header_Pets`
Prefixes: Frame_, Btn_, Card_, Icon_, Lbl_ (TextLabel), Img_ (ImageLabel), Bar_, Tab_

## What to export vs rebuild in Roblox
Export as images:
- Icons, item renders, gloss/halftone overlays, angular headers, glow trims, complex frames
Do NOT export (rebuild as Roblox instances):
- Any text that changes (numbers, names, prices, timers)
- Simple rounded rectangles with solid/gradient fill and strokes (UICorner/UIGradient/UIStroke are lighter)

## Export settings
- PNG, @2x, transparent background, one element per file
- Max 1024×1024 per image (Roblox downscales larger)
- Frames/panels meant to stretch: keep corners intact and middle uniform so they 9-slice; note the slice margins (e.g. 24px) for SliceCenter
- Trim empty transparent space; consistent pivot/centering for icons (same canvas size per icon set, e.g. 256×256)

## Figma MCP practical notes (learned the hard way)
- Upload the user's icon PNGs with `upload_assets` + curl multipart POST. On Windows, curl needs `C:/Users/...` paths — `/c/Users/...` fails silently (empty response). Check each response has `"success":true` and keep the returned `imageHash` per icon.
- Put icons on a rectangle with `{type:'IMAGE', imageHash, scaleMode:'FIT'}` — reuse hashes everywhere instead of re-uploading.
- Component property names get a `#id` suffix ("Label#2:5"). Resolve the real key from `instance.componentProperties` before `setProperties`.
- A failed `use_figma` script is atomic — nothing is left behind, so fix and rerun.
- Proven anime-glow recipe in Figma: panel fill vertical gradient #2A1740→#0F0918, INSIDE gradient stroke #B14CFF→#FF4FD8 3px, purple DROP_SHADOW glow (offset 0, radius 28, a .55) + purple INNER_SHADOW; two faint rotated white stripes clipped inside. Slashed header = SVG path with gradient fill + black stroke via `createNodeFromSvg`, title in Montserrat Black Italic with 5px black OUTSIDE text stroke. Glossy buttons = vertical gradient + 3px black OUTSIDE stroke + hard drop shadow y4 + white inner shadow y2 + a 32% white "Shine" rect on the top half.
- Rarity card = vertical gradient dark→rarity color + rarity INSIDE stroke + diamond gem; selected card = white 4px stroke + white glow.
- Proven cartoony 3D sticker recipe in Figma (component = non-auto-layout frame): Lip rect (BLACK #000000 — user rule, y+6, radius 16, 3px black OUTSIDE stroke) behind a Face frame (vertical gradient light→main, 3px black OUTSIDE stroke, white INNER_SHADOW spread 4 as the inner bevel, 45% white top Shine pill + faint diagonal Stripe). Cards add a white Sticker rect (+3px black outline, soft shadow) behind lip+face, a halftone dot SVG in the corner (SOFT_LIGHT, 35%), a rarity tag pill and a nested buy button. Window = white panel, 4px black outline, inner dashed blue rect (dashPattern [18,12], 5px), header/close buttons overlapping the top edge. Font: Fredoka Bold (Figma has no "Fredoka One") with black OUTSIDE text stroke + hard drop shadow.
- Recolor instances by overriding the Face fill (+ RarityTag); the Lip stays BLACK.
- Layout math: 4 cards of 232 in a 1000px wrap row need spacing ≤16 — check columns before screenshots.
- ui-resources.com "Visit/Download" are JS buttons: intercept `window.open` in the page to read the target URL. itch.io packs: ask the user to download the pack themselves from its itch.io page and tell you the folder; check the pack's license file before using or sharing its icons. Always get the user's OK before downloading anything.
- **When the Figma MCP cap is hit — fallbacks** (offer them, user picks): (a) user upgrades Figma (Professional/Org raises the cap); (b) wait for the cap to reset; (c) **HTML/CSS design board**: build the screen as a local HTML file (CSS gradients, blend modes, mask, filters, background-image studs from `assets/textures`, text-stroke) and render it in the browser pane — same "can't-do-in-Studio" quality, unlimited edits; export each piece as PNG by screenshotting elements; (d) give the user exact manual Figma steps.
- **Figma MCP rate limit** (Figma docs): Starter plan or View/Collab seat = **20 calls per month**; Full/Dev seat on Professional/Org = 200 per day (10–15 per minute); Enterprise = 600 per day. The user is on Starter (View seat) — about 20 calls per month total. Batch work into few, large `use_figma` scripts (build a whole screen per call, include the screenshot in the same call), avoid separate read/inspect calls, and don't waste calls on tiny tweaks. If the cap is hit, stop, tell the user, and give manual Figma steps for anything left.
- If the user names a UI kit that isn't in `get_libraries` (e.g. "Kek UI Essentials"), say so and ask for the file/link; build in that style meanwhile.

## Handing off to Roblox
- Upload with the Roblox Studio MCP `upload_image` (≤5 per call); if it isn't connected, the user imports via Asset Manager → Bulk Import and sends the IDs
- Keep a table: layer name → rbxassetid → slice margins
