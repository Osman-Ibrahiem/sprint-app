# Font subsets

Alexandria (600, 700) and Cairo (400, 500, 600, 700) are **subset** to the Unicode ranges in
[`tool/font_subset.json`](../../tool/font_subset.json): basic Latin, Latin-1 punctuation, the Arabic
blocks (including presentation forms) and common punctuation. This takes the six files from
about 1 MB to about 0.37 MB (about 0.46 MB to about 0.19 MB gzip) for the web's first load
(SC-011, decision of 2026-11-11 in `docs/decisions.md`).

- Glyph shaping tables (GSUB and GPOS: initial, medial, final forms, ligatures, kerning) are kept
  (`--layout-features='*'`), and so are the font's name records and copyright notice. Hinting is
  dropped, which Flutter does not use.
- The weights and file names are unchanged, and no font was added or removed. The family names
  inside the files are unchanged: the Cairo and Alexandria licences (SIL OFL 1.1, see `OFL-*.txt`)
  declare no Reserved Font Name.
- **IBM Plex Mono is not subset.** Its licence reserves the name "Plex", and a modified version
  could not keep it. It is loaded on demand instead (`lib/core/fonts/deferred_fonts.dart`).
- `test/core/fonts/font_subset_test.dart` fails if the app's strings use a character outside the
  kept ranges, so new copy cannot silently fall back to another font. To add a range, edit
  `tool/font_subset.json`, re-run `tool/subset_fonts.sh` on the original files, and commit.
- Original full files: in git history before the subsetting commit.
