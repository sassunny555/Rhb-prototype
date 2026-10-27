import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../receive_view.dart';

import 'payment_loading_screen.dart';

import 'recipient.dart';
import 'cents_input_formatter.dart';
import 'review_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.recipient, this.ocrMessage});
  final Recipient recipient;
  final String? ocrMessage;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.recipient.name);
  final amount = TextEditingController(text: '00.00');
  final details = TextEditingController();
  bool resident = true;
  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    details.dispose();
    super.dispose();
  }

  Future<void> editRecipient() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recipient name'),
        content: TextField(
          controller: name,
          maxLength: 80,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter recipient name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> next() async {
    FocusScope.of(context).unfocus();
    if (name.text.trim().isEmpty) {
      await editRecipient();
      return;
    }
    if (!form.currentState!.validate()) return;
    final approved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          name: name.text.trim(),
          amount: double.parse(amount.text.trim()).toStringAsFixed(2),
          resident: resident,
          details: details.text.trim(),
        ),
      ),
    );
    if (approved != true || !mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PaymentLoadingScreen(
          name: name.text.trim(),
          resident: resident,
          details: details.text.trim(),
          amount: double.parse(amount.text.trim()).toStringAsFixed(2),
        ),
      ),
    );
  }

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
              const muted = Color(0xff858c90);
              const blue = Color(0xff3067a8);
              return Stack(
                children: [
                  Positioned.fill(
                    bottom: 90 * s,
                    child: SingleChildScrollView(
                      child: Form(
                        key: form,
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
                                            'Payment Details',
                                            style: TextStyle(
                                              fontSize: 15 * s,
                                              fontWeight: FontWeight.w600,
                                              color: ink,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: IconButton(
                                              tooltip: 'Back to scanner',
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  Navigator.pop(context),
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
                                    child: GestureDetector(
                                      onTap: editRecipient,
                                      child: Text(
                                        name.text.trim().isEmpty
                                            ? 'Enter recipient name'
                                            : name.text.trim(),
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 13 * s,
                                          color: ink,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8 * s),
                            Container(
                              height: 87 * s,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 15 * s,
                                vertical: 10 * s,
                              ),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'From',
                                        style: TextStyle(
                                          fontSize: 11 * s,
                                          color: muted,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 18 * s,
                                        color: ink,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7 * s),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          'Savings Pro Account-i',
                                          style: TextStyle(
                                            fontSize: 13 * s,
                                            color: ink,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        'MYR 388.20',
                                        style: TextStyle(
                                          fontSize: 13 * s,
                                          color: ink,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3 * s),
                                  Text(
                                    '1-62027-0028825-8',
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      color: ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8 * s),
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.fromLTRB(
                                15 * s,
                                16 * s,
                                15 * s,
                                15 * s,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recipient’s Residential Status',
                                    style: TextStyle(
                                      fontSize: 11 * s,
                                      color: const Color(0xff60666c),
                                    ),
                                  ),
                                  SizedBox(height: 11 * s),
                                  Row(
                                    children: [
                                      status('Resident', true, s),
                                      SizedBox(width: 8 * s),
                                      status('Non-Resident', false, s),
                                    ],
                                  ),
                                  SizedBox(height: 27 * s),
                                  Text(
                                    'Amount in MYR',
                                    style: TextStyle(
                                      fontSize: 11 * s,
                                      color: muted,
                                    ),
                                  ),
                                  TextFormField(
                                    key: const Key('payment-amount'),
                                    controller: amount,
                                    onTap: () {
                                      if (amount.text == '00.00') {
                                        amount.selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: amount.text.length,
                                        );
                                      }
                                    },
                                    style: TextStyle(
                                      fontSize: 22 * s,
                                      fontWeight: FontWeight.w600,
                                      color: ink,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: const [
                                      CentsInputFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                        top: 3 * s,
                                        bottom: 5 * s,
                                      ),
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xffc8cbd0),
                                        ),
                                      ),
                                    ),
                                    validator: (v) => validAmount(v?.trim())
                                        ? null
                                        : 'Enter an amount greater than 00.00.',
                                  ),
                                  SizedBox(height: 5 * s),
                                  Text(
                                    'Available Daily Limit: MYR 49,989.00',
                                    style: TextStyle(
                                      fontSize: 11 * s,
                                      color: blue,
                                    ),
                                  ),
                                  SizedBox(height: 34 * s),
                                  TextField(
                                    controller: details,
                                    maxLength: 140,
                                    style: TextStyle(fontSize: 14 * s),
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText:
                                          'Other Payment Details (Optional)',
                                      hintStyle: TextStyle(
                                        color: muted,
                                        fontSize: 15 * s,
                                      ),
                                      counterText: '',
                                      contentPadding: EdgeInsets.only(
                                        top: 8 * s,
                                        bottom: 8 * s,
                                      ),
                                      border: const UnderlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 5 * s),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          'Appear on recipient’s statement.',
                                          style: TextStyle(
                                            fontSize: 11 * s,
                                            color: blue,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        '${details.text.length}/140',
                                        style: TextStyle(
                                          fontSize: 11 * s,
                                          color: blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          backgroundColor: blue,
                          shape: const StadiumBorder(),
                          textStyle: TextStyle(fontSize: 16 * s),
                        ),
                        onPressed: next,
                        child: const Text('Next'),
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
  Widget status(String label, bool value, double s) => Expanded(
    child: SizedBox(
      height: 34 * s,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: resident == value
              ? const Color(0xffe1f1fd)
              : Colors.white,
          foregroundColor: resident == value
              ? const Color(0xff3067a8)
              : const Color(0xff101e29),
          side: BorderSide(
            color: resident == value
                ? const Color(0xff3067a8)
                : const Color(0xffe2e2e2),
          ),
          padding: EdgeInsets.zero,
          textStyle: TextStyle(fontSize: 13 * s),
        ),
        onPressed: () => setState(() => resident = value),
        child: Text(label),
      ),
    ),
  );
}
