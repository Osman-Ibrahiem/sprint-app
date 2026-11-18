/// Folds Arabic and Latin text to one searchable form (FR-014): tashkeel is
/// dropped, the alef forms become bare alef, ta marbuta becomes ha, alef
/// maqsura becomes ya, Latin is lowercased and runs of spaces collapse.
class ArabicNormalizer {
  const ArabicNormalizer._();

  static final RegExp _tashkeel = RegExp(
    '[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]',
  );
  static final RegExp _spaces = RegExp(r'\s+');

  static String normalize(String text) => text
      .replaceAll(_tashkeel, '')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .toLowerCase()
      .replaceAll(_spaces, ' ')
      .trim();

  static bool contains(String haystack, String needle) =>
      normalize(haystack).contains(normalize(needle));
}
