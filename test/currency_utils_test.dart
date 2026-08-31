import 'package:dobre/utils/currency_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyUtils.format tests', () {
    test('Formats integers with thousand dots and currency symbol', () {
      expect(CurrencyUtils.format(35000), '\$ 35.000');
      expect(CurrencyUtils.format(1500), '\$ 1.500');
      expect(CurrencyUtils.format(1000000), '\$ 1.000.000');
      expect(CurrencyUtils.format(0), '\$ 0');
    });

    test('Formats decimals when requested', () {
      expect(CurrencyUtils.format(63619.45, includeDecimals: true), '\$ 63.619,45');
      expect(CurrencyUtils.format(35000.0, includeDecimals: true), '\$ 35.000');
    });

    test('Formats exact user-specified amounts correctly', () {
      expect(CurrencyUtils.format(1), '\$ 1');
      expect(CurrencyUtils.format(10), '\$ 10');
      expect(CurrencyUtils.format(100), '\$ 100');
      expect(CurrencyUtils.format(1000), '\$ 1.000');
      expect(CurrencyUtils.format(35000), '\$ 35.000');
      expect(CurrencyUtils.format(35450.75, includeDecimals: true), '\$ 35.450,75');
      expect(CurrencyUtils.format(500000), '\$ 500.000');
      expect(CurrencyUtils.format(5000000), '\$ 5.000.000');
    });

    test('Handles negative and special values gracefully', () {
      expect(CurrencyUtils.format(-500), '-\$ 500');
      expect(CurrencyUtils.format(double.nan), '\$ 0');
      expect(CurrencyUtils.format(double.infinity), '\$ 0');
      expect(CurrencyUtils.format(double.negativeInfinity), '\$ 0');
    });
  });

  group('CurrencyUtils.parse tests', () {
    test('Parses plain numbers', () {
      expect(CurrencyUtils.parse('35000'), 35000.0);
      expect(CurrencyUtils.parse('1500'), 1500.0);
      expect(CurrencyUtils.parse('0'), 0.0);
    });

    test('Parses numbers with thousand separators', () {
      expect(CurrencyUtils.parse('35.000'), 35000.0);
      expect(CurrencyUtils.parse('1.500.000'), 1500000.0);
      expect(CurrencyUtils.parse('35,000'), 35000.0);
    });

    test('Parses numbers with currency symbols and spaces', () {
      expect(CurrencyUtils.parse('\$ 35.000'), 35000.0);
      expect(CurrencyUtils.parse('\$35000'), 35000.0);
      expect(CurrencyUtils.parse('  \$ 1.250,50  '), 1250.50);
    });

    test('Parses decimals with comma or dot', () {
      expect(CurrencyUtils.parse('35000,50'), 35000.50);
      expect(CurrencyUtils.parse('35000.50'), 35000.50);
      expect(CurrencyUtils.parse('35.000,75'), 35000.75);
    });

    test('Returns null for empty or invalid strings', () {
      expect(CurrencyUtils.parse(''), isNull);
      expect(CurrencyUtils.parse('   '), isNull);
      expect(CurrencyUtils.parse('\$'), isNull);
      expect(CurrencyUtils.parse('abc'), isNull);
      expect(CurrencyUtils.parse(null), isNull);
    });
  });
}
