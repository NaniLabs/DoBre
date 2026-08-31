import 'package:dobre/models/app_config.dart';
import 'package:dobre/models/calculation_breakdown.dart';
import 'package:dobre/models/calculation_options.dart';
import 'package:dobre/models/calculator_settings.dart';

class PricingCalculator {
  const PricingCalculator();

  double calculateReceived({
    required double publishedPrice,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
    if (publishedPrice <= 0) {
      return 0.0;
    }

    final commissionCost = _calculateCommission(
      publishedPrice: publishedPrice,
      settings: settings,
      options: options,
    );
    final fixedCharge = _calculateFixedCharge(
      publishedPrice: publishedPrice,
      settings: settings,
    );
    final installmentCost = _calculateInstallmentCost(
      publishedPrice: publishedPrice,
      settings: settings,
      options: options,
    );
    final shippingCost = _calculateShippingCost(
      publishedPrice: publishedPrice,
      settings: settings,
      options: options,
    );
    final unitCost = _calculateUnitCost(
      publishedPrice: publishedPrice,
      settings: settings,
    );

    return publishedPrice -
        commissionCost -
        fixedCharge -
        installmentCost -
        shippingCost -
        unitCost;
  }

  CalculationBreakdown getBreakdown({
    required double publishedPrice,
    required double targetNetAmount,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
    final commissionRate = settings.commissionRateFor(
      categoryId: options.categoryId,
      publicationTypeId: options.publicationTypeId,
    );
    final commissionAmount = publishedPrice * commissionRate;

    final installmentRate = settings.installmentRateFor(
      options.installmentOptionId,
    );
    final installmentAmount = publishedPrice * installmentRate;

    final fixedChargeAmount = _calculateFixedCharge(
      publishedPrice: publishedPrice,
      settings: settings,
    );

    final shippingAmount = _calculateShippingCost(
      publishedPrice: publishedPrice,
      settings: settings,
      options: options,
    );

    final unitCostAmount = _calculateUnitCost(
      publishedPrice: publishedPrice,
      settings: settings,
    );

    final actualReceived =
        publishedPrice -
        commissionAmount -
        installmentAmount -
        shippingAmount -
        fixedChargeAmount -
        unitCostAmount;

    return CalculationBreakdown(
      publishedPrice: publishedPrice,
      targetNetAmount: targetNetAmount,
      actualReceived: actualReceived,
      commissionRate: commissionRate,
      commissionAmount: commissionAmount,
      installmentRate: installmentRate,
      installmentAmount: installmentAmount,
      shippingAmount: shippingAmount,
      fixedChargeAmount: fixedChargeAmount,
      unitCostAmount: unitCostAmount,
    );
  }

  double findOptimalPrice({
    required double targetNetAmount,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
    if (targetNetAmount <= 0) {
      return 0.0;
    }

    // Aseguramos una cota superior suficientemente grande para cubrir costos fijos,
    // envíos elevados y deducciones porcentuales combinadas.
    var minimum = 0.0;
    var maximum = targetNetAmount > 0 ? targetNetAmount * 2 : 1000.0;
    maximum += 100000.0; // Margen para absorber costos fijos y envíos pesados

    // Expandir dinámicamente si aún no cubre el objetivo
    var expansionCount = 0;
    while (calculateReceived(
              publishedPrice: maximum,
              settings: settings,
              options: options,
            ) <
            targetNetAmount &&
        expansionCount < 20 &&
        maximum < settings.maxAllowedPrice) {
      maximum = (maximum * 2).clamp(0.0, settings.maxAllowedPrice);
      expansionCount++;
    }

    var iterations = 0;
    while ((maximum - minimum) > 0.005 && iterations < 80) {
      iterations++;
      final mid = (minimum + maximum) / 2;
      final received = calculateReceived(
        publishedPrice: mid,
        settings: settings,
        options: options,
      );

      if (received < targetNetAmount) {
        minimum = mid;
      } else {
        maximum = mid;
      }
    }

    return maximum;
  }

  double _calculateCommission({
    required double publishedPrice,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
    final commissionRate = settings.commissionRateFor(
      categoryId: options.categoryId,
      publicationTypeId: options.publicationTypeId,
    );

    return publishedPrice * commissionRate;
  }

  double _calculateFixedCharge({
    required double publishedPrice,
    required CalculatorSettings settings,
  }) {
    return settings.fixedChargeFor(publishedPrice);
  }

  double _calculateInstallmentCost({
    required double publishedPrice,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
    final installmentRate = settings.installmentRateFor(
      options.installmentOptionId,
    );
    return publishedPrice * installmentRate;
  }

  double _calculateShippingCost({
    required double publishedPrice,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
    if (!options.freeShipping) {
      return 0.0;
    }

    final shippingTier = settings.shippingTierFor(options.weightKg);

    if (publishedPrice < settings.freeShippingThreshold) {
      return shippingTier.below33000;
    }

    if (publishedPrice < ShippingConfig.highPriceShippingThreshold) {
      return shippingTier.between33000And49999;
    }

    return shippingTier.above50000;
  }

  double _calculateUnitCost({
    required double publishedPrice,
    required CalculatorSettings settings,
  }) {
    if (publishedPrice < settings.freeShippingThreshold) {
      return settings.unitCostBelowThreshold;
    }

    return 0.0;
  }
}
