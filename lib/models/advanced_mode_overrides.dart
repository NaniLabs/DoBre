import 'dart:convert';

import 'package:dobre/models/calculator_settings.dart';

class AdvancedModeOverrides {
  const AdvancedModeOverrides({
    this.sellerFeeRate,
    this.unitCostBelowThreshold,
    this.freeShippingThreshold,
    this.minAllowedPrice,
    this.maxAllowedPrice,
    this.installmentRates = const {},
  });

  final double? sellerFeeRate;
  final double? unitCostBelowThreshold;
  final double? freeShippingThreshold;
  final double? minAllowedPrice;
  final double? maxAllowedPrice;
  final Map<String, double> installmentRates;

  bool get isEmpty =>
      sellerFeeRate == null &&
      unitCostBelowThreshold == null &&
      freeShippingThreshold == null &&
      minAllowedPrice == null &&
      maxAllowedPrice == null &&
      installmentRates.isEmpty;

  CalculatorSettings applyTo(CalculatorSettings base) {
    final overriddenInstallments = installmentRates.isEmpty
        ? base.installmentOptions
        : base.installmentOptions
              .map(
                (option) => option.copyWith(
                  rate: installmentRates[option.id] ?? option.rate,
                ),
              )
              .toList(growable: false);

    return base.copyWith(
      sellerFeeRate: sellerFeeRate,
      unitCostBelowThreshold: unitCostBelowThreshold,
      freeShippingThreshold: freeShippingThreshold,
      installmentOptions: overriddenInstallments,
      minAllowedPrice: minAllowedPrice,
      maxAllowedPrice: maxAllowedPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sellerFeeRate': sellerFeeRate,
      'unitCostBelowThreshold': unitCostBelowThreshold,
      'freeShippingThreshold': freeShippingThreshold,
      'minAllowedPrice': minAllowedPrice,
      'maxAllowedPrice': maxAllowedPrice,
      'installmentRates': installmentRates,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AdvancedModeOverrides.fromJson(Map<String, dynamic> json) {
    return AdvancedModeOverrides(
      sellerFeeRate: _toDouble(json['sellerFeeRate']),
      unitCostBelowThreshold: _toDouble(json['unitCostBelowThreshold']),
      freeShippingThreshold: _toDouble(json['freeShippingThreshold']),
      minAllowedPrice: _toDouble(json['minAllowedPrice']),
      maxAllowedPrice: _toDouble(json['maxAllowedPrice']),
      installmentRates: _toDoubleMap(json['installmentRates']),
    );
  }

  factory AdvancedModeOverrides.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Advanced mode overrides must be a JSON map.',
      );
    }

    return AdvancedModeOverrides.fromJson(decoded);
  }

  static double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  static Map<String, double> _toDoubleMap(Object? value) {
    if (value is! Map) {
      return const {};
    }

    final result = <String, double>{};
    for (final entry in value.entries) {
      final parsed = _toDouble(entry.value);
      if (parsed != null) {
        result[entry.key.toString()] = parsed;
      }
    }
    return result;
  }
}
