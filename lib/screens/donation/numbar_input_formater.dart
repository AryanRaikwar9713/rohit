import 'package:flutter/services.dart';

/// Allows only digits and a single decimal point.
/// - [decimalRange]: if non-null, limits digits after decimal to this many.
/// - [onInvalid]: called with the invalid substring when user tries to enter disallowed chars.
class NumberInputFormatter extends TextInputFormatter {
  final int? decimalRange;
  final void Function(String invalid)? onInvalid;

  NumberInputFormatter({this.decimalRange, this.onInvalid})
      : assert(decimalRange == null || decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;

    if (newText.isEmpty) return newValue;

    // quick reject: more than one dot
    final dotCount = '.'.allMatches(newText).length;
    if (dotCount > 1) {
      onInvalid?.call('.');
      return oldValue;
    }

    // allow digits and dot only
    final onlyValidChars = RegExp(r'^[0-9.]*$');
    if (!onlyValidChars.hasMatch(newText)) {
      final invalid = newText.replaceAll(RegExp(r'[0-9.]'), '');
      onInvalid?.call(invalid);
      return oldValue;
    }

    // if decimalRange is set, ensure fractional part length <= decimalRange
    if (decimalRange != null && newText.contains('.')) {
      final parts = newText.split('.');
      if (parts.length > 1 && parts[1].length > decimalRange!) {
        onInvalid?.call(parts[1].substring(decimalRange!)); // tell which extra part
        return oldValue;
      }
    }

    // Leading '.' -> allow (user can type ".5"); keep it as-is
    return newValue;
  }
}
