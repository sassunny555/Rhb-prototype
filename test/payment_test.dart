import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rhb_banking_prototype/payment/transaction_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhb_banking_prototype/payment/payment_screen.dart';
import 'package:rhb_banking_prototype/payment/recipient.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TransactionStore.instance.value = [];
  });
  testWidgets(
    'payment details starts at zero and reviews amount before demo receipt',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentScreen(
            recipient: Recipient(
              name: 'Brooklyn Simmons',
              amount: '99.00',
              source: 'Camera OCR',
            ),
          ),
        ),
      );
      expect(find.text('Brooklyn Simmons'), findsOneWidget);
      expect(find.text('00.00'), findsOneWidget);
      expect(find.text('Savings Pro Account-i'), findsOneWidget);
      expect(find.text('MYR 388.20'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Enter an amount greater than 00.00.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('payment-amount')), '38.20');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Resident'), findsOneWidget);
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();
      expect(find.text('38.20'), findsOneWidget);
      await tester.tap(find.text('Non-Resident'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Non-Resident'), findsOneWidget);
      await tester.tap(find.text('Approve'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Successful'), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Brooklyn Simmons'), findsOneWidget);
      expect(find.text('MYR 38.20'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Successful'), findsOneWidget);
      expect(find.text('Non-Resident'), findsOneWidget);
      expect(find.text('Share Receipt'), findsOneWidget);
      expect(find.text('DEMO · NO MONEY TRANSFERRED'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Close status'));
      await tester.pumpAndSettle();
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Brooklyn Simmons'), findsNWidgets(2));
      expect(find.text('+ MYR 38.20'), findsOneWidget);
      expect(find.text('- MYR 38.20'), findsOneWidget);
      expect(TransactionStore.instance.value.length, 1);
      await tester.tap(find.text('Brooklyn Simmons').last);
      await tester.pumpAndSettle();
      expect(find.text('Status'), findsOneWidget);
      await tester.tap(find.byTooltip('Close status'));
      await tester.pumpAndSettle();
      expect(find.text('Transactions'), findsOneWidget);
      expect(TransactionStore.instance.value.length, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
