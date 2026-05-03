abstract final class ArabicTextUtils {
  /// Normalises Arabic text:
  /// • Removes tashkeel (diacritics) and tatweel
  /// • Unifies alef variants (أ إ آ → ا)
  /// • Converts taa marbuta (ة → ه)
  /// • Converts alef maqsoura (ى → ي)
  static String normalize(String input) {
    if (input.isEmpty) return '';
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  /// Returns true if [input] contains at least one Arabic character.
  static bool containsArabic(String input) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(input);
  }

  /// Collapses consecutive whitespace runs into a single space and trims.
  static String removeExtraSpaces(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
