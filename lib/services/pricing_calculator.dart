import 'package:dobre/models/app_config.dart';
import 'package:dobre/models/calculation_options.dart';
import 'package:dobre/models/calculator_settings.dart';

class PricingCalculator {
  const PricingCalculator();

  double calculateReceived({
    required double publishedPrice,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
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

  double findOptimalPrice({
    required double targetNetAmount,
    required CalculatorSettings settings,
    required CalculationOptions options,
  }) {
    var minimum = targetNetAmount;
    var maximum = targetNetAmount * 3;

    while ((maximum - minimum) > 0.01) {
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
