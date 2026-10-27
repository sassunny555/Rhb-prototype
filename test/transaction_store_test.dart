import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rhb_banking_prototype/payment/transaction_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('persists history, avoids duplicate receipts and orders newest first', () async {
    SharedPreferences.setMockInitialValues({});
    final store = TransactionStore();
    PaymentTransaction record(String id, String date) => PaymentTransaction(reference: id, name: id, amount: '12.00', resident: true, details: '', createdAt: DateTime.parse(date));
    final first = record('old', '2026-10-26T12:00:00Z');
    final recent = record('recent', '2026-10-27T12:00:00Z');
    expect(await store.add(recent), isTrue);
    await store.add(first);
    await store.add(recent);
    final restored = TransactionStore();
    await restored.load();
    expect(restored.value.map((r) => r.reference), ['recent', 'old']);
    expect(restored.value.first.myt.hour, 20);
  });
}
