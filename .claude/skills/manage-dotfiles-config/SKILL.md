---
name: manage-dotfiles-config
description: Safely edit tool config files in this dotfiles repo (Zed, Neovim, Ghostty, Yazi, tmux, lazygit, etc.) by looking up real current docs for exact option/keybind/action names instead of guessing, then validating per file format. Use when changing editor or terminal settings or keybindings, adding/remapping a shortcut, toggling a panel/dock, or whenever the user references a config file like keymap.json, settings.json, init.lua, config.toml, or asks "what's the action/option for X in <tool>".
user-invokable: true
---

# manage-dotfiles-config

Edit machine config in `~/dotfiles` without guessing. Three rules: **look up the real
option/action name, make the edit, validate before declaring done.** Never invent a
config key or action identifier from memory — they drift between versions.

## Workflow

1. **Locate** the file in the Tool catalog below (paths are stow-managed in `~/dotfiles`).
2. **Look up** the exact key/action/option via the `find-docs` skill (Context7) — see
   "Docs lookup" per tool. Don't guess identifiers like `editor::GoToDefinition` or a
   settings key; confirm them against current docs.
3. **Edit** the file (preserve the surrounding comment/idiom style).
4. **Validate**: `bash scripts/validate-config.sh <file>` (auto-detects format). Fix until ✓.
5. **Check the Gotchas catalog** for the tool before finishing.

## Tool catalog

| Tool | Config path(s) | Format | Docs lookup (find-docs) |
|------|----------------|--------|-------------------------|
| Zed | `~/.config/zed/keymap.json`, `settings.json` | JSONC | lib `/websites/zed_dev` — query for action ids / setting keys |
| Neovim (LazyVim) | `~/.config/nvim/lua/**` | Lua | `ctx7 library "Neovim"` / `"LazyVim"` |
| Ghostty | `~/.config/ghostty/config` | key=value | `ctx7 library "Ghostty"` |
| Yazi | `~/.config/yazi/keymap.toml`, `yazi.toml` | TOML | `ctx7 library "Yazi"` |
| tmux | `~/.tmux.conf` | tmux conf | `ctx7 library "tmux"` |
| lazygit | `~/.config/lazygit/config.yml` | YAML | `ctx7 library "lazygit"` |

Add new tools as rows here; add their quirks to Gotchas.

## Gotchas catalog

### Zed
- `keymap.json` / `settings.json` are **JSONC** (comments + sometimes trailing commas).
  Plain `jq` / `JSON.parse` chokes on `//` comments — use `validate-config.sh` (it strips
  comments first). Keymap is an array of `{ "context"?, "bindings" }` blocks; chords are
  space-separated, e.g. `"cmd-g cmd-d"`.
- **Dock-toggle keybinds depend on which dock a panel is assigned**, set in `settings.json`.
  Each panel (`agent`, `project_panel`, `outline_panel`, `git_panel`, …) has a
  `"dock": "left" | "right" | "bottom"`. `workspace::ToggleLeftDock` /
  `ToggleRightDock` toggle *whatever panel lives in that dock*, not a named panel. **Always
  read the panel `dock` values before binding a dock toggle.** In this repo: `agent` is
  left-docked, `project_panel` (file tree) is right-docked → `cmd-b` =
  `workspace::ToggleRightDock` (file tree), `cmd-j` = `workspace::ToggleLeftDock` (AI panel).
- Prefer `workspace::Toggle{Left,Right}Dock` for clean open/close. `*::ToggleFocus` only
  moves focus (won't reliably close a panel), which feels like a broken toggle.
- Zed applies config on save — no restart needed to test.

### (add other tools' gotchas as you hit them)

## Notes

- These configs are symlinked from `~/dotfiles` via stow, and `~/.claude` itself symlinks
  into the repo. Editing the real file under `~/.config/...` edits the repo copy.
- Commit per concern (keybinds vs theme are separate commits). To mirror a change onto
  another branch, cherry-pick the specific commit rather than merging.
- See [scripts/validate-config.sh](scripts/validate-config.sh) for the validator.
