import 'dart:async';

import 'package:flutter/material.dart';

import 'status_screen.dart';
import 'transaction_store.dart';

class PaymentLoadingScreen extends StatefulWidget {
  const PaymentLoadingScreen({
    super.key,
    required this.name,
    required this.amount,
    required this.resident,
    required this.details,
  });
  final String name, amount, details;
  final bool resident;
  @override
  State<PaymentLoadingScreen> createState() => _PaymentLoadingScreenState();
}

class _PaymentLoadingScreenState extends State<PaymentLoadingScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 2), () async {
      final record = PaymentTransaction.create(
        name: widget.name,
        amount: widget.amount,
        resident: widget.resident,
        details: widget.details,
      );
      final saved = await TransactionStore.instance.add(record);
      if (mounted && !saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Transaction saved for this session only; local storage is unavailable.',
            ),
          ),
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReceiptScreen(transaction: record),
        ),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      backgroundColor: Color(0xffeff9fc),
      body: Center(
        child: Semantics(
          label: 'Processing payment',
          liveRegion: true,
          child: SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              color: Color(0xff3067a8),
              backgroundColor: Color(0xffdcebf7),
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ),
    ),
  );
}
