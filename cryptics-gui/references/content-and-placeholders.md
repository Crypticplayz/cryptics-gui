# Content sheets and text holders — never invent values

Skill Made By : Crypticplay_RBLX - Only on Youtube

Pet names, powers, prices, product ids, timers and currency amounts are the GAME's data, not the designer's. The skill never makes them up. They live in spreadsheets the user fills in, and every screen — the design board, the Roblox UI and the purchase server — reads the same numbers.

## The sheets (`assets/content/`, CSV — open in Excel or Google Sheets, save as CSV)
| Sheet | Columns | Used for |
|---|---|---|
| `currencies.csv` | id, name, icon, amount | currency pills (amount = what the mockup shows; the game uses live data) |
| `pets.csv` | id, name, rarity, power, icon, tags, equipped, locked | inventory / index cards, details panel |
| `shop.csv` | id, section, name, description, price, currency, old_price, product_id, pass_id, gives, badge, icon, ends_in_seconds, rarity | shop hero + cards, purchase server |
| `boosts.csv` | id, name, icon, multiplier, seconds_left | HUD boost chips, offer timers |
| `text.csv` | key, text | every label and button (pre-filled with plain UI words; edit or translate) |

Rules for the cells:
- `rarity` = Common / Uncommon / Rare / Epic / Legendary / Mythic / Secret.
- Numbers may be written `125000`, `125,000` or `125k` / `1.5m`.
- `currency` = `robux` or an id from currencies.csv. A Robux row needs a `product_id` (developer product) or `pass_id` (gamepass) from Creator Dashboard → Monetization.
- `section` groups shop rows: `featured` (hero), `passes`, `potions`… — templates pick rows with `data-where="section=passes"`.
- `icon` = an icon file name without `.png` (e.g. `pet_cat_gold`, from `tools/icons_from_pack.py` or the user's own folder).
- `gives` (optional) = `<currency id>:<amount>` (e.g. `coins:5000`) and the purchase server grants it automatically; anything else needs a GRANTS handler.
- Empty cell = not decided yet. Leave it empty — don't guess.

## Workflow
1. Copy `assets/content/` into the working folder (e.g. `ui-board/content/`). Ask the user for the real rows — or for the game's existing data (a pets module, a shop config) and convert it. **Never fill rows yourself.**
2. Build: `python tools/build_content.py ui-board/content ui-board` → `content.json` (board) + `UIContent.lua` (Roblox). It lists empty cells and refuses bad rows (unknown rarity, text in a number column, Robux item without an id).
3. The board shows real values where they exist and a **text holder** (dashed box with the field name, e.g. `PET NAME`, `PRICE`) where they don't. Text holders never get baked into PNGs (export hides them; text is a TextLabel anyway).
4. Roblox: install `UIContent.lua` as `ReplicatedStorage.UIContent`. `UIKit.content()` / `UIKit.text(key)` read it; `Purchases.server.lua` takes prices and product/pass ids from it, so a button can't show a different price than the server charges.
5. When the data changes: edit the CSV → rebuild → re-run `/cryptics-gui import` for text only (no new PNGs needed).

## Binding a board (for new templates)
`assets/templates/content.js` fills the board:
```html
<span data-bind="text.title_shop" data-ph="TITLE"></span>
<span data-bind="currencies.coins.amount" data-format="abbrev" data-ph="COINS"></span>
<div data-repeat="pets" data-count="15" data-class="rarity">     <!-- one card per row, 15 slots -->
  <img data-src="icon"> <b data-field="name" data-ph="PET NAME"></b>
  <i data-field="power" data-format="abbrev" data-ph="POWER"></i>
  <img src="assets/icons/check.png" data-if="equipped">
</div>
<div data-repeat="shop" data-where="section=passes" data-count="3">…</div>
```
Formats: `abbrev` (1.23K, 4.5M), `commas` (12,500), `time` (9:59, 1:02:03, 2d 4h). `data-bind-class` adds a bound value as a class (e.g. the selected pet's rarity colour).
