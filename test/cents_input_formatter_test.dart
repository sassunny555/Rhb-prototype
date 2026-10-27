import 'package:flutter_test/flutter_test.dart';
import 'package:rhb_banking_prototype/payment/cents_input_formatter.dart';

void main() {
  const formatter = CentsInputFormatter();
  test('digits shift through cents to whole MYR', () {
    var value = const TextEditingValue(text: '00.00');
    final expected = ['00.06', '00.60', '06.00', '60.00'];
    final digits = ['6', '0', '0', '0'];
    for (var i = 0; i < digits.length; i++) {
      value = formatter.formatEditUpdate(
        value,
        TextEditingValue(text: '${value.text}${digits[i]}'),
      );
      expect(value.text, expected[i]);
      expect(value.selection.baseOffset, value.text.length);
    }
    value = formatter.formatEditUpdate(
      value,
      const TextEditingValue(text: '60.0'),
    );
    expect(value.text, '06.00');
    value = formatter.formatEditUpdate(value, TextEditingValue.empty);
    expect(value.text, '00.00');
  });
  test('supports replacement and formatted pastes within amount limit', () {
    expect(
      formatter
          .formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(text: '60'),
          )
          .text,
      '00.60',
    );
    expect(
      formatter
          .formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(text: '60.00'),
          )
          .text,
      '60.00',
    );
    const old = TextEditingValue(text: '9999999.99');
    expect(
      formatter.formatEditUpdate(
        old,
        const TextEditingValue(text: '9999999.999'),
      ),
      old,
    );
  });
}
