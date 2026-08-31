class CurrencyUtils {
  const CurrencyUtils._();

  /// Formatea un monto numérico según la convención argentina/hispana:
  /// Separador de miles con punto (.) y decimales con coma (,).
  ///
  /// Ejemplos:
  /// - 35000 -> "$ 35.000"
  /// - 63619.45 -> "$ 63.619,45"
  /// - 1500 -> "$ 1.500"
  static String format(
    double amount, {
    bool includeDecimals = false,
    bool spaceAfterSymbol = true,
  }) {
    if (amount.isNaN || amount.isInfinite) {
      return spaceAfterSymbol ? '\$ 0' : '\$0';
    }

    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final integerPart = absAmount.floor();
    final decimalPart = ((absAmount - integerPart) * 100).round();

    final digits = integerPart.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    var formatted = buffer.toString();
    if (includeDecimals && decimalPart > 0) {
      final decStr = decimalPart.toString().padLeft(2, '0');
      formatted += ',$decStr';
    }

    final prefix = spaceAfterSymbol ? '\$ ' : '\$';
    return isNegative ? '-$prefix$formatted' : '$prefix$formatted';
  }

  /// Parsea un texto ingresado por el usuario a [double] de forma robusta.
  /// Acepta texto con '$', puntos de miles, comas decimales o puntos decimales.
  ///
  /// Ejemplos soportados:
  /// - "35000" -> 35000.0
  /// - "35.000" -> 35000.0
  /// - "35000,50" -> 35000.5
  /// - "35.000,50" -> 35000.5
  /// - "$ 50.000" -> 50000.0
  /// - "$ 1.250,75" -> 1250.75
  static double? parse(String? input) {
    if (input == null) {
      return null;
    }

    var cleaned = input.trim();
    if (cleaned.isEmpty) {
      return null;
    }

    // Remover símbolo de moneda y espacios
    cleaned = cleaned.replaceAll('\$', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) {
      return null;
    }

    final isNegative = cleaned.startsWith('-');
    if (isNegative) {
      cleaned = cleaned.substring(1).trim();
    }

    if (cleaned.isEmpty) {
      return null;
    }

    // Analizar puntuaciones presentes
    final hasComma = cleaned.contains(',');
    final hasDot = cleaned.contains('.');

    if (hasComma && hasDot) {
      // Caso estándar: "35.000,50" -> los puntos son miles, la coma es decimal
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');

      if (lastComma > lastDot) {
        // Formato ES/AR: 1.234.567,89
        final withoutDots = cleaned.replaceAll('.', '');
        final withDotDecimal = withoutDots.replaceAll(',', '.');
        final value = double.tryParse(withDotDecimal);
        return value == null ? null : (isNegative ? -value : value);
      } else {
        // Formato US: 1,234,567.89
        final withoutCommas = cleaned.replaceAll(',', '');
        final value = double.tryParse(withoutCommas);
        return value == null ? null : (isNegative ? -value : value);
      }
    } else if (hasComma) {
      // Solo coma: "35000,50" o "35,000"
      final parts = cleaned.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        // Decimal estándar: "35000,50"
        final value = double.tryParse('${parts[0]}.${parts[1]}');
        return value == null ? null : (isNegative ? -value : value);
      } else {
        // Puede ser separador de miles: "35,000" -> 35000
        final withoutCommas = cleaned.replaceAll(',', '');
        final value = double.tryParse(withoutCommas);
        return value == null ? null : (isNegative ? -value : value);
      }
    } else if (hasDot) {
      // Solo punto: "35.000" (miles) o "35.5" (decimal)
      final parts = cleaned.split('.');
      if (parts.length > 2) {
        // Múltiples puntos -> claramente miles: "1.000.000"
        final withoutDots = cleaned.replaceAll('.', '');
        final value = double.tryParse(withoutDots);
        return value == null ? null : (isNegative ? -value : value);
      } else if (parts.length == 2) {
        if (parts[1].length == 3) {
          // Exactamente 3 dígitos después del punto -> miles: "35.000"
          final withoutDots = cleaned.replaceAll('.', '');
          final value = double.tryParse(withoutDots);
          return value == null ? null : (isNegative ? -value : value);
        } else {
          // 1 o 2 dígitos -> decimal: "35.5" o "35.50"
          final value = double.tryParse(cleaned);
          return value == null ? null : (isNegative ? -value : value);
        }
      }
    }

    final value = double.tryParse(cleaned);
    if (value == null || value.isNaN || value.isInfinite) {
      return null;
    }

    return isNegative ? -value : value;
  }
}
