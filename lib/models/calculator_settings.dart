import 'package:dobre/models/app_config.dart';

class CalculatorSettings {
  const CalculatorSettings({
    required this.publicationTypes,
    required this.sellerFeeRate,
    required this.unitCostBelowThreshold,
    required this.fixedCharges,
    required this.freeShippingThreshold,
    required this.shippingWeightTable,
    required this.installmentOptions,
    required this.categories,
    required this.minAllowedPrice,
    required this.maxAllowedPrice,
  });

  final List<PublicationTypeConfig> publicationTypes;
  final double sellerFeeRate;
  final double unitCostBelowThreshold;
  final List<FixedChargeConfig> fixedCharges;
  final double freeShippingThreshold;
  final List<ShippingWeightRateConfig> shippingWeightTable;
  final List<InstallmentOption> installmentOptions;
  final List<CategoryConfig> categories;
  final double minAllowedPrice;
  final double maxAllowedPrice;

  factory CalculatorSettings.fromConfig(AppConfig config) {
    return CalculatorSettings(
      publicationTypes: config.publicationTypes,
      sellerFeeRate: config.tariffs.sellerFeeRate,
      unitCostBelowThreshold: config.tariffs.unitCostBelowThreshold,
      fixedCharges: config.fixedCharges,
      freeShippingThreshold: config.shipping.freeShippingThreshold,
      shippingWeightTable: config.shipping.weightTable,
      installmentOptions: config.installments.options,
      categories: config.categories,
      minAllowedPrice: config.input.minAllowedPrice,
      maxAllowedPrice: config.input.maxAllowedPrice,
    );
  }

  CalculatorSettings copyWith({
    List<PublicationTypeConfig>? publicationTypes,
    double? sellerFeeRate,
    double? unitCostBelowThreshold,
    List<FixedChargeConfig>? fixedCharges,
    double? freeShippingThreshold,
    List<ShippingWeightRateConfig>? shippingWeightTable,
    List<InstallmentOption>? installmentOptions,
    List<CategoryConfig>? categories,
    double? minAllowedPrice,
    double? maxAllowedPrice,
  }) {
    return CalculatorSettings(
      publicationTypes: publicationTypes ?? this.publicationTypes,
      sellerFeeRate: sellerFeeRate ?? this.sellerFeeRate,
      unitCostBelowThreshold:
          unitCostBelowThreshold ?? this.unitCostBelowThreshold,
      fixedCharges: fixedCharges ?? this.fixedCharges,
      freeShippingThreshold:
          freeShippingThreshold ?? this.freeShippingThreshold,
      shippingWeightTable: shippingWeightTable ?? this.shippingWeightTable,
      installmentOptions: installmentOptions ?? this.installmentOptions,
      categories: categories ?? this.categories,
      minAllowedPrice: minAllowedPrice ?? this.minAllowedPrice,
      maxAllowedPrice: maxAllowedPrice ?? this.maxAllowedPrice,
    );
  }

  double installmentRateFor(String installmentOptionId) {
    return installmentOptions
            .where((option) => option.id == installmentOptionId)
            .map((option) => option.rate)
            .cast<double?>()
            .firstOrNull ??
        0.0;
  }

  double commissionRateFor({
    required String categoryId,
    required String publicationTypeId,
  }) {
    final category = categories
        .where((entry) => entry.id == categoryId)
        .cast<CategoryConfig?>()
        .firstOrNull;

    if (category == null) {
      return sellerFeeRate;
    }

    return category.fees.rateFor(publicationTypeId);
  }

  double fixedChargeFor(double publishedPrice) {
    for (final fixedCharge in fixedCharges) {
      final maxPrice = fixedCharge.maxPrice;
      if (maxPrice == null || publishedPrice <= maxPrice) {
        return fixedCharge.charge;
      }
    }

    return 0.0;
  }

  ShippingWeightRateConfig shippingTierFor(double weightKg) {
    for (final tier in shippingWeightTable) {
      if (weightKg <= tier.maxWeight) {
        return tier;
      }
    }

    return shippingWeightTable.isNotEmpty
        ? shippingWeightTable.last
        : const ShippingWeightRateConfig(
            maxWeight: 0.0,
            below33000: 0.0,
            between33000And49999: 0.0,
            above50000: 0.0,
          );
  }
}
