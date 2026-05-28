# Neovim Cheatsheet Generator

Generates a printable PDF cheatsheet of this Neovim config's keybindings.

## Files

| File              | Purpose                                                            |
|-------------------|--------------------------------------------------------------------|
| `CHEATSHEET.md`   | **The source.** Edit this — content, tables, sections, tips.       |
| `build.py`        | Wraps the rendered markdown in print CSS (layout, fonts, columns). |
| `build.sh`        | One-command pipeline: markdown → HTML → PDF.                        |
| `CHEATSHEET.pdf`  | The generated output (what you print).                             |

## Build

```sh
cd cheatsheet-generator
./build.sh        # (chmod +x build.sh the first time)
```

Output: `CHEATSHEET.pdf` in this directory.

**Requirements:** `node`/`npx` (provides `marked`), `python3`, and Google Chrome
at `/Applications/Google Chrome.app`. No packages are installed permanently —
`marked` runs via `npx`.

## Current layout

- A4 **landscape**, **2 columns** per sheet, ~6.3pt body font.
- Two sheets: **front** = config bindings, **back** = Vim basics reference.
  (Currently spills slightly to a 3rd page — fine for desk use.)

## Tuning

- **Content** (keys, descriptions, sections, tips): edit `CHEATSHEET.md`.
  - The line `<div style="page-break-after: always;"></div>` marks the
    front/back split. Keep exactly one of these.
- **Looks / page count**: edit the `CSS` block in `build.py`.
  - `font-size` on `body` is the main lever — smaller = fewer pages.
  - `column-count` on `.sheet` — 2 (side-by-side) or 3 (denser).
  - `@page { size: ... }` — `A4 landscape`, `A4 portrait`, `A3 landscape`, etc.
  - `column-fill: balance` (even columns) vs `auto` (fill top-down).

## Regenerating with Claude Code

Point Claude at this directory and say what to change (e.g. "add my new
`<leader>tt` mapping", "make it fit 2 pages", "switch to 3 columns"). Because
the source markdown and build pipeline already exist, Claude only edits + runs
`build.sh` — it does **not** need to re-scan the whole config or rebuild the
styling from scratch, so it's faster and cheaper than the first run.

If you've **changed your actual Neovim config**, tell Claude that too so it can
re-scan the relevant files and update the bindings before rebuilding.
