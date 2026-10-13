/// Utility functions for numeral normalization and parsing across locales.

/// Normalizes Eastern Arabic (٠-٩) and Persian (۰-۹) numerals to Western digits (0-9).
String normalizeArabicDigits(String input) {
  const easternArabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  String result = input;
  for (int i = 0; i < 10; i++) {
    result = result.replaceAll(easternArabic[i], i.toString());
    result = result.replaceAll(persian[i], i.toString());
  }
  return result;
}

/// Tries to parse any dynamic input as a [num], normalizing Eastern Arabic and Persian numerals.
num? tryParseNormalizedNum(dynamic input) {
  if (input == null) return null;
  final str = input.toString().trim();
  if (str.isEmpty) return null;
  final normalized = normalizeArabicDigits(str);
  return num.tryParse(normalized);
}
