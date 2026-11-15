#!/bin/sh
# Subsets Alexandria and Cairo to the ranges in tool/font_subset.json (Arabic,
# basic Latin and common punctuation) to cut the web's first load (SC-011).
#
# Usage: tool/subset_fonts.sh <directory with the ORIGINAL full .ttf files>
# Needs fonttools (`pip install fonttools`). The originals are the files in git
# history before the commit "perf(foundation): T101"; or download them from the
# Cairo and Alexandria projects. Output overwrites assets/fonts/.
set -eu
src="${1:?directory with the original full .ttf files}"
unicodes=$(python3 -c "import json;print(json.load(open('tool/font_subset.json'))['unicodes'])")
for name in $(python3 -c "import json;print(' '.join(json.load(open('tool/font_subset.json'))['fonts']))"); do
  pyftsubset "$src/$name.ttf" \
    --unicodes="$unicodes" \
    --layout-features='*' --notdef-outline \
    --name-IDs='*' --name-legacy --name-languages='*' \
    --no-hinting \
    --output-file="assets/fonts/$name.ttf"
  echo "$name: $(wc -c < "assets/fonts/$name.ttf") bytes"
done
