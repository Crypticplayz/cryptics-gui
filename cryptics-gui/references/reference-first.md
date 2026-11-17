# Reference first, wireframe second, style last — and the AI-slop check

Skill Made By : Crypticplay_RBLX - Only on Youtube

Designs made "from imagination" come out generic: same-size rounded cards, pastel gradients, glow on everything. Real Roblox UI designers start from references and a grey-box layout. So does this skill.

## 1. Collect 3 references before designing (every new screen or style)
1. **The user's own screenshots / Figma links win.** Ask for them first ("send 1–3 UIs you love").
2. Otherwise look them up (browser):
   - Figma Community: `https://www.figma.com/community/search?resource_type=files&sort_by=popular&query=roblox%20<screen>` (e.g. "roblox shop", "roblox inventory"). Open the top files and look at the cover image.
   - Roblox DevForum: "Show off your UI designs", designer portfolios ("UI portfolio").
   - The top games in the user's genre (front page) — screenshots of their shop/inventory.
   - Game UI Database / Interface In Game for non-Roblox ideas.
3. Write a **reference breakdown** (in chat, 5–8 lines) before building: layout (what is big, what is small), frame + corner size, outline/lip, colour use, icon size vs card, where prices sit, text style, how much effect. Build to that breakdown.
4. Never copy a game's art, logo or exact screen. Learn the structure and the finish, then make it your own.

Proven patterns from the references (2026):
- **Stud-style shop (Figma Community, most-used Roblox shop file):** thick dark outer frame, one big hero card across the top + smaller cards below (bento, not a uniform grid), tight 8–12 px gaps, flat saturated card colours with a faint stud texture, big black-outlined icons breaking out of card edges, price tab pinned to a card's bottom-left corner, heavy italic titles tilted a few degrees.
- **Pro designer process (unroot, Roblox Creator Spotlight):** scope the screen → find the game's vibe → wireframe in grey boxes → apply style → feedback → build. Mobile first. "If a 9-year-old gets it at a glance, it works."
- **Dark/competitive UI (Boxing Beta):** flat dark panels, small corners, one accent colour, dense but ordered information, the character/item art is the hero.

## 2. Wireframe in grey boxes, get a yes, then style
Lay the screen out with plain grey rectangles + text holders (no colour, no effects). Check hierarchy (one hero), reading order, phone size, thumb zones. Show it, get approval, THEN apply the style. Changing a layout after styling costs ten times more.

## 3. The AI-slop check (run before showing any design)
If two or more of these are true, it looks AI-made — fix it:

| Slop sign | Fix |
|---|---|
| Every card the same size in a uniform grid | One hero element clearly bigger; bento layout |
| Very round, soft, pastel blobs everywhere | Smaller corners (10–14 px), flat saturated faces, thick dark frame |
| Diagonal glare stripe / glow / gradient on every surface | Effects on ONE element (the thing you want clicked); everything else flat |
| Small icons sitting politely inside cards | Icons 1.2–1.5× the space, breaking out of edges, slightly rotated |
| Centred generic buttons on every card | Price tabs pinned to a corner, or one strong CTA per area |
| Unicode symbols (★ ♛ ✦ ▲) as decoration or rarity marks | Real icon PNGs; rarity = colour + the word |
| Neon purple/pink as "anime" | Dark flat panels + ONE accent colour |
| Invented content (fake pet names, powers, prices, timers) | Content sheets; empty = text holder (`references/content-and-placeholders.md`) |
| Everything perfectly straight and centred | Tilt titles 2–4°, offset icons, let one thing break the frame |
| Emoji or placeholder art | The user's icons or the icon pack (`tools/icons_from_pack.py`) |
| A legend/notes box on top of the UI | Notes beside the artboard |

## 4. Compare side by side
Before calling a screen done, put a screenshot of it next to the main reference and list what still looks different. Fix the biggest difference, repeat once.
