import 'package:flutter_test/flutter_test.dart';
import 'package:rhb_banking_prototype/payment/recipient.dart';

void main() {
  String field(String id, String value) =>
      '$id${value.length.toString().padLeft(2, '0')}$value';
  String payment(String name) {
    final data =
        '${field('00', '02')}${field('53', '458')}${field('54', '12.50')}${field('59', name)}6304';
    return '$data${crc16(data)}';
  }

  test('extracts name and MYR amount from checksum-valid payment QR', () {
    final recipient = parsePaymentQr(payment('Brooklyn Simmons'));
    expect(recipient.name, 'Brooklyn Simmons');
    expect(recipient.amount, '12.50');
    expect(recipient.account, isNull);
  });
  test('rejects damaged, malformed and unknown QR data', () {
    expect(
      parsePaymentQr(
        payment('Brooklyn Simmons').replaceFirst('Brooklyn', 'Brooklym'),
      ).name,
      isNull,
    );
    expect(parsePaymentQr('5905Bob').name, isNull);
    expect(parsePaymentQr('https://example.com/Brooklyn').name, isNull);
    expect(parsePaymentQr('{"name":"Unverified arbitrary JSON"}').name, isNull);
  });
  test('recognizes explicitly marked demo QR', () {
    final r = parsePaymentQr(
      '{"type":"fyp-payment","name":"Demo Recipient","account":"1234"}',
    );
    expect(r.name, 'Demo Recipient');
    expect(r.account, '1234');
  });
  test('OCR uses recipient label, not arbitrary text', () {
    expect(
      nameFromOcr(
        'Receive\nScan this QR to transfer to\nBrooklyn Simmons\nMALAYSIA NATIONAL QR\nDownload QR code',
      ),
      'Brooklyn Simmons',
    );
    expect(nameFromOcr('Recipient name: Brooklyn Simmons'), 'Brooklyn Simmons');
    expect(
      nameFromOcr(
        'Download QR code\nEnter specific amount\nDuitNow Account Number',
      ),
      isNull,
    );
  });
  test('amount validation rejects invalid and nonpositive values', () {
    for (final value in ['0', '-1', 'NaN', 'Infinity', '1.999', '1,000', '']) {
      expect(validAmount(value), isFalse);
    }
    expect(validAmount('388.20'), isTrue);
  });
}
