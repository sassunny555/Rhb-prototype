import 'package:flutter/services.dart';

/// Banking keypad: each digit shifts the value by one decimal place.
class CentsInputFormatter extends TextInputFormatter {
  const CentsInputFormatter();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > 9) return oldValue;
    final padded = digits.padLeft(4, '0');
    final formatted =
        '${padded.substring(0, padded.length - 2)}.${padded.substring(padded.length - 2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
