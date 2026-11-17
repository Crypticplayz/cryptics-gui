# UI sounds — every button makes a sound

Skill Made By : Crypticplay_RBLX - Only on Youtube

Silent UI feels broken. Every button, tab, window and purchase gets a short sound. This skill does not upload audio: it uses the **roblox-sfx** skill (free Creator Store sounds by asset id, each one proven to load in Studio before it's chosen).

## The roles
`assets/ui-sounds.spec.json` lists one role per UI event. UIKit plays them automatically:

| Role | Played by | Feel |
|---|---|---|
| `ui_click` | every `UIKit.button` | short, crisp pop (< 0.6 s) |
| `ui_hover` | mouse enters a button (desktop only) | very quiet tick |
| `tab_switch` | `UIKit.tabs` | soft swipe |
| `window_open` / `window_close` | `UIKit.window` | whoosh/pop, close slightly quieter |
| `purchase_success` / `purchase_fail` | `UIKit.buyWithCurrency`, `UIKit.watchPass` | cash register / gentle error |
| `reward_claim` | your claim button (`UIKit.sound("reward_claim")`) | chime + sparkle |
| `rare_hatch` | hatch reveal for Legendary+ | short fanfare |
| `notification` | badge appears / toast | ding |

## Steps
1. If the **roblox-sfx** skill is installed, run its pipeline with this spec:
   ```bash
   python <roblox-sfx>/scripts/find_sfx.py spec <cryptics-gui>/assets/ui-sounds.spec.json --out work/candidates.json --per-role 5
   ```
   then its probe → report → pick → emit_bank steps (they prove each sound in Studio). Install the emitted `Sfx` module as `ReplicatedStorage.Sfx` and the `SoundBank` next to it.
2. If roblox-sfx isn't installed, ask the user for sound ids per role (or skip): build `ReplicatedStorage.Sfx` as a ModuleScript with `play(role, parent)` that clones a Sound from a table of ids.
3. UIKit finds `ReplicatedStorage.Sfx` on its own. No Sfx module = silent, never an error.
4. Play the tour (roblox-sfx `tour.lua`) so the user hears every UI sound before calling it done.

## Rules
- Volume: hover ≤ 0.25, clicks ~0.5, rewards/hatch the loudest. UI never drowns the game.
- One sound per action; don't stack click + open on the same press (UIKit's window open plays only `window_open` when opened by a button that has `sound = false`).
- Respect the player: a Settings toggle for SFX should mute the `SFX` SoundGroup the Sfx module uses.
