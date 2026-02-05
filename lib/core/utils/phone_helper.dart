class PhoneNumberHelper {
  /// Normalizes Egyptian phone numbers.
  /// Removes non-digits. If length is 11 and starts with '0', replaces '0' with '20'.
  static String normalize(String phone) {
    // Remove all non-digit characters (+, spaces, hyphens, etc.)
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    // If it's already 12 digits and starts with 20 (Egyptian with country code)
    if (digits.length == 12 && digits.startsWith('20')) {
      return digits;
    }

    // If it starts with 0 and has 11 digits (Standard Egyptian mobile: 01xxxxxxxxx)
    if (digits.length == 11 && digits.startsWith('0')) {
      return '2$digits';
    }

    // If it has 10 digits and starts with 1 (Missing leading 0, e.g., 1012345678)
    if (digits.length == 10 &&
        (digits.startsWith('1') || digits.startsWith('5'))) {
      return '20$digits';
    }

    return digits;
  }
}
