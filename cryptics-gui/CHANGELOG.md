# Changelog

Skill Made By : Crypticplay_RBLX - Only on Youtube

## 2.2.0
**New**
- `assets/AuditUI.lua` + `/cryptics-gui audit`: automatic Studio check of an assembled UI — Scale vs Offset, missing UIAspectRatioConstraint, tap targets and text size estimated on an 844×390 phone, text that doesn't fit, empty images, empty 9-slice centres, clipped children, edge gaps (rule 13c), accidental overlaps (rule 13), off-screen pieces, mobile thumb zones, Roblox menu area, close X position, native styling (rule 3). Runs at the end of every import.
- `assets/UIKit.lua` + `/cryptics-gui wire`: assembles exported PNGs (piece / icon / label with the same margin maths as the import guide), windows (dim, blur, Back-eased open/close, one open at a time, B/Esc closes, gamepad focus), tabs (selected PNG swap + Glow), buttons (Bounce + sound + debounce), stroke scaling, `abbrev` / `commas` / `time` formatting, a virtualized data grid, flipbooks, rarity table with label + symbol, Reduce Motion.
- `assets/Purchases.server.lua` + `references/purchases.md` + `/cryptics-gui purchases`: ProcessReceipt that grants once per PurchaseId, gamepass ownership → `Pass_<id>` attribute, server-validated in-game currency purchases with refund on failure.
- `references/ui-sounds.md` + `assets/ui-sounds.spec.json` + `/cryptics-gui sounds`: UI sound roles for the roblox-sfx skill.
- `references/reward-vfx.md`: hatch/reward effects (UIEffects, flipbooks from roblox-vfx textures, world-space VFX), hatch timing table.
- `references/input-and-accessibility.md` + `/cryptics-gui gamepad`: console/gamepad, data-driven grids, number formats, colour-blind rarity, Reduce Motion, room for translations.
- Templates: `cartoony-hud.html` (with a thumb-zone overlay, press Z), `cartoony-inventory.html`, `anime-glow-shop.html`. `export.js` gained a generic mode (`data-piece`, `data-margin`, `data-origin`) used by all new templates; the shop template still works as before.
- `LOCAL.template.md`: machine-specific settings (icon folder, Figma plan, screenshot scale) live in `LOCAL.md`, never in the shared files.
- Tests: `evals/evals.json` (8 prompts with expectations for the skill-creator skill) and `tests/selftest.lua` (Studio self-test: formatting, every audit check can fail, a clean UIKit window passes, grid virtualization).

**Fixed**
- UIEffects `Glow` drew on top of its button (children always draw above their parent with Sibling ZIndex): it is now a sibling behind the button that follows its position, size, rotation and visibility.
- UIEffects `Shine` set ClipsDescendants on the button, clipping the black lip, the glow and the sparkles: it now uses its own rounded CanvasGroup mask.
- Every effect now cleans itself up when its target is destroyed (no leaked RenderStepped loops); cleanups are safe to call twice; Ring/Shine cancel their running tween.
- Bounce no longer sticks at 1.07 after a tap on touch screens.
- Contradicting rules: the Cartoony palette's "dark shade" column is for 3D text only (lips are always black); the Stud recipe no longer says "or draw your own studs" or "darker shade" lip; Figma font is Fredoka Bold (Figma has no Fredoka One); grid columns are 5 for inventory/index and 4 for shop cards everywhere; the menu is 11 styles + Mix.
- Quality bar: tap targets ≥ 44 px on the phone (≈ 120 px at 1920×1080), checked by AuditUI.

## 2.1.0
- Commands (`/cryptics-gui help`, `hud`, `shop`, …), credits + downloads start message, Studio = import + assembly only.
