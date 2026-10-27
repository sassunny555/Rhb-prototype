import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhb_banking_prototype/main.dart';

void main() {
  testWidgets('Home matches reference content and balance visibility works', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BankingPrototype());
    await tester.pumpAndSettle();
    expect(find.text('Savings Pro Account-i'), findsOneWidget);
    expect(find.text('MYR 388.20'), findsOneWidget);
    expect(find.text('Top Favourites'), findsOneWidget);
    expect(find.text('Offers & Promotion'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Hide balance'));
    await tester.pump();
    expect(find.text('MYR ••••'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
