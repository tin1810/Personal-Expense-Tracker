import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/presentation/utils/amount_input_buffer.dart';

void main() {
  group('AmountInputBuffer.applyDigit', () {
    test('replaces initial 0 with non-zero digit', () {
      expect(AmountInputBuffer.applyDigit(AmountInputBuffer.initial, '7'), '7');
    });

    test('ignores extra zero on initial', () {
      expect(AmountInputBuffer.applyDigit(AmountInputBuffer.initial, '0'), AmountInputBuffer.initial);
    });

    test('appends digit to whole part', () {
      expect(AmountInputBuffer.applyDigit('12', '3'), '123');
    });

    test('allows up to two fractional digits then ignores', () {
      expect(AmountInputBuffer.applyDigit('3.14', '9'), '3.14');
      expect(AmountInputBuffer.applyDigit('3.1', '4'), '3.14');
    });
  });

  group('AmountInputBuffer.applyDot', () {
    test('adds single decimal point', () {
      expect(AmountInputBuffer.applyDot('10'), '10.');
    });

    test('does not add second dot', () {
      expect(AmountInputBuffer.applyDot('1.5'), '1.5');
    });
  });

  group('AmountInputBuffer.applyBackspace', () {
    test('reduces length', () {
      expect(AmountInputBuffer.applyBackspace('123'), '12');
    });

    test('returns initial when one char left', () {
      expect(AmountInputBuffer.applyBackspace('5'), AmountInputBuffer.initial);
      expect(AmountInputBuffer.applyBackspace('0'), AmountInputBuffer.initial);
    });
  });

  group('AmountInputBuffer.applyAc', () {
    test('resets to initial', () {
      expect(AmountInputBuffer.applyAc(), AmountInputBuffer.initial);
    });
  });

  group('AmountInputBuffer.applyDoubleZero', () {
    test('appends two zeros when allowed', () {
      expect(AmountInputBuffer.applyDoubleZero('1'), '100');
    });
  });

  group('AmountInputBuffer.fromAmount', () {
    test('non-positive returns initial', () {
      expect(AmountInputBuffer.fromAmount(0), AmountInputBuffer.initial);
      expect(AmountInputBuffer.fromAmount(-1), AmountInputBuffer.initial);
    });

    test('integer amount omits decimals', () {
      expect(AmountInputBuffer.fromAmount(42), '42');
    });

    test('two decimal places normalized', () {
      expect(AmountInputBuffer.fromAmount(12.50), '12.5');
      expect(AmountInputBuffer.fromAmount(0.01), '0.01');
    });
  });

  group('AmountInputBuffer.parseAmount', () {
    test('parses whole and decimal buffers', () {
      expect(AmountInputBuffer.parseAmount('12.34'), 12.34);
      expect(AmountInputBuffer.parseAmount('99'), 99.0);
    });

    test('trailing dot parses whole part', () {
      expect(AmountInputBuffer.parseAmount('12.'), 12.0);
    });

    test('initial parses as zero', () {
      expect(AmountInputBuffer.parseAmount('0'), 0.0);
    });
  });
}
