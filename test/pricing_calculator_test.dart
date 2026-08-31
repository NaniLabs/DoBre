import 'dart:convert';
import 'package:dobre/models/app_config.dart';
import 'package:dobre/models/calculation_options.dart';
import 'package:dobre/models/calculator_settings.dart';
import 'package:dobre/services/pricing_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleConfigJson = '''
  {
    "version": "2026.07.17",
    "lastUpdate": "2026-07-17T00:00:00Z",
    "message": null,
    "maintenanceMode": false,
    "minimumSupportedVersion": "0.1.1",
    "publicationTypes": [
      {"id": "classic", "name": "Clásica"},
      {"id": "premium", "name": "Premium"}
    ],
    "tariffs": {
      "sellerFeeRate": 0.14,
      "unitCostBelowThreshold": 2800.0
    },
    "percentages": {
      "sellerFeeRate": 0.14
    },
    "fixedCharges": [
      {"maxPrice": 12000, "charge": 900},
      {"maxPrice": 33000, "charge": 1800},
      {"maxPrice": null, "charge": 0}
    ],
    "shipping": {
      "freeShippingThreshold": 33000.0,
      "weightTable": [
        {
          "maxWeight": 1.0,
          "below33000": 9800,
          "between33000And49999": 7000,
          "above50000": 7470
        },
        {
          "maxWeight": 5.0,
          "below33000": 14070,
          "between33000And49999": 10050,
          "above50000": 10760
        }
      ]
    },
    "installments": {
      "defaultOptionId": "5",
      "options": [
        {"id": "0", "label": "3-12 con interés", "rate": 0.05},
        {"id": "2", "label": "6 sin interés", "rate": 0.123},
        {"id": "5", "label": "Sin cuotas", "rate": 0.0}
      ]
    },
    "categories": [
      {
        "id": "electronics",
        "name": "Electrónica, Audio y Video",
        "fees": {"classic": 0.15, "premium": 0.1714}
      },
      {
        "id": "computing",
        "name": "Computación",
        "fees": {"classic": 0.14, "premium": 0.17}
      }
    ],
    "advancedMode": {
      "enabledByDefault": false,
      "parameters": {"notes": "Test notes"}
    },
    "input": {
      "minAllowedPrice": 1000.0,
      "maxAllowedPrice": 999999999.0
    }
  }
  ''';

  late AppConfig config;
  late CalculatorSettings settings;
  const calculator = PricingCalculator();

  setUp(() {
    config = AppConfig.fromJson(
      jsonDecode(sampleConfigJson) as Map<String, dynamic>,
    );
    settings = CalculatorSettings.fromConfig(config);
  });

  group('PricingCalculator direct calculation (calculateReceived)', () {
    test('Returns 0 when publishedPrice <= 0', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: false,
      );

      expect(
        calculator.calculateReceived(
          publishedPrice: 0,
          settings: settings,
          options: options,
        ),
        0.0,
      );
      expect(
        calculator.calculateReceived(
          publishedPrice: -100,
          settings: settings,
          options: options,
        ),
        0.0,
      );
    });

    test('Calculates correctly below shipping threshold without free shipping', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: false,
      );

      // Price: 10,000 (< 12,000)
      // Commission: 15% of 10,000 = 1,500
      // Fixed charge: 900 (< 12,000)
      // Unit cost: 2,800 (< 33,000)
      // Installments: 0% = 0
      // Shipping: 0 (freeShipping is false)
      // Total deductions: 1,500 + 900 + 2,800 = 5,200
      // Net received: 10,000 - 5,200 = 4,800
      final received = calculator.calculateReceived(
        publishedPrice: 10000,
        settings: settings,
        options: options,
      );
      expect(received, closeTo(4800.0, 0.001));
    });

    test('Calculates correctly above shipping threshold with free shipping', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: true,
      );

      // Price: 40,000 (between 33,000 and 49,999)
      // Commission: 15% of 40,000 = 6,000
      // Fixed charge: 0 (> 33,000)
      // Unit cost: 0 (>= 33,000)
      // Shipping: 7,000 (tier 1kg, between 33,000 and 49,999)
      // Net received: 40,000 - 6,000 - 7,000 = 27,000
      final received = calculator.calculateReceived(
        publishedPrice: 40000,
        settings: settings,
        options: options,
      );
      expect(received, closeTo(27000.0, 0.001));
    });
  });

  group('PricingCalculator inverse calculation (findOptimalPrice)', () {
    test('Returns 0 for targetNetAmount <= 0', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: false,
      );

      expect(
        calculator.findOptimalPrice(
          targetNetAmount: 0,
          settings: settings,
          options: options,
        ),
        0.0,
      );
      expect(
        calculator.findOptimalPrice(
          targetNetAmount: -500,
          settings: settings,
          options: options,
        ),
        0.0,
      );
    });

    test('Solves low target amount where fixed costs exceed 3x target amount', () {
      // Small target net amount ($1,500) with free shipping enabled ($9,800) and unit costs ($2,800) + fixed charge ($900)
      // Required price is much greater than 3 * 1,500 ($4,500)
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: true,
      );

      const target = 1500.0;
      final price = calculator.findOptimalPrice(
        targetNetAmount: target,
        settings: settings,
        options: options,
      );

      final received = calculator.calculateReceived(
        publishedPrice: price,
        settings: settings,
        options: options,
      );

      expect(received, greaterThanOrEqualTo(target));
      expect((received - target).abs(), lessThan(0.05));
    });

    test('Solves target net amount \$50,000 accurately', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: true,
      );

      const target = 50000.0;
      final price = calculator.findOptimalPrice(
        targetNetAmount: target,
        settings: settings,
        options: options,
      );

      final received = calculator.calculateReceived(
        publishedPrice: price,
        settings: settings,
        options: options,
      );

      expect(received, greaterThanOrEqualTo(target));
      expect((received - target).abs(), lessThan(0.05));
    });

    test('Solves target with 6 cuotas sin interés (installment financing)', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'premium',
        weightKg: 5.0,
        installmentOptionId: '2', // 12.3% rate
        freeShipping: true,
      );

      const target = 80000.0;
      final price = calculator.findOptimalPrice(
        targetNetAmount: target,
        settings: settings,
        options: options,
      );

      final received = calculator.calculateReceived(
        publishedPrice: price,
        settings: settings,
        options: options,
      );

      expect(received, greaterThanOrEqualTo(target));
      expect((received - target).abs(), lessThan(0.05));
    });

    test('Solves extremely low target amounts (\$1, \$10, \$100) without NaN or Infinity', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: false,
      );

      for (final target in [1.0, 10.0, 100.0]) {
        final price = calculator.findOptimalPrice(
          targetNetAmount: target,
          settings: settings,
          options: options,
        );

        expect(price.isNaN, isFalse);
        expect(price.isInfinite, isFalse);
        expect(price, greaterThan(0));

        final received = calculator.calculateReceived(
          publishedPrice: price,
          settings: settings,
          options: options,
        );
        expect(received, greaterThanOrEqualTo(target));
        expect((received - target).abs(), lessThan(0.05));
      }
    });

    test('Solves high target amounts (\$500.000, \$5.000.000) accurately', () {
      const options = CalculationOptions(
        categoryId: 'computing',
        publicationTypeId: 'classic',
        weightKg: 2.0,
        installmentOptionId: '0', // 5%
        freeShipping: true,
      );

      for (final target in [500000.0, 5000000.0]) {
        final price = calculator.findOptimalPrice(
          targetNetAmount: target,
          settings: settings,
          options: options,
        );

        expect(price.isNaN, isFalse);
        expect(price.isInfinite, isFalse);

        final received = calculator.calculateReceived(
          publishedPrice: price,
          settings: settings,
          options: options,
        );
        expect(received, greaterThanOrEqualTo(target));
        expect((received - target).abs(), lessThan(0.05));
      }
    });

    test('Solves decimal target amounts (\$35.450,75) accurately', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '5',
        freeShipping: true,
      );

      const target = 35450.75;
      final price = calculator.findOptimalPrice(
        targetNetAmount: target,
        settings: settings,
        options: options,
      );

      final received = calculator.calculateReceived(
        publishedPrice: price,
        settings: settings,
        options: options,
      );

      expect(received, greaterThanOrEqualTo(target));
      expect((received - target).abs(), lessThan(0.05));
    });
  });

  group('PricingCalculator getBreakdown', () {
    test('Provides exact breakdown matching deductions and net received', () {
      const options = CalculationOptions(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
        weightKg: 1.0,
        installmentOptionId: '2', // 12.3%
        freeShipping: true,
      );

      const target = 35000.0;
      final price = calculator.findOptimalPrice(
        targetNetAmount: target,
        settings: settings,
        options: options,
      );

      final breakdown = calculator.getBreakdown(
        publishedPrice: price,
        targetNetAmount: target,
        settings: settings,
        options: options,
      );

      expect(breakdown.publishedPrice, price);
      expect(breakdown.targetNetAmount, target);
      expect(breakdown.commissionRate, 0.15);
      expect(breakdown.installmentRate, 0.123);
      expect(
        breakdown.totalDeductions,
        closeTo(breakdown.publishedPrice - breakdown.actualReceived, 0.01),
      );
      expect(breakdown.actualReceived, greaterThanOrEqualTo(target));
      expect((breakdown.actualReceived - target).abs(), lessThan(0.05));
    });
  });
}
