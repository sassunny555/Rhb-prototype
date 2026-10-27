import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../receive_view.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    super.key,
    required this.name,
    required this.amount,
    required this.resident,
    this.details = '',
  });
  final String name, amount, details;
  final bool resident;
  void information(BuildContext context, String title) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(
        'This is an academic banking prototype. Approving creates a demo receipt only. No funds are transferred and no real deposit protection or banking agreement is established.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Scaffold(
      backgroundColor: const Color(0xffeff9fc),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: LayoutBuilder(
            builder: (context, box) {
              final s = box.maxWidth / 393;
              const ink = Color(0xff101e29);
              const blue = Color(0xff3067a8);
              return Stack(
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
                                          'Review',
                                          style: TextStyle(
                                            fontSize: 15 * s,
                                            fontWeight: FontWeight.w600,
                                            color: ink,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: IconButton(
                                            tooltip: 'Back to payment details',
                                            padding: EdgeInsets.zero,
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            icon: Icon(
                                              Icons.arrow_back,
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
                          Container(
                            height: 88 * s,
                            color: Colors.white,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -12 * s,
                                  left: 13 * s,
                                  child: Container(
                                    width: 58 * s,
                                    height: 58 * s,
                                    padding: EdgeInsets.all(17 * s),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xffe4e4e4),
                                      ),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/qr-code.svg',
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 18 * s,
                                  top: 10 * s,
                                  child: Image.asset(
                                    'assets/images/duitnow_badge.png',
                                    width: 50 * s,
                                    height: 63 * s,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  left: 13 * s,
                                  right: 80 * s,
                                  top: 54 * s,
                                  child: Text(
                                    name,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      color: ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                              15 * s,
                              15 * s,
                              16 * s,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                SizedBox(height: 17 * s),
                                label('From', s),
                                value('Savings Pro Account-i', s),
                                value('16202700288258', s),
                                SizedBox(height: 17 * s),
                                label('Recipient’s Residential Status', s),
                                value(
                                  resident ? 'Resident' : 'Non-Resident',
                                  s,
                                ),
                                SizedBox(height: 17 * s),
                                label('Payment Type', s),
                                value('DuitNow QR P2P', s),
                                if (details.isNotEmpty) ...[
                                  SizedBox(height: 17 * s),
                                  label('Other Payment Details', s),
                                  value(details, s),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              15 * s,
                              21 * s,
                              15 * s,
                              24 * s,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '1. ',
                                      style: TextStyle(
                                        fontSize: 11 * s,
                                        color: const Color(0xff68727d),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Money withdrawn from your insured deposits is no longer protected by PIDM if transferred to non-PIDM members and non-deposit products.',
                                            style: TextStyle(
                                              fontSize: 11 * s,
                                              height: 1.4,
                                              color: const Color(0xff68727d),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => information(
                                              context,
                                              'Learn More',
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top: 6 * s,
                                                bottom: 10 * s,
                                              ),
                                              child: Text(
                                                'Learn More',
                                                style: TextStyle(
                                                  fontSize: 13 * s,
                                                  color: blue,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8 * s),
                                Row(
                                  children: [
                                    Text(
                                      '2. ',
                                      style: TextStyle(
                                        fontSize: 11 * s,
                                        color: const Color(0xff68727d),
                                      ),
                                    ),
                                    Flexible(
                                      child: InkWell(
                                        onTap: () => information(
                                          context,
                                          'Terms and Conditions',
                                        ),
                                        child: Text(
                                          'Terms and Conditions',
                                          style: TextStyle(
                                            fontSize: 13 * s,
                                            color: blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16 * s),
                                Text(
                                  'By submitting this, I confirm that I have read and agreed to the coverage of PIDM and Terms and Conditions therein.',
                                  style: TextStyle(
                                    fontSize: 11 * s,
                                    height: 1.4,
                                    color: const Color(0xff68727d),
                                  ),
                                ),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox.expand(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xffbb4244),
                                  side: const BorderSide(
                                    color: Color(0xffbb4244),
                                  ),
                                  shape: const StadiumBorder(),
                                  textStyle: TextStyle(
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Reject'),
                              ),
                            ),
                          ),
                          SizedBox(width: 11 * s),
                          Expanded(
                            child: SizedBox.expand(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: blue,
                                  shape: const StadiumBorder(),
                                  textStyle: TextStyle(
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Approve'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
