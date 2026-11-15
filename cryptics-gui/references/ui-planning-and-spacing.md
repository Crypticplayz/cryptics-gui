# UI planning, spacing & what attracts players

Read this before laying out ANY screen. A pretty component in a bad layout still looks amateur.

## 1. Plan before drawing (5 minutes, saves hours)
1. **Goal of the screen** in one sentence ("get the player to buy a luck potion").
2. **Hero / focal point** — exactly ONE thing the eye hits first (featured offer, big reward, primary button). Make it the biggest, brightest, most animated thing.
3. **List every element**, then group them: navigation (tabs), status (currency), content (grid), actions (buy/close).
4. **Reading order**: players scan Z-pattern — top-left → top-right → down to content → bottom-right action. Put currency top, hero high, primary action where the eye ends.
5. **Sketch zones** with grey boxes first, check spacing, then style.

## 2. Spacing system (8-point grid)
- Only use: **4, 8, 12, 16, 24, 32, 48, 64**.
- Window inner padding: **32**. Section gap: **24**. Card gap: **16**. Inside a card: **12**. Icon↔label: **8**.
- **Proximity rule**: things that belong together are closer (8–12) than things that don't (24+). Gap between groups ≥ 2× the gap inside a group.
- Align everything to shared edges (left edge of tabs = left edge of grid). No random offsets.
- Leave breathing room: ~20–30% of a window should be "empty" (padding, gaps). Crowded = cheap.
- Corner radius scale: window 32 → panel 24 → card 20 → button 16 → pill = full. Inner radius = outer radius − padding.

## 3. Hierarchy (size, color, motion)
- **3 text levels only**: Title 40–56 · Item name 22–26 · Meta/effect 14–16. Numbers (prices, currency) bold and big.
- **Color**: neutral surfaces (white/light blue), saturated color reserved for things that matter (rarity, buttons, badges). Primary action = brightest green; destructive = red; everything else calmer.
- **Motion** draws the eye most → only animate what you want clicked (hero, shop button badge, best deal).
- Contrast check: text on colored cards always has a black outline.

## 4. Roblox screen zones (HUD)
- **Top-left**: currencies (coin, gem) with "+" that opens the shop. Keep clear of the Roblox menu button (top-left 60px) — use ScreenInsets CoreUISafeInsets.
- **Left side, vertical stack**: menu buttons (Shop, Pets, Index, Rebirth, Daily, Settings). 72–96px squares, label under/on each, 12–16 gap.
- **Top-center**: active boosts/events (x2 Luck 09:59), server announcements.
- **Right side**: offers & free rewards (Free Gift timer, Starter Pack, playtime rewards), quests.
- **Bottom-center**: keep clear for gameplay; contextual prompts only. **Bottom-left/right** = mobile joystick/jump → no buttons there.
- Mobile: tap targets ≥ 60px, test at 844×390.

## 5. The "Open" button (menu button) — make it irresistible
- Big square 3D button with a **chunky icon that overflows the top edge** a little, label pill at the bottom ("SHOP").
- **Notification badge**: red circle top-right with a number or "!" when there's something new/free.
- Idle animation: gentle **wiggle/bounce every 4–6 s**, a **shine sweep** across it, sparkle twinkle — only on the button that matters most (Shop / Free Gift).
- Hover 1.08 scale, press 0.92, then window opens with Back easing.
- Order buttons by importance top→bottom; the shop is usually first or highlighted in gold.

## 6. Shop layout that sells (keep it honest)
- **Vertical tab rail on the left** (Featured ⭐, categories, Robux) frees width for the grid; selected tab gold + glow.
- **Featured / Limited offer hero** at the top: big item art on a **rotating sunburst**, sparkles, title, what's inside, **real** countdown timer, old price struck through + new price, "-66%" badge, huge BUY button.
- **Grid** below with a small section title; 4 columns on desktop, cards same size.
- **Badges** on cards: HOT (red), NEW (blue), BEST VALUE (gold), LIMITED (purple). Max 1 badge per card, max ~3 per screen.
- **States**: owned (gray button "OWNED" + check), locked (dark overlay + lock + requirement), can't afford (button stays green, shows "Need 2K more" on click).
- **Value anchoring**: show bundles next to singles; mark the best one.
- **Free thing in the shop** (daily free potion) → brings players into the shop every day.
- Feedback on buy: confetti/sparkle burst, coin counter tween down, card pop.
- Honesty rules: real timers only, real discounts only, Robux prices clearly labeled. No fake scarcity.

## 7. Visual effects kit (white PNGs from ui-resources.com, tint in Roblox with ImageColor3)
| Effect | Where | Motion in Roblox |
|---|---|---|
| Sunburst (rays/swirl) | behind featured item, legendary/mythic icons, reward reveals | rotate 360° every 10–20 s (TweenService, Linear, repeat -1) |
| Sparkle / 4-point star | corners of rare cards, shop button, hero | twinkle: scale 0↔1 + transparency, random delay |
| Lens shine | on gems, coins, glass | pulse transparency |
| Diagonal shine streaks | across buttons/cards | sweep left→right every 3 s (UIGradient Offset tween) |
| Halftone dots | card corners, panel backgrounds | static, 15–35% |
| Glow | behind selected tab/card, hero | slow pulse |
| Confetti / burst | purchase, hatch, level up | one-shot |
Rule: effects support the hierarchy — strongest effects on the hero, light effects on rares, none on commons.

## 8. Final layout checklist
- [ ] One clear hero; one primary action per area
- [ ] All spacing from the 8-pt scale, groups separated ≥ 2× inner gap
- [ ] Edges aligned, consistent radii
- [ ] Text levels ≤ 3, every colored text outlined
- [ ] Currency visible while shopping
- [ ] Badges ≤ 3 visible, timers real
- [ ] Works at phone size, nothing in joystick/jump zones
