# Wiring real purchases (Robux + in-game currency)

Skill Made By : Crypticplay_RBLX - Only on Youtube

A shop that looks amazing but doesn't take Robux is a mockup. This is how the skill turns it into a working shop. The rule that never bends: **the client never decides what a player owns.** It only asks Roblox to show a purchase prompt, or asks the server to spend currency. The server checks everything.

## Files
| File | Goes to | Does |
|---|---|---|
| `assets/Purchases.server.lua` | ServerScriptService (Script) | ProcessReceipt (grant once per PurchaseId), gamepass ownership → `Pass_<id>` attribute, server-validated currency purchases |
| `assets/UIKit.lua` | ReplicatedStorage | `UIKit.buyProduct(id)`, `UIKit.buyPass(id)`, `UIKit.buyWithCurrency(itemId)`, `UIKit.watchPass(id, onOwned)` |

## Steps
1. Ask the user for every product, pass and currency item on the screen: name, type (developer product / gamepass / currency), price, what it gives. Never invent product ids. The user creates products and passes on the Creator Dashboard (Monetization → Developer Products / Passes) and sends the ids.
2. Fill `PRODUCTS`, `PASSES`, `SHOP_ITEMS` in `Purchases.server.lua`, and point the `Economy` functions at the game's real data (leaderstats is only the example). If the game uses ProfileStore or another data layer, write the grant through it so it's saved.
3. Install with `execute_luau`: create the Script in ServerScriptService with the file as Source (and UIKit / UIEffects in ReplicatedStorage).
4. Wire the buttons in the controller LocalScript:
   ```lua
   local UI = require(game.ReplicatedStorage.UIKit)
   UI.button(shop.Btn_BuyStarter, { onClick = function() UI.buyProduct(1234567) end })
   UI.button(shop.Card_VIP.Btn_Buy, { onClick = function() UI.buyPass(7654321) end })
   UI.watchPass(7654321, function() swapToOwned(shop.Card_VIP) end)   -- gray OWNED PNG + check
   UI.button(shop.Card_Potion.Btn_Buy, { onClick = function()
       local ok, msg = UI.buyWithCurrency("luck_potion")
       showToast(msg)                                                  -- "Need 1,200 more Coins"
   end })
   ```
5. States come from exported PNGs (rule 3): `Btn_Green` (buy), `Btn_Gray` + check (OWNED), dark overlay + lock (LOCKED). Swap the `Bg` image; never recolour with frames.
6. Test: the place must be published and **Studio API access** enabled (Game Settings → Security) for prompts in Studio. Studio purchases are free test purchases. Check the Output for `Purchases:` warnings.

## Rules
- Prices on buttons are TextLabels filled from the same table the server uses, so the label can't disagree with the charge.
- "Can't afford" keeps the button green; clicking shows "Need X more" (from the server's reply).
- Honest shop (ui-planning-and-spacing.md §6): real timers, real discounts, Robux prices clearly labelled.
- Never trust a price, item id or amount sent by the client beyond looking it up in the server's table.
- `ProcessReceipt` returns `NotProcessedYet` whenever the grant failed or the player left, so Roblox retries and nobody pays for nothing.
