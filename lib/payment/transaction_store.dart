import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentTransaction {
  const PaymentTransaction({
    required this.reference,
    required this.name,
    required this.amount,
    required this.resident,
    required this.details,
    required this.createdAt,
  });
  factory PaymentTransaction.create({
    required String name,
    required String amount,
    required bool resident,
    required String details,
  }) {
    final now = DateTime.now().toUtc();
    return PaymentTransaction(
      reference: 'DEMO${now.microsecondsSinceEpoch}',
      name: name,
      amount: amount,
      resident: resident,
      details: details,
      createdAt: now,
    );
  }
  final String reference, name, amount, details;
  final bool resident;
  final DateTime createdAt;
  DateTime get myt => createdAt.toUtc().add(const Duration(hours: 8));
  Map<String, dynamic> toJson() => {
    'reference': reference,
    'name': name,
    'amount': amount,
    'resident': resident,
    'details': details,
    'createdAt': createdAt.toIso8601String(),
  };
  factory PaymentTransaction.fromJson(Map<String, dynamic> value) =>
      PaymentTransaction(
        reference: value['reference'] as String,
        name: value['name'] as String,
        amount: value['amount'] as String,
        resident: value['resident'] as bool,
        details: value['details'] as String,
        createdAt: DateTime.parse(value['createdAt'] as String),
      );
}

class TransactionStore extends ValueNotifier<List<PaymentTransaction>> {
  TransactionStore() : super(const []);
  static final instance = TransactionStore();
  static const storageKey = 'fyp_payment_transactions_v1';
  final Set<String> deletedSamples = {};
  static const deletedSamplesKey = 'fyp_deleted_sample_transactions_v1';
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      deletedSamples.addAll(prefs.getStringList(deletedSamplesKey) ?? []);
      notifyListeners();
      final saved = prefs.getString(storageKey);
      if (saved == null) return;
      final records = <String, PaymentTransaction>{
        for (final item in value) item.reference: item,
      };
      for (final item in jsonDecode(saved) as List) {
        try {
          final record = PaymentTransaction.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
          records.putIfAbsent(record.reference, () => record);
        } catch (_) {
          /* Skip an invalid stored row. */
        }
      }
      value = records.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      /* Keep the session usable if local storage is unavailable. */
    }
  }

  Future<bool> delete(String reference) async {
    value = value.where((item) => item.reference != reference).toList();
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        storageKey,
        jsonEncode(value.map((item) => item.toJson()).toList()),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSample(String id) async {
    deletedSamples.add(id);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(
        deletedSamplesKey,
        deletedSamples.toList(),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> add(PaymentTransaction record) async {
    if (!value.any((item) => item.reference == record.reference)) {
      value = [...value, record]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        storageKey,
        jsonEncode(value.map((item) => item.toJson()).toList()),
      );
    } catch (_) {
      return false;
    }
  }
}

String transactionDateLabel(DateTime date) {
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
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}
