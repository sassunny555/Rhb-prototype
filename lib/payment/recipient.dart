import 'dart:convert';

class Recipient {
  const Recipient({
    this.name,
    this.account,
    this.amount,
    this.source = 'Manual confirmation',
  });
  final String? name;
  final String? account;
  final String? amount;
  final String source;
}

Recipient parsePaymentQr(String raw) {
  try {
    final data = jsonDecode(raw);
    if (data is Map && data['type'] == 'fyp-payment') {
      String? field(String key) =>
          data[key] is String && (data[key] as String).trim().isNotEmpty
          ? (data[key] as String).trim()
          : null;
      return Recipient(
        name: field('name'),
        account: field('account'),
        amount: validAmount(field('amount')) ? field('amount') : null,
        source: 'Demo QR data',
      );
    }
  } catch (_) {
    /* Not a JSON payment QR. */
  }
  final fields = <String, String>{};
  var pos = 0;
  while (pos + 4 <= raw.length) {
    final id = raw.substring(pos, pos + 2);
    final length = int.tryParse(raw.substring(pos + 2, pos + 4));
    if (!RegExp(r'^\d{2}$').hasMatch(id) ||
        length == null ||
        pos + 4 + length > raw.length ||
        fields.containsKey(id)) {
      return const Recipient();
    }
    fields[id] = raw.substring(pos + 4, pos + 4 + length);
    pos += 4 + length;
  }
  if (pos != raw.length ||
      fields['00'] == null ||
      fields['63']?.length != 4 ||
      !raw.endsWith('6304${fields['63']}')) {
    return const Recipient();
  }
  if (crc16(raw.substring(0, raw.length - 4)) != fields['63']!.toUpperCase()) {
    return const Recipient();
  }
  final name = fields['59']?.trim();
  return Recipient(
    name: name == null || name.isEmpty ? null : name,
    amount: fields['53'] == '458' && validAmount(fields['54'])
        ? fields['54']
        : null,
    source: 'Payment QR name field',
  );
}

String crc16(String value) {
  var crc = 0xffff;
  for (final byte in utf8.encode(value)) {
    crc ^= byte << 8;
    for (var bit = 0; bit < 8; bit++) {
      crc = ((crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1) & 0xffff;
    }
  }
  return crc.toRadixString(16).padLeft(4, '0').toUpperCase();
}

bool validAmount(String? value) =>
    value != null &&
    RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(value) &&
    (double.tryParse(value) ?? 0) > 0;

String? nameFromOcr(String text) {
  final lines = text
      .split('\n')
      .map((s) => s.trim().replaceAll(RegExp(r'\s+'), ' '))
      .where((s) => s.isNotEmpty)
      .toList();
  final label = RegExp(
    r'(?:scan\s+this\s+qr\s+to\s+transfer\s+to|recipient\s*(?:name)?|account\s*name|pay\s+to|transfer\s+to)\s*[:\-]?\s*(.*)$',
    caseSensitive: false,
  );
  bool plausible(String s) =>
      s.length >= 3 &&
      s.length <= 80 &&
      RegExp(r'[a-zA-Z]').hasMatch(s) &&
      !RegExp(
        r'qr|amount|download|receive|transfer|payment|duitnow|national|account number',
        caseSensitive: false,
      ).hasMatch(s) &&
      !RegExp(r'\d{3}').hasMatch(s);
  for (var i = 0; i < lines.length; i++) {
    final match = label.firstMatch(lines[i]);
    if (match == null) continue;
    final inline = match.group(1)!.trim();
    if (plausible(inline)) return inline;
    if (i + 1 < lines.length && plausible(lines[i + 1])) return lines[i + 1];
  }
  return null;
}
