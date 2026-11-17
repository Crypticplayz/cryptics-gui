# Cryptic's GUI: a Claude skill for Roblox GUI

**Skill Made By : Crypticplay_RBLX - Only on Youtube**

A skill for Claude that designs **front-page-quality Roblox UI** (HUD, shop, inventory, egg hatch, index, gamepasses, popups) in Figma or an HTML design board and exports them as PNGs, instead of default gray frames. Then it imports the images into Roblox Studio and puts the UI together for you. It never "designs" with plain Studio frames: every look comes from the images.

## What it does
1. Asks which style you want: Cartoony, Stud, Anime Glow, Clean Modern, Glass, Pixel, Sci-Fi Neon, Fantasy, Horror, Candy Pastel, Military Metal, or your own reference screenshot.
2. Plans the layout and locks the style on one screen. You approve it before it builds the rest.
3. Builds reusable pieces (buttons, cards, headers, tabs, currency pills) and then all your screens.
4. Exports PNGs, imports them into Studio and assembles the ScreenGui with scale, 9-slice and mobile rules, plus animated effects (glow, shine, sparkles, bounce).

Built-in rules: black 3D lips and outlines, nothing cut off or overlapping, proper padding, readable on phones, real TextLabels for changing numbers, and the same rarity colors everywhere.

## Get the skill
Go to **[Releases](../../releases/latest)** and download **`cryptics-gui.zip`**.

## Install

**Claude Code:** copy the `cryptics-gui` folder into your skills folder:
- Windows: `C:\Users\<you>\.claude\skills\`
- Mac/Linux: `~/.claude/skills/`

**Claude.ai / Claude desktop:** zip the `cryptics-gui` folder and upload `cryptics-gui.zip` under Settings → Capabilities → Skills.

## Downloads
The first time you use it, the skill thanks the creators and:
- asks you to download **[gvesster's Free Icon Pack](https://gvesster.itch.io/free-icon-pack)** (or use your own icons)
- downloads the stud textures and glow/sparkle images from [UI Resources](https://ui-resources.com) for you

## Works best with
- The **Figma MCP** (for the Figma path; without it the skill makes an HTML design board)
- The **Roblox Studio MCP** (so it can import and assemble the UI in your game; without it you get the PNGs and the steps)
- Optional: the **roblox-sfx** skill (UI sounds) and the **roblox-vfx** skill (textures for hatch/reward effects)

## Use it
Type **`/cryptics-gui`** for the full guided flow, or just ask Claude something like *"make a shop UI for my pet simulator"*.

## Commands
| Command | What it does |
|---|---|
| `/cryptics-gui` | Full guided flow: credits → style → screens → export → import into Studio |
| `/cryptics-gui help` | Show this list of commands |
| `/cryptics-gui credits` | Show the creator credits and the download list again |
| `/cryptics-gui styles` | Show the 12-style menu with a short description of each look |
| `/cryptics-gui refs` | Find real reference UIs and break down what makes them work, before designing |
| `/cryptics-gui content` | Fill the content sheets (pets, shop, currencies, labels) used by the design and the game |
| `/cryptics-gui hud` | HUD: currency pills, stat pill, side menu buttons with badges |
| `/cryptics-gui shop` | Shop window: tabs, item cards, price buttons, hero deal |
| `/cryptics-gui inventory` | Inventory / pets: grid, rarity cards, Equip Best, Delete Mode |
| `/cryptics-gui hatch` | Egg hatch / reward reveal overlay with rays and rarity banner |
| `/cryptics-gui index` | Index / collection book with silhouettes and completion bar |
| `/cryptics-gui gamepass` | Gamepass / Robux store with BEST VALUE ribbon |
| `/cryptics-gui daily` | Daily rewards, playtime rewards or spin wheel |
| `/cryptics-gui popup` | Popups: region unlock, toasts, server announcements |
| `/cryptics-gui settings` | Settings: toggles, codes box + Redeem |
| `/cryptics-gui kit` | Full UI kit: buttons, cards, headers, tabs, pills, close X in the locked style |
| `/cryptics-gui restyle` | Change an existing design to a different style |
| `/cryptics-gui polish` | Check and fix an existing UI: clipping, overlaps, padding, black lips, phone size |
| `/cryptics-gui export` | Export PNGs from an existing Figma file or HTML board |
| `/cryptics-gui import` | Import the exported PNGs into Roblox Studio and assemble them (images only) |
| `/cryptics-gui effects` | Add the animations (Bounce, Glow, Shine, Sparkles, Ring, Spin) to an assembled UI |
| `/cryptics-gui audit` | Automatic check of the UI in Studio: sizes, phone tap targets, text fit, clipping, overlaps, off-screen |
| `/cryptics-gui wire` | Make the UI work: windows, tabs, buttons, data-driven grids, formatted numbers (UIKit) |
| `/cryptics-gui purchases` | Real Robux products, gamepasses and in-game currency buys, checked on the server |
| `/cryptics-gui sounds` | A sound on every button, window and purchase (with the roblox-sfx skill) |
| `/cryptics-gui gamepad` | Console / controller support: selection ring, focus, B to close |

## What's new in v2.2
- **No more fake values**: pet names, powers, prices and product ids come from simple spreadsheets you fill in (`/cryptics-gui content`). Anything you haven't filled in shows as a labelled text holder, and the game, the design and the purchase server all use the same numbers.
- **Designs start from real references**: the skill finds real Roblox UIs first (yours, Figma Community, DevForum), lays the screen out in grey boxes, then styles it, and runs an "AI-slop" check before showing anything (`/cryptics-gui refs`).
- **Icons from your icon pack**: one command copies the right icons out of gvesster's Free Icon Pack download.
- **AuditUI**: one command checks an assembled UI in Studio against every rule and lists what to fix.
- **UIKit**: assembles your exported PNGs the same way every time: windows that open/close, tabs, buttons with bounce + sound, grids built from data (smooth with hundreds of pets), 1.2K / 3.4M number formats, timers, flipbook effects.
- **Real purchases**: `Purchases.server.lua` handles Robux products, gamepasses (OWNED state) and coin purchases safely on the server.
- **UI sounds** (roblox-sfx skill), **reward/hatch effects** (flipbooks, roblox-vfx textures), **console/gamepad support**, **colour-blind safe rarities** and **Reduce Motion**.
- **New templates**: cartoony HUD, cartoony inventory and an Anime Glow shop for the HTML board.
- **Tests**: test prompts (`evals/`) and a Studio self-test (`tests/selftest.lua`).
- `LOCAL.md` keeps your own settings (icon folder, Figma plan) out of the shared files.
- Fixes: Glow now draws behind buttons, Shine no longer clips them, effects clean themselves up, Bounce works on touch, and contradicting rules were cleaned up.

## Credits
Huge thanks to everyone whose free resources this skill uses. See **[CREDITS.md](CREDITS.md)**.

## Official version
The official skill is free and only shared by **Crypticplay_RBLX** (YouTube / Discord). If you got it from a re-upload, a paywall or a "sub to unlock" page, or the credit line was changed, it isn't the official version. `CHECKSUMS.txt` lets you check that the files weren't modified.

## License
**Free to use.** Use it yourself and use the UI you make in your own games, even paid ones. Share the official link, but **don't** re-upload, sell or paywall the skill, or claim it as yours, and the credit line has to stay. Full terms are in [LICENSE](LICENSE). Other creators' assets keep their own licenses (see CREDITS.md).
