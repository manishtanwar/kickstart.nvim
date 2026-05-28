---
name: nvim-cheatsheet
description: Regenerate the printable Neovim keybinding cheatsheet PDF for this config. Use when the user wants to update, rebuild, or change the layout of their nvim cheatsheet, or after they change keybindings/plugins in this nvim config and want the printed reference refreshed.
---

# Neovim Cheatsheet

Regenerates `cheatsheet-generator/CHEATSHEET.pdf` — a printable keybinding reference for this Neovim config.

The pipeline already exists in `cheatsheet-generator/`. Do **not** rebuild it from scratch or duplicate it.

| File | Role |
|------|------|
| `cheatsheet-generator/CHEATSHEET.md` | Content source — edit for keys, descriptions, sections, tips |
| `cheatsheet-generator/build.py` | Print CSS / layout (font size, columns, page size) |
| `cheatsheet-generator/build.sh` | One-command pipeline: md → html → pdf |
| `cheatsheet-generator/README.md` | Full docs (build steps, tuning knobs) — read if unsure |

## Workflow

1. **Identify the change type:**
   - **Content edit** (add/remove/reword a binding, section, or tip) → edit `CHEATSHEET.md` only.
   - **Layout edit** (page count, font, columns, page size, colors) → edit the `CSS` block in `build.py`.
   - **Config changed** (user actually rebound keys / added plugins in nvim) → first re-scan the relevant config files under `lua/` and `init.lua`, update `CHEATSHEET.md` to match, then rebuild. Ask the user *what* changed so you scan only those files, not the whole config.

2. **Rebuild:**
   ```sh
   cd cheatsheet-generator && ./build.sh
   ```
   Requires `node`/`npx` (for `marked`), `python3`, and Google Chrome. Nothing is installed permanently.

3. **Verify:** read the generated PDF pages (Read tool with `pages:`) to confirm it rendered and the page count is what the user wanted. Report the page count.

## Rules & gotchas

- `CHEATSHEET.md` must contain **exactly one** `<div style="page-break-after: always;"></div>` marker — it splits front (config bindings) from back (Vim basics). Keep it.
- **Page count is driven by `font-size` on `body`** in `build.py` — smaller = fewer pages. `column-count` (2 = side-by-side, 3 = denser) and `@page { size: ... }` (`A4 landscape`, `A4 portrait`, `A3 landscape`) are the other levers.
- Current layout: A4 landscape, 2 columns, ~6.3pt, ~3 pages. This is the accepted baseline — don't change it unless asked.
- Document built-in plugin keys (Neogit status buffer, NvimTree, Telescope picker) as defaults unless the user has overridden them in config.
- Don't commit unless the user asks. The `.pdf` is currently untracked — confirm tracked-vs-gitignored with the user before committing.

See `cheatsheet-generator/README.md` for the full tuning reference.
