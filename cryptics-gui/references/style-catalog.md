# Style catalog — the menu to show the user

Show this numbered menu at the start (see SKILL.md step 1). Each style has a recipe. Styles 1 and 3 have full recipe files; the rest are below. Every style still follows the Figma-first + export workflow and the quality bar.

| # | Style | Best for | Look in one line |
|---|---|---|---|
| 1 | **Cartoony 3D Sticker** | pets, simulators, kids, tycoons | bright, chunky, glossy, black outline + white sticker border → `style-a-cartoony.md` |
| 2 | **Stud (classic Roblox)** | obbies, tycoons, nostalgic games | blocky plates with the Roblox stud texture, primary colors, hard edges |
| 3 | **Anime Glow** | anime, fighting, tower defense, RPG | dark purple/navy, neon gradient strokes, slashed headers → `style-b-anime.md` |
| 4 | **Clean Modern / Minimal** | shooters, social hangouts, utilities | flat, lots of space, soft shadows, one accent color |
| 5 | **Glass / Frosted** | showcases, lobbies, premium shops | translucent blurred panels, thin white borders |
| 6 | **Pixel / Retro** | arcade, 2D-feel, nostalgia | 8-bit pixel borders, pixel font, hard shadows, no smooth corners |
| 7 | **Sci-Fi Neon** | space, cyber, futuristic shooters | cut corners, thin cyan lines, scanlines, holographic glow |
| 8 | **Fantasy / Medieval** | RPG, dungeon, magic | parchment, wood, gold trims, serif titles, gem accents |
| 9 | **Horror** | horror, escape, survival | grunge, scratches, dark red/black, distressed text, flicker |
| 10 | **Candy / Kawaii Pastel** | cute, cafe, dress-up, girls' RP | pastel pinks/blues, bubbly round shapes, hearts/sparkles |
| 11 | **Military / Metal** | war, tower defense, tycoon factory | metal plates, rivets, hazard stripes, stencil font |

---

## 2. Stud (classic Roblox) — upgrade: **Studded Glass** (the signature look)
Studded Glass = saturated gradient surfaces + stud grid texture on everything + big glass glare + slate-gray inner body + overflowing 3D icons + full-width rainbow/yellow header slab. See `signature-looks.md` for the exact layout (shop, HUD tiles, daily rewards, spin wheel).

### Basic Stud
- **Shapes:** rectangles with small radius (2–4px) or none; chunky thick plates like bricks.
- **Texture:** the Roblox **stud** pattern (circles in a grid with a soft top highlight) on panel tops. ALWAYS a ui-resources.com stud texture (tag *Stud*), never homemade (SKILL.md rule 7).
- **Colors:** classic brick colors — Bright red #C4281C, Bright blue #0D69AC, Bright yellow #F5CD30, Dark green #287F47, Medium stone grey #A3A2A5, plus a black 3px outline.
- **Depth:** hard bottom lip 6px in BLACK #000000 (SKILL.md rule 11), no soft shadows.
- **Font:** Luckiest Guy or Fredoka One (bold, blocky), white with black stroke.
- **Buttons:** look like 2×1 bricks; pressed = lip shrinks to 2px.
- **Roblox:** export the studded plates as 9-slice PNGs (studs, outline and lip baked in) and place them as ImageLabels.

## 4. Clean Modern / Minimal
- **Shapes:** radius 14–20, generous padding (24+), consistent 8px spacing grid.
- **Colors:** neutral surfaces (#F5F6F8 light or #15171C dark) + ONE accent (e.g. #5B8CFF). Text 2 shades only.
- **Depth:** soft shadow (y 8, blur 24, 12%) or none; 1px border #FFFFFF14 on dark.
- **Font:** Builder Sans / Gotham / Montserrat SemiBold–Bold; no text stroke.
- **Icons:** line or duotone icons, single color.
- **Roblox:** export the flat panels/buttons as 9-slice PNGs and place them as ImageLabels (small files, very light).

## 5. Glass / Frosted
- **Panels:** white fill 10–18% opacity, background blur 20–30, 1.5px white stroke 35%, radius 20.
- **Accent:** colorful gradient blobs behind panels so the glass reads.
- **Text:** white, SemiBold, subtle shadow.
- **Roblox:** no real background blur in UI — fake it: export the blurred glass panel as PNG (optionally add Lighting BlurEffect while the menu is open).

## 6. Pixel / Retro
- **Borders:** stepped pixel corners (no anti-aliased radius) — draw corners as 2–3 pixel steps; 4px solid outline.
- **Colors:** limited palette (PICO-8 / NES style), flat fills, dithering for gradients.
- **Font:** a pixel font (e.g. Press Start 2P) — export text as images for titles, Roblox Arcade font (Enum.Font.Arcade) for dynamic text.
- **Depth:** hard 4px drop shadow, no blur.
- **Export:** PNGs at exact integer scale; set ImageLabel.ResampleMode = Pixelated in Roblox.

## 7. Sci-Fi Neon
- **Shapes:** cut (chamfered) corners — 45° notches; thin 1.5–2px strokes; corner brackets.
- **Colors:** near-black #05080F + cyan #2EF2FF / magenta #FF2EA6 accents; outer glow on strokes.
- **Details:** scanline overlay (1px lines, 6% opacity), grid background, small tech labels ("SYS.01"), animated pulse.
- **Font:** Orbitron / Exo 2 / Michroma (titles), Montserrat for body.
- **Roblox:** chamfered panels exported as 9-slice PNGs; glow via ImageLabel behind; pulse with TweenService on ImageTransparency.

## 8. Fantasy / Medieval
- **Surfaces:** parchment (cream with paper texture), dark wood frames, leather.
- **Trims:** gold ornamental borders, corner flourishes, gem sockets (rarity gems).
- **Colors:** parchment #E9D7B0, wood #5A3A22, gold #E0B04A, deep red #8E1C1C.
- **Font:** Cinzel / MedievalSharp / IM Fell for titles; readable serif or Fredoka for numbers.
- **Textures:** paper/wood from ui-resources.com (Textures, Backgrounds).
- **Roblox:** ornate frames as 9-slice PNGs; text as TextLabels on top.

## 9. Horror
- **Surfaces:** dark (#0B0B0B–#1A1212), grunge/scratch textures, torn paper, dried blood red #7A0F0F.
- **Font:** distressed (Creepster, Nosifer) for titles only; simple sans for numbers.
- **Effects:** vignette, flicker (tween transparency randomly), slight shake on open, scorch/crack overlays (ui-resources.com tags Horror, Scorch, Haunted).
- **Rule:** keep buttons readable — horror on the frame, clarity on the content.

## 10. Candy / Kawaii Pastel
- **Shapes:** very round (radius 24+ / pills), bubbly outlines, wavy edges.
- **Colors:** pastel pink #FFB6D9, mint #B8F2E6, lavender #CDB4FF, butter #FFE8A3, white.
- **Outline:** 3–4px darker pastel (not black), white inner highlight.
- **Decor:** hearts, stars, sparkles, sprinkles, drip edges (ui-resources.com tags CandyLand, Hearts, Sparkle).
- **Font:** Fredoka / Baloo 2 / Lilita One.

## 11. Military / Metal
- **Surfaces:** brushed metal or olive plates, rivets in corners, scratches, hazard stripes (yellow/black 45°) on warnings.
- **Colors:** gunmetal #3A3F44, olive #4B5320, steel #9AA4AE, warning yellow #F2C200.
- **Font:** stencil / Black Ops One / Teko for titles.
- **Textures:** metal plates and scratches from ui-resources.com (tag Metal).
- **Roblox:** plate frames as 9-slice PNGs; rivet decals as separate ImageLabels.

---

## Mixing styles
A user can ask for a mix (e.g. "anime glow but with cartoony buttons"). Lock the panel/background style from one and the button/text style from the other, then confirm with ONE screen first.
