#!/usr/bin/env bash
# Build CHEATSHEET.pdf from CHEATSHEET.md.
#
# Requires: node/npx (for `marked`), python3, and Google Chrome.
# Usage:    ./build.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

echo "1/3  markdown -> html fragment (marked)"
npx -y marked@latest --gfm -i "$DIR/CHEATSHEET.md" -o "$DIR/.body.html"

echo "2/3  wrap in print CSS (build.py)"
python3 "$DIR/build.py"

echo "3/3  html -> pdf (headless chrome)"
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$DIR/CHEATSHEET.pdf" \
  "file://$DIR/.full.html" 2>/dev/null

# Clean up intermediates (comment out to inspect them).
rm -f "$DIR/.body.html" "$DIR/.full.html"

echo "done -> $DIR/CHEATSHEET.pdf"
