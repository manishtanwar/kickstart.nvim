#!/usr/bin/env python3
"""
Wrap a marked-generated HTML fragment in print-optimised CSS.

Pipeline (driven by build.sh):
  CHEATSHEET.md --(marked)--> .body.html --(this script)--> .full.html --(chrome)--> CHEATSHEET.pdf

Layout: A4 landscape, 2 columns. The document is split into "sheets" at the
page-break marker so the config lands on the front and Vim basics on the back.
Tune the numbers in CSS below (font-size is the main lever for page count).
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
body = open(os.path.join(HERE, ".body.html")).read()

# Split into "sheets" at page-break markers authored in the markdown.
# Zero markers => one continuous sheet (columns flow/balance across all pages,
# no forced page break). One marker => front/back split as before.
MARKER = '<div style="page-break-after: always;"></div>'
parts = body.split(MARKER)
assert len(parts) <= 2, f"expected at most 1 page-break marker, found {len(parts) - 1}"
sections = "".join(f'<section class="sheet">{p}</section>' for p in parts)

CSS = """
@page { size: A4 landscape; margin: 8mm 8mm; }
* { box-sizing: border-box; }
body {
  font-family: -apple-system, "Helvetica Neue", Arial, sans-serif;
  font-size: 6.3pt; line-height: 1.13; color: #1a1a1a; margin: 0;
  -webkit-print-color-adjust: exact; print-color-adjust: exact;
}
.sheet { column-count: 2; column-gap: 8mm; column-fill: balance; }
.sheet:not(:last-child) { break-after: page; }
h1 {
  column-span: all; font-size: 15pt; color: #1f6feb; margin: 0 0 2pt;
  border-bottom: 2.5px solid #1f6feb; padding-bottom: 2.5pt;
}
h1 + p { color: #5a6b7b; font-size: 6.8pt; margin: 0 0 4pt; column-span: all; }
h2 {
  font-size: 8pt; color: #0d3b66; margin: 5pt 0 1.5pt;
  border-bottom: 1px solid #cdd9e5; padding-bottom: 1.5pt;
  break-after: avoid; break-inside: avoid;
}
.sheet > h2:first-of-type { margin-top: 1pt; }
p { margin: 2.5pt 0; }
strong { color: #0d3b66; }
code {
  font-family: "SF Mono", "Menlo", Consolas, monospace;
  font-size: 5.9pt; background: #eef2f6; color: #b3266b;
  padding: 0.3pt 2pt; border-radius: 3px; white-space: nowrap;
}
table {
  border-collapse: collapse; width: 100%; margin: 1.5pt 0 4.5pt;
  break-inside: avoid;
}
th {
  background: #1f6feb; color: #fff; text-align: left;
  padding: 1.5pt 4.5pt; font-size: 6pt;
}
td { padding: 1.3pt 4.5pt; border-bottom: 1px solid #e3e8ee; vertical-align: top; }
tr:nth-child(even) td { background: #f6f9fc; }
td code, th code { background: #dde6f0; color: #0d3b66; }
blockquote {
  margin: 2.5pt 0; padding: 3pt 7pt; background: #fff8e6;
  border-left: 3px solid #f0b429; font-size: 6.9pt;
  break-inside: avoid; border-radius: 0 3px 3px 0;
}
blockquote p { margin: 0; }
hr { display: none; }
ul { margin: 2pt 0; padding-left: 13pt; }
li { margin: 0.8pt 0; }
"""

html = (
    '<!doctype html>\n<html><head><meta charset="utf-8">'
    f"<style>{CSS}</style></head>\n<body>{sections}</body></html>"
)

out = os.path.join(HERE, ".full.html")
open(out, "w").write(html)
print(f"wrote {out} ({len(html)} bytes); sheets: {len(parts)}")
