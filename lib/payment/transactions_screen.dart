import 'package:flutter/material.dart';

import '../receive_view.dart';
import 'transaction_store.dart';
import 'status_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool receipts = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: LayoutBuilder(
          builder: (context, box) {
            final s = box.maxWidth / 393;
            return Column(
              children: [
                SizedBox(
                  height: 137 * s,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: ReceiveHeaderPainter()),
                      ),

                      Positioned(
                        top: 53 * s,
                        left: 12 * s,
                        right: 12 * s,
                        child: SizedBox(
                          height: 34 * s,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'Transactions',
                                style: TextStyle(
                                  fontSize: 15 * s,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff101e29),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  tooltip: 'Back to home',
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  ),
                                  icon: Icon(Icons.arrow_back, size: 23 * s),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 15 * s,
                        right: 0,
                        bottom: 0,
                        height: 38 * s,
                        child: Row(
                          children: [
                            tab('All', false, s),
                            SizedBox(width: 30 * s),
                            tab('Receipts', true, s),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<PaymentTransaction>>(
                    valueListenable: TransactionStore.instance,
                    builder: (context, records, _) {
                      final rows = <Widget>[];
                      String? lastDate;
                      for (final record in records) {
                        final date = transactionDateLabel(record.myt);
                        if (date != lastDate) {
                          rows.add(
                            Container(
                              width: double.infinity,
                              color: const Color(0xffeff9fc),
                              padding: EdgeInsets.symmetric(
                                horizontal: 15 * s,
                                vertical: 15 * s,
                              ),
                              child: Text(
                                date,
                                style: TextStyle(
                                  fontSize: 13 * s,
                                  color: const Color(0xff67717a),
                                ),
                              ),
                            ),
                          );
                          lastDate = date;
                        }
                        for (final incoming in [true, false]) {
                          if (incoming &&
                              TransactionStore.instance.deletedSamples.contains(
                                '${record.reference}-REV',
                              )) {
                            continue;
                          }
                          rows.add(
                            swipeRow(
                              incoming
                                  ? '${record.reference}-REV'
                                  : record.reference,
                              () => incoming
                                  ? TransactionStore.instance.deleteSample(
                                      '${record.reference}-REV',
                                    )
                                  : TransactionStore.instance.delete(
                                      record.reference,
                                    ),
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => ReceiptScreen(
                                      transaction: record,
                                      fromHistory: true,
                                      incoming: incoming,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                    15 * s,
                                    18 * s,
                                    15 * s,
                                    14 * s,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xfff1f1f1),
                                      ),
                                    ),
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
                                            child: Text(
                                              record.name,
                                              style: TextStyle(
                                                fontSize: 13 * s,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xff101e29),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12 * s),
                                          Text(
                                            '${incoming ? '+' : '-'} MYR ${record.amount}',
                                            style: TextStyle(
                                              fontSize: 13 * s,
                                              color: incoming
                                                  ? const Color(0xff508835)
                                                  : const Color(0xffbd484b),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 3 * s),
                                      Text(
                                        incoming
                                            ? '${record.reference}-REV'
                                            : record.reference,
                                        style: TextStyle(
                                          fontSize: 12 * s,
                                          color: const Color(0xff67717a),
                                        ),
                                      ),
                                      SizedBox(height: 7 * s),
                                      Text(
                                        'DuitNow QR P2P',
                                        style: TextStyle(
                                          fontSize: 11 * s,
                                          color: const Color(0xff67717a),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      rows.addAll(defaultRows(s, lastDate));
                      return ListView(padding: EdgeInsets.zero, children: rows);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  List<Widget> defaultRows(double s, String? previousDate) {
    const samples = [
      (
        'Tuesday, 27 October 2026',
        'AMIRUL SYAMIL',
        'RHBQR000000',
        '4.00',
        true,
        'DuitNow QR P2P',
        'QR84520245\nDuitQR P2P Transfer',
      ),
      (
        'Tuesday, 27 October 2026',
        'JASMI BIN SUDIN',
        '10091488922',
        '11.00',
        false,
        'DuitNow QR P2P',
        '',
      ),
      (
        'Tuesday, 27 October 2026',
        'PETRONAS',
        '251026 PETRONAS',
        '30.00',
        false,
        'Debit Card Transaction',
        '',
      ),
      (
        'Monday, 26 October 2026',
        'PETRONAS',
        '241026 PETRONAS',
        '30.00',
        false,
        'Debit Card Transaction',
        '',
      ),
      (
        'Monday, 26 October 2026',
        'SHEIKH MD SHAMIM',
        '171002837295',
        '7.50',
        false,
        'DuitNow QR P2P',
        '',
      ),
      (
        'Monday, 26 October 2026',
        'TEOH CHUN KIAT',
        '150729622256',
        '5.00',
        false,
        'DuitNow QR P2P',
        '',
      ),
    ];
    final rows = <Widget>[];
    var lastDate = previousDate;
    for (final entry in samples) {
      final id = 'sample-${entry.$1}-${entry.$2}-${entry.$3}';
      if (TransactionStore.instance.deletedSamples.contains(id)) continue;
      if (entry.$1 != lastDate) {
        rows.add(
          Container(
            width: double.infinity,
            color: const Color(0xffeff9fc),
            padding: EdgeInsets.symmetric(horizontal: 15 * s, vertical: 15 * s),
            child: Text(
              entry.$1,
              style: TextStyle(
                fontSize: 13 * s,
                color: const Color(0xff67717a),
              ),
            ),
          ),
        );
        lastDate = entry.$1;
      }
      rows.add(
        swipeRow(
          id,
          () => TransactionStore.instance.deleteSample(id),
          Container(
            padding: EdgeInsets.fromLTRB(15 * s, 18 * s, 15 * s, 14 * s),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xfff1f1f1))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.$2,
                        style: TextStyle(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff101e29),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Text(
                      '${entry.$5 ? '' : '- '}MYR ${entry.$4}',
                      style: TextStyle(
                        fontSize: 13 * s,
                        color: entry.$5
                            ? const Color(0xff508835)
                            : const Color(0xffbd484b),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3 * s),
                Text(
                  entry.$3,
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: const Color(0xff67717a),
                  ),
                ),
                SizedBox(height: 7 * s),
                Text(
                  entry.$6,
                  style: TextStyle(
                    fontSize: 11 * s,
                    color: const Color(0xff67717a),
                  ),
                ),
                if (entry.$7.isNotEmpty) ...[
                  SizedBox(height: 7 * s),
                  Text(
                    entry.$7,
                    style: TextStyle(
                      fontSize: 12 * s,
                      height: 1.8,
                      color: const Color(0xff67717a),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return rows;
  }

  Widget swipeRow(String id, Future<bool> Function() remove, Widget child) =>
      Dismissible(
        key: ValueKey('transaction-$id'),
        direction: DismissDirection.endToStart,
        background: Container(
          color: const Color(0xffbd484b),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (_) async {
          final saved = await remove();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                saved
                    ? 'Transaction deleted'
                    : 'Deleted for this session. Unable to save changes.',
              ),
            ),
          );
        },
        child: child,
      );

  Widget tab(String title, bool value, double s) => InkWell(
    onTap: () => setState(() => receipts = value),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7 * s),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13 * s,
              color: receipts == value
                  ? const Color(0xff3067a8)
                  : const Color(0xff101e29),
              fontWeight: receipts == value
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
        Container(
          width: 16 * s,
          height: 2 * s,
          color: receipts == value
              ? const Color(0xff3067a8)
              : Colors.transparent,
        ),
      ],
    ),
  );
}
