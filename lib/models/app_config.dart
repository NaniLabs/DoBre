import 'dart:convert';

import 'package:dobre/models/calculation_options.dart';
import 'package:dobre/models/calculator_settings.dart';

class AppConfig {
  const AppConfig({
    required this.version,
    required this.lastUpdate,
    required this.message,
    required this.maintenanceMode,
    required this.minimumSupportedVersion,
    required this.publicationTypes,
    required this.tariffs,
    required this.percentages,
    required this.fixedCharges,
    required this.shipping,
    required this.installments,
    required this.categories,
    required this.advancedMode,
    required this.input,
  });

  final String version;
  final DateTime? lastUpdate;
  final String? message;
  final bool maintenanceMode;
  final String minimumSupportedVersion;
  final List<PublicationTypeConfig> publicationTypes;
  final TariffsConfig tariffs;
  final PercentagesConfig percentages;
  final List<FixedChargeConfig> fixedCharges;
  final ShippingConfig shipping;
  final InstallmentConfig installments;
  final List<CategoryConfig> categories;
  final AdvancedModeConfig advancedMode;
  final InputConfig input;

  CalculatorSettings get calculatorSettings =>
      CalculatorSettings.fromConfig(this);

  CalculationOptions get defaultAdvancedOptions {
    final defaultCategoryId = categories.isNotEmpty ? categories.first.id : '';
    final defaultPublicationTypeId = publicationTypes.isNotEmpty
        ? publicationTypes.first.id
        : '';
    final defaultWeight = shipping.weightTable.isNotEmpty
        ? shipping.weightTable.first.maxWeight
        : 0.0;

    return CalculationOptions(
      categoryId: defaultCategoryId,
      publicationTypeId: defaultPublicationTypeId,
      weightKg: defaultWeight,
      installmentOptionId: installments.defaultOptionId,
      freeShipping: false,
    );
  }

  CalculationOptions get basicModeOptions {
    var worstPublicationTypeId = publicationTypes.isNotEmpty
        ? publicationTypes.first.id
        : '';
    var worstCategoryId = categories.isNotEmpty ? categories.first.id : '';
    var worstFeeRate = tariffs.sellerFeeRate;

    for (final category in categories) {
      for (final publicationType in publicationTypes) {
        final feeRate = category.fees.rateFor(publicationType.id);
        if (feeRate > worstFeeRate) {
          worstFeeRate = feeRate;
          worstCategoryId = category.id;
          worstPublicationTypeId = publicationType.id;
        }
      }
    }

    final worstInstallmentOption = installments.options.isEmpty
        ? null
        : installments.options.reduce(
            (current, next) => next.rate > current.rate ? next : current,
          );

    final worstWeight = shipping.weightTable.isEmpty
        ? 0.0
        : shipping.weightTable.last.maxWeight;

    return CalculationOptions(
      categoryId: worstCategoryId,
      publicationTypeId: worstPublicationTypeId,
      weightKg: worstWeight,
      installmentOptionId:
          worstInstallmentOption?.id ?? installments.defaultOptionId,
      freeShipping: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdate': lastUpdate?.toIso8601String(),
      'message': message,
      'maintenanceMode': maintenanceMode,
      'minimumSupportedVersion': minimumSupportedVersion,
      'publicationTypes': publicationTypes
          .map((publicationType) => publicationType.toJson())
          .toList(),
      'tariffs': tariffs.toJson(),
      'percentages': percentages.toJson(),
      'fixedCharges': fixedCharges.map((charge) => charge.toJson()).toList(),
      'shipping': shipping.toJson(),
      'installments': installments.toJson(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'advancedMode': advancedMode.toJson(),
      'input': input.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      version: json['version']?.toString() ?? '0.0.0',
      lastUpdate: _parseDate(json['lastUpdate']),
      message: json['message']?.toString(),
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      minimumSupportedVersion:
          json['minimumSupportedVersion']?.toString() ?? '0.0.0',
      publicationTypes: _parseList(
        json['publicationTypes'],
        PublicationTypeConfig.fromJson,
      ),
      tariffs: TariffsConfig.fromJson(_asMap(json['tariffs'])),
      percentages: PercentagesConfig.fromJson(_asMap(json['percentages'])),
      fixedCharges: _parseList(
        json['fixedCharges'],
        FixedChargeConfig.fromJson,
      ),
      shipping: ShippingConfig.fromJson(_asMap(json['shipping'])),
      installments: InstallmentConfig.fromJson(_asMap(json['installments'])),
      categories: _parseList(json['categories'], CategoryConfig.fromJson),
      advancedMode: AdvancedModeConfig.fromJson(_asMap(json['advancedMode'])),
      input: InputConfig.fromJson(_asMap(json['input'])),
    );
  }

  factory AppConfig.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Remote config must be a JSON map.');
    }

    return AppConfig.fromJson(decoded);
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }

    return const <String, dynamic>{};
  }

  static List<T> _parseList<T>(
    Object? value,
    T Function(Map<String, dynamic> json) parser,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((entry) => parser(_asMap(entry)))
        .toList(growable: false);
  }

  static double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}

class PublicationTypeConfig {
  const PublicationTypeConfig({required this.id, required this.name});

  final String id;
  final String name;

  PublicationTypeConfig copyWith({String? id, String? name}) {
    return PublicationTypeConfig(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory PublicationTypeConfig.fromJson(Map<String, dynamic> json) {
    return PublicationTypeConfig(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class TariffsConfig {
  const TariffsConfig({
    required this.sellerFeeRate,
    required this.unitCostBelowThreshold,
  });

  final double sellerFeeRate;
  final double unitCostBelowThreshold;

  TariffsConfig copyWith({
    double? sellerFeeRate,
    double? unitCostBelowThreshold,
  }) {
    return TariffsConfig(
      sellerFeeRate: sellerFeeRate ?? this.sellerFeeRate,
      unitCostBelowThreshold:
          unitCostBelowThreshold ?? this.unitCostBelowThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
    'sellerFeeRate': sellerFeeRate,
    'unitCostBelowThreshold': unitCostBelowThreshold,
  };

  factory TariffsConfig.fromJson(Map<String, dynamic> json) {
    return TariffsConfig(
      sellerFeeRate: AppConfig._readDouble(json['sellerFeeRate']),
      unitCostBelowThreshold: AppConfig._readDouble(
        json['unitCostBelowThreshold'],
      ),
    );
  }
}

class PercentagesConfig {
  const PercentagesConfig({required this.sellerFeeRate});

  final double sellerFeeRate;

  PercentagesConfig copyWith({double? sellerFeeRate}) {
    return PercentagesConfig(
      sellerFeeRate: sellerFeeRate ?? this.sellerFeeRate,
    );
  }

  Map<String, dynamic> toJson() => {'sellerFeeRate': sellerFeeRate};

  factory PercentagesConfig.fromJson(Map<String, dynamic> json) {
    return PercentagesConfig(
      sellerFeeRate: AppConfig._readDouble(json['sellerFeeRate']),
    );
  }
}

class FixedChargeConfig {
  const FixedChargeConfig({required this.maxPrice, required this.charge});

  final double? maxPrice;
  final double charge;

  FixedChargeConfig copyWith({
    double? maxPrice,
    double? charge,
    bool keepNullMaxPrice = false,
  }) {
    return FixedChargeConfig(
      maxPrice: keepNullMaxPrice ? null : (maxPrice ?? this.maxPrice),
      charge: charge ?? this.charge,
    );
  }

  Map<String, dynamic> toJson() => {'maxPrice': maxPrice, 'charge': charge};

  factory FixedChargeConfig.fromJson(Map<String, dynamic> json) {
    final maxPriceValue = json['maxPrice'];
    return FixedChargeConfig(
      maxPrice: maxPriceValue == null
          ? null
          : AppConfig._readDouble(maxPriceValue),
      charge: AppConfig._readDouble(json['charge']),
    );
  }
}

class ShippingConfig {
  const ShippingConfig({
    required this.freeShippingThreshold,
    required this.weightTable,
  });

  static const highPriceShippingThreshold = 50000.0;

  final double freeShippingThreshold;
  final List<ShippingWeightRateConfig> weightTable;

  ShippingConfig copyWith({
    double? freeShippingThreshold,
    List<ShippingWeightRateConfig>? weightTable,
  }) {
    return ShippingConfig(
      freeShippingThreshold:
          freeShippingThreshold ?? this.freeShippingThreshold,
      weightTable: weightTable ?? this.weightTable,
    );
  }

  Map<String, dynamic> toJson() => {
    'freeShippingThreshold': freeShippingThreshold,
    'weightTable': weightTable.map((entry) => entry.toJson()).toList(),
  };

  factory ShippingConfig.fromJson(Map<String, dynamic> json) {
    return ShippingConfig(
      freeShippingThreshold: AppConfig._readDouble(
        json['freeShippingThreshold'],
      ),
      weightTable: AppConfig._parseList(
        json['weightTable'],
        ShippingWeightRateConfig.fromJson,
      ),
    );
  }
}

class ShippingWeightRateConfig {
  const ShippingWeightRateConfig({
    required this.maxWeight,
    required this.below33000,
    required this.between33000And49999,
    required this.above50000,
  });

  final double maxWeight;
  final double below33000;
  final double between33000And49999;
  final double above50000;

  ShippingWeightRateConfig copyWith({
    double? maxWeight,
    double? below33000,
    double? between33000And49999,
    double? above50000,
  }) {
    return ShippingWeightRateConfig(
      maxWeight: maxWeight ?? this.maxWeight,
      below33000: below33000 ?? this.below33000,
      between33000And49999: between33000And49999 ?? this.between33000And49999,
      above50000: above50000 ?? this.above50000,
    );
  }

  Map<String, dynamic> toJson() => {
    'maxWeight': maxWeight,
    'below33000': below33000,
    'between33000And49999': between33000And49999,
    'above50000': above50000,
  };

  factory ShippingWeightRateConfig.fromJson(Map<String, dynamic> json) {
    return ShippingWeightRateConfig(
      maxWeight: AppConfig._readDouble(json['maxWeight']),
      below33000: AppConfig._readDouble(json['below33000']),
      between33000And49999: AppConfig._readDouble(json['between33000And49999']),
      above50000: AppConfig._readDouble(json['above50000']),
    );
  }
}

class InstallmentConfig {
  const InstallmentConfig({
    required this.defaultOptionId,
    required this.options,
  });

  final String defaultOptionId;
  final List<InstallmentOption> options;

  InstallmentConfig copyWith({
    String? defaultOptionId,
    List<InstallmentOption>? options,
  }) {
    return InstallmentConfig(
      defaultOptionId: defaultOptionId ?? this.defaultOptionId,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toJson() => {
    'defaultOptionId': defaultOptionId,
    'options': options.map((option) => option.toJson()).toList(),
  };

  factory InstallmentConfig.fromJson(Map<String, dynamic> json) {
    return InstallmentConfig(
      defaultOptionId: json['defaultOptionId']?.toString() ?? '',
      options: AppConfig._parseList(
        json['options'],
        InstallmentOption.fromJson,
      ),
    );
  }
}

class InstallmentOption {
  const InstallmentOption({
    required this.id,
    required this.label,
    required this.rate,
  });

  final String id;
  final String label;
  final double rate;

  InstallmentOption copyWith({String? id, String? label, double? rate}) {
    return InstallmentOption(
      id: id ?? this.id,
      label: label ?? this.label,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'rate': rate};

  factory InstallmentOption.fromJson(Map<String, dynamic> json) {
    return InstallmentOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      rate: AppConfig._readDouble(json['rate']),
    );
  }
}

class CategoryConfig {
  const CategoryConfig({
    required this.id,
    required this.name,
    required this.fees,
  });

  final String id;
  final String name;
  final CategoryFeesConfig fees;

  CategoryConfig copyWith({
    String? id,
    String? name,
    CategoryFeesConfig? fees,
  }) {
    return CategoryConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      fees: fees ?? this.fees,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'fees': fees.toJson(),
  };

  factory CategoryConfig.fromJson(Map<String, dynamic> json) {
    return CategoryConfig(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fees: CategoryFeesConfig.fromJson(AppConfig._asMap(json['fees'])),
    );
  }
}

class CategoryFeesConfig {
  const CategoryFeesConfig({required this.classic, required this.premium});

  final double classic;
  final double premium;

  CategoryFeesConfig copyWith({double? classic, double? premium}) {
    return CategoryFeesConfig(
      classic: classic ?? this.classic,
      premium: premium ?? this.premium,
    );
  }

  double rateFor(String publicationTypeId) {
    switch (publicationTypeId) {
      case 'premium':
        return premium;
      case 'classic':
      default:
        return classic;
    }
  }

  Map<String, dynamic> toJson() => {'classic': classic, 'premium': premium};

  factory CategoryFeesConfig.fromJson(Map<String, dynamic> json) {
    return CategoryFeesConfig(
      classic: AppConfig._readDouble(json['classic']),
      premium: AppConfig._readDouble(json['premium']),
    );
  }
}

class AdvancedModeConfig {
  const AdvancedModeConfig({
    required this.enabledByDefault,
    required this.parameters,
  });

  final bool enabledByDefault;
  final AdvancedModeParameters parameters;

  AdvancedModeConfig copyWith({
    bool? enabledByDefault,
    AdvancedModeParameters? parameters,
  }) {
    return AdvancedModeConfig(
      enabledByDefault: enabledByDefault ?? this.enabledByDefault,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabledByDefault': enabledByDefault,
    'parameters': parameters.toJson(),
  };

  factory AdvancedModeConfig.fromJson(Map<String, dynamic> json) {
    return AdvancedModeConfig(
      enabledByDefault: json['enabledByDefault'] as bool? ?? false,
      parameters: AdvancedModeParameters.fromJson(
        AppConfig._asMap(json['parameters']),
      ),
    );
  }
}

class AdvancedModeParameters {
  const AdvancedModeParameters({required this.notes});

  final String notes;

  AdvancedModeParameters copyWith({String? notes}) {
    return AdvancedModeParameters(notes: notes ?? this.notes);
  }

  bool get isNotEmpty => notes.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {'notes': notes};

  factory AdvancedModeParameters.fromJson(Map<String, dynamic> json) {
    return AdvancedModeParameters(notes: json['notes']?.toString() ?? '');
  }
}

class InputConfig {
  const InputConfig({
    required this.minAllowedPrice,
    required this.maxAllowedPrice,
  });

  final double minAllowedPrice;
  final double maxAllowedPrice;

  InputConfig copyWith({double? minAllowedPrice, double? maxAllowedPrice}) {
    return InputConfig(
      minAllowedPrice: minAllowedPrice ?? this.minAllowedPrice,
      maxAllowedPrice: maxAllowedPrice ?? this.maxAllowedPrice,
    );
  }

  Map<String, dynamic> toJson() => {
    'minAllowedPrice': minAllowedPrice,
    'maxAllowedPrice': maxAllowedPrice,
  };

  factory InputConfig.fromJson(Map<String, dynamic> json) {
    return InputConfig(
      minAllowedPrice: AppConfig._readDouble(json['minAllowedPrice']),
      maxAllowedPrice: AppConfig._readDouble(json['maxAllowedPrice']),
    );
  }
}
