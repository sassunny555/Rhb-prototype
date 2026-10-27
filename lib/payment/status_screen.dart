import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../receive_view.dart';
import 'transaction_store.dart';
import 'transactions_screen.dart';

class ReceiptScreen extends StatelessWidget {
  ReceiptScreen({
    super.key,
    required this.transaction,
    this.fromHistory = false,
    this.incoming = false,
  });
  final PaymentTransaction transaction;
  final bool fromHistory;
  final bool incoming;
  String get name => transaction.name;
  String get amount => transaction.amount;
  String get details => transaction.details;
  String get reference =>
      incoming ? '${transaction.reference}-REV' : transaction.reference;
  bool get resident => transaction.resident;
  DateTime get timestamp => transaction.myt;
  void leave(BuildContext context) {
    if (fromHistory) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const TransactionsScreen()),
      );
    }
  }

  final receiptKey = GlobalKey();
  String get receiptFileStem =>
      'RHB_${reference.replaceFirst('DEMO', '')}_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';

  String get dateLabel {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}${timestamp.hour >= 12 ? 'PM' : 'AM'} ${days[timestamp.weekday - 1]}, ${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year} MYT';
  }

  Future<void> share(BuildContext context) async {
    try {
      final boundary =
          receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null || !context.mounted) return;
      final box = context.findRenderObject() as RenderBox;
      await SharePlus.instance.share(
        ShareParams(
          title: receiptFileStem,
          text: receiptFileStem,
          files: [
            XFile.fromData(
              bytes.buffer.asUint8List(),
              mimeType: 'image/png',
              name: '$receiptFileStem.png',
            ),
          ],
          fileNameOverrides: ['$receiptFileStem.png'],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share the receipt on this device.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: PopScope(
      canPop: fromHistory,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffeff9fc),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: RepaintBoundary(
              key: receiptKey,
              child: LayoutBuilder(
                builder: (context, box) {
                  final s = box.maxWidth / 393;
                  const ink = Color(0xff101e29);
                  return ColoredBox(
                    color: const Color(0xffeff9fc),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          bottom: 90 * s,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 107 * s,
                                  child: Stack(
                                    children: [
                                      const Positioned.fill(
                                        child: CustomPaint(
                                          painter: ReceiveHeaderPainter(),
                                        ),
                                      ),

                                      Positioned(
                                        top: 58 * s,
                                        left: 12 * s,
                                        right: 12 * s,
                                        child: SizedBox(
                                          height: 34 * s,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Text(
                                                'Status',
                                                style: TextStyle(
                                                  fontSize: 15 * s,
                                                  fontWeight: FontWeight.w600,
                                                  color: ink,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: IconButton(
                                                  tooltip: 'Close status',
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () =>
                                                      leave(context),
                                                  icon: Icon(
                                                    Icons.close,
                                                    size: 23 * s,
                                                    color: ink,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    17 * s,
                                    17 * s,
                                    15 * s,
                                    18 * s,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 39 * s,
                                        height: 39 * s,
                                        decoration: const BoxDecoration(
                                          color: Color(0xff49872d),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 27 * s,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10 * s),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Successful',
                                              style: TextStyle(
                                                fontSize: 19 * s,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xff49872d),
                                              ),
                                            ),
                                            SizedBox(height: 4 * s),
                                            Text(
                                              dateLabel,
                                              style: TextStyle(
                                                fontSize: 12 * s,
                                                color: ink,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  color: Colors.white,
                                  padding: EdgeInsets.fromLTRB(
                                    15 * s,
                                    18 * s,
                                    15 * s,
                                    14 * s,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Amount',
                                                  style: TextStyle(
                                                    fontSize: 11 * s,
                                                    color: ink,
                                                  ),
                                                ),
                                                SizedBox(height: 2 * s),
                                                Text(
                                                  'MYR $amount',
                                                  style: TextStyle(
                                                    fontSize: 23 * s,
                                                    fontWeight: FontWeight.w600,
                                                    color: ink,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/images/duitnow_badge.png',
                                            width: 50 * s,
                                            height: 58 * s,
                                            fit: BoxFit.contain,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15 * s),
                                      Row(
                                        children: [
                                          Text(
                                            'Reference ID',
                                            style: TextStyle(
                                              fontSize: 13 * s,
                                              fontWeight: FontWeight.w600,
                                              color: ink,
                                            ),
                                          ),
                                          SizedBox(width: 20 * s),
                                          Expanded(
                                            child: Text(
                                              reference,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12 * s,
                                                color: ink,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8 * s),
                                Container(
                                  width: double.infinity,
                                  color: Colors.white,
                                  padding: EdgeInsets.fromLTRB(
                                    15 * s,
                                    17 * s,
                                    15 * s,
                                    16 * s,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      label('From', s),
                                      value(
                                        incoming
                                            ? name
                                            : 'Savings Pro Account-i',
                                        s,
                                      ),
                                      if (!incoming) value('16202700288258', s),
                                      SizedBox(height: 17 * s),
                                      label('To', s),
                                      value(
                                        incoming
                                            ? 'Savings Pro Account-i'
                                            : name,
                                        s,
                                      ),
                                      if (incoming) value('16202700288258', s),
                                      SizedBox(height: 17 * s),
                                      label('Payment Type', s),
                                      value('DuitNow QR P2P', s),
                                      SizedBox(height: 17 * s),
                                      label(
                                        'Recipient’s Residential Status',
                                        s,
                                      ),
                                      value(
                                        resident ? 'Resident' : 'Non-Resident',
                                        s,
                                      ),
                                      if (details.isNotEmpty) ...[
                                        SizedBox(height: 17 * s),
                                        label('Other Payment Details', s),
                                        value(details, s),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 90 * s,
                            padding: EdgeInsets.fromLTRB(
                              15 * s,
                              15 * s,
                              15 * s,
                              30 * s,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(17 * s),
                              ),
                            ),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xff3067a8),
                                shape: const StadiumBorder(),
                                textStyle: TextStyle(fontSize: 16 * s),
                              ),
                              onPressed: () => share(context),
                              child: const Text('Share Receipt'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget label(String text, double s) => Padding(
    padding: EdgeInsets.only(bottom: 2 * s),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13 * s,
        fontWeight: FontWeight.w600,
        color: const Color(0xff101e29),
      ),
    ),
  );
  Widget value(String text, double s) => Text(
    text,
    style: TextStyle(
      fontSize: 13 * s,
      height: 1.4,
      color: const Color(0xff101e29),
    ),
  );
}
