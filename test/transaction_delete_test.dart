import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rhb_banking_prototype/payment/transactions_screen.dart';
import 'package:rhb_banking_prototype/payment/transaction_store.dart';

void main() {
  testWidgets('left swipe removes completed and sample rows and persists deletion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TransactionStore.instance;
    store.value = [];
    store.deletedSamples.clear();
    final record = PaymentTransaction.create(name: 'Latest Recipient', amount: '12.00', resident: true, details: '');
    await store.add(record);
    await tester.pumpWidget(const MaterialApp(home: TransactionsScreen()));
    await tester.pumpAndSettle();
    final completed = find.byKey(ValueKey('transaction-${record.reference}'));
    await tester.drag(completed, const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('Latest Recipient'), findsNothing);
    expect(store.value, isEmpty);
    final sample = find.ancestor(of: find.text('AMIRUL SYAMIL'), matching: find.byType(Dismissible));
    await tester.drag(sample, const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('AMIRUL SYAMIL'), findsNothing);
    final restored = TransactionStore();
    await restored.load();
    expect(restored.value, isEmpty);
    expect(restored.deletedSamples.any((id) => id.contains('AMIRUL SYAMIL')), isTrue);
    expect(tester.takeException(), isNull);
  });
}
