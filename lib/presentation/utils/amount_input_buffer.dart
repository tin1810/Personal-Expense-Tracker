/// Pure keypad buffer logic for monetary strings 
abstract final class AmountInputBuffer {
  AmountInputBuffer._();

  static const String initial = '0';

  static String applyAc() => initial;

  static String applyBackspace(String current) {
    if (current.length <= 1) return initial;
    final next = current.substring(0, current.length - 1);
    if (next.isEmpty) return initial;
    return next;
  }

  static String applyDot(String current) {
    if (current.contains('.')) return current;
    return '$current.';
  }

  static String applyDoubleZero(String current) => applyDigit(applyDigit(current, '0'), '0');

  static String applyDigit(String current, String digit) {
    assert(digit.length == 1 && RegExp(r'\d').hasMatch(digit));
    final dotIdx = current.indexOf('.');
    if (dotIdx >= 0) {
      final frac = current.substring(dotIdx + 1);
      if (frac.length >= 2) return current;
    }
    if (current == initial && digit != '0') return digit;
    if (current == initial && digit == '0') return initial;
    return '$current$digit';
  }

  /// Builds a keypad buffer string from a stored positive amount (max two fractional digits).
  static String fromAmount(double amount) {
    if (amount <= 0) return initial;
    final cents = (amount * 100).round();
    final normalized = cents / 100;
    if (normalized == normalized.roundToDouble()) {
      return normalized.round().toString();
    }
    final s = normalized.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static double? parseAmount(String buffer) {
    if (buffer.isEmpty || buffer == initial || buffer == '.' || buffer.endsWith('.')) {
      return double.tryParse(buffer.endsWith('.') ? buffer.substring(0, buffer.length - 1) : buffer);
    }
    return double.tryParse(buffer);
  }
}
