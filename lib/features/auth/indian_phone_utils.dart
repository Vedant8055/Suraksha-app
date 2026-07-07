import 'package:flutter/services.dart';

/// Formats Indian mobile numbers as `+91 70200 94073`.
class IndianPhoneUtils {
  IndianPhoneUtils._();

  static const String countryPrefix = '+91 ';

  /// Ten-digit national mobile number (no country code).
  static String nationalDigits(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits == '91') {
      return '';
    }
    if (digits.startsWith('91') && digits.length > 2) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    return digits;
  }

  /// Display string with +91, space, and 5+5 grouping. Empty when no digits.
  static String formatDisplay(String input) {
    final national = nationalDigits(input);
    if (national.isEmpty) return '';

    final first = national.length <= 5
        ? national
        : national.substring(0, 5);
    final second = national.length <= 5 ? '' : national.substring(5);

    if (second.isEmpty) return '$countryPrefix$first';
    return '$countryPrefix$first $second';
  }

  /// Value sent to backend (10-digit national number).
  static String forApi(String input) => nationalDigits(input);

  /// Cursor position after formatting based on national digit count.
  static int cursorOffsetForNationalLength(int nationalLength) {
    if (nationalLength <= 0) return 0;
    if (nationalLength <= 5) return countryPrefix.length + nationalLength;
    return countryPrefix.length + 5 + 1 + (nationalLength - 5);
  }
}

class IndianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldNational = IndianPhoneUtils.nationalDigits(oldValue.text);
    final newNational = IndianPhoneUtils.nationalDigits(newValue.text);

    if (newNational.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = IndianPhoneUtils.formatDisplay(newValue.text);
    final isDeleting = newNational.length < oldNational.length;
    final cursorOffset = isDeleting
        ? IndianPhoneUtils.cursorOffsetForNationalLength(newNational.length)
        : formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, formatted.length),
      ),
    );
  }
}
