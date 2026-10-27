import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhb_banking_prototype/receive_view.dart';

void main() {
  testWidgets('Receive view shows account, QR and sharing without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceiveView(
            onClose: () => closed = true,
            footer: const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('DuitNow QR'), findsOneWidget);
    expect(find.text('1-62027-0028825-8'), findsOneWidget);
    expect(find.text('Malaysia National QR'), findsOneWidget);
    expect(find.text('Share QR'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close receive screen'));
    expect(closed, isTrue);
  });
}
