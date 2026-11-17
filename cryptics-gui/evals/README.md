# Testing Cryptic's GUI

Skill Made By : Crypticplay_RBLX - Only on Youtube

Two kinds of tests. Run both after every change to the skill.

## 1. Skill tests — `evals/evals.json`
Ten prompts with yes/no expectations (credits first, black lips, 5 vs 4 columns, rule 3, real purchases, audit, the credit line, no invented content, reference-first + slop check). Run them with the **skill-creator** skill: ask Claude *"run the evals for cryptics-gui"*. A failing expectation means a rule in SKILL.md is unclear or contradicted somewhere — fix the text, then re-run.

## 2. Studio self-test — `tests/selftest.lua`
Proves the Luau code works and that the audit can actually fail:
1. Open any place in Studio (edit mode) with the Roblox Studio MCP connected.
2. Install `assets/UIKit.lua` as `ReplicatedStorage.UIKit` and `assets/AuditUI.lua` as `ServerStorage.CrypticsAudit`.
3. Run `tests/selftest.lua` with `execute_luau`. If the output is empty (the script yields), read `ServerStorage.__CrypticsTest.Value` in a second call.
4. Every line should say PASS. It checks number/time formatting, that AuditUI catches 8 kinds of broken UI, that a clean UIKit window has 0 errors, and that a 500-item grid only builds the visible rows.

The test builds throwaway ScreenGuis named `__AuditBad`, `__AuditGood`, `__GridTest` under StarterGui and deletes them. Don't run it in a place you haven't saved.
