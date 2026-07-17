import 'dart:convert';

class CalculationOptions {
  const CalculationOptions({
    required this.categoryId,
    required this.publicationTypeId,
    required this.weightKg,
    required this.installmentOptionId,
    required this.freeShipping,
  });

  final String categoryId;
  final String publicationTypeId;
  final double weightKg;
  final String installmentOptionId;
  final bool freeShipping;

  CalculationOptions copyWith({
    String? categoryId,
    String? publicationTypeId,
    double? weightKg,
    String? installmentOptionId,
    bool? freeShipping,
  }) {
    return CalculationOptions(
      categoryId: categoryId ?? this.categoryId,
      publicationTypeId: publicationTypeId ?? this.publicationTypeId,
      weightKg: weightKg ?? this.weightKg,
      installmentOptionId: installmentOptionId ?? this.installmentOptionId,
      freeShipping: freeShipping ?? this.freeShipping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'publicationTypeId': publicationTypeId,
      'weightKg': weightKg,
      'installmentOptionId': installmentOptionId,
      'freeShipping': freeShipping,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory CalculationOptions.fromJson(Map<String, dynamic> json) {
    return CalculationOptions(
      categoryId: json['categoryId']?.toString() ?? '',
      publicationTypeId: json['publicationTypeId']?.toString() ?? '',
      weightKg: _toDouble(json['weightKg']),
      installmentOptionId: json['installmentOptionId']?.toString() ?? '',
      freeShipping: json['freeShipping'] as bool? ?? false,
    );
  }

  factory CalculationOptions.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('CalculationOptions must be a JSON map.');
    }

    return CalculationOptions.fromJson(decoded);
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
}
