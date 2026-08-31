import 'dart:io';
import 'package:dobre/models/advanced_mode_overrides.dart';
import 'package:dobre/models/app_config.dart';
import 'package:dobre/models/calculator_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig and CalculatorSettings unit tests', () {
    late String defaultConfigContent;

    setUpAll(() {
      final file = File('assets/config/default_config.json');
      defaultConfigContent = file.readAsStringSync();
    });

    test('Parses bundled default_config.json accurately', () {
      final config = AppConfig.fromJsonString(defaultConfigContent);

      expect(config.version, isNotEmpty);
      expect(config.categories, isNotEmpty);
      expect(config.publicationTypes, hasLength(2));
      expect(config.shipping.weightTable, isNotEmpty);
      expect(config.installments.options, isNotEmpty);
      expect(config.input.minAllowedPrice, greaterThan(0));
      expect(config.input.maxAllowedPrice, greaterThan(config.input.minAllowedPrice));
      expect(config.donations.enabled, isTrue);
      expect(config.donations.alias, 'dobre.app.mp');
    });

    test('AppConfig roundtrip serialization produces identical model', () {
      final config = AppConfig.fromJsonString(defaultConfigContent);
      final jsonString = config.toJsonString();
      final decodedConfig = AppConfig.fromJsonString(jsonString);

      expect(decodedConfig.version, config.version);
      expect(decodedConfig.categories.length, config.categories.length);
      expect(decodedConfig.tariffs.sellerFeeRate, config.tariffs.sellerFeeRate);
      expect(decodedConfig.shipping.freeShippingThreshold, config.shipping.freeShippingThreshold);
    });

    test('CalculatorSettings correctly resolves fixed charges by price bracket', () {
      final config = AppConfig.fromJsonString(defaultConfigContent);
      final settings = CalculatorSettings.fromConfig(config);

      // maxPrice: 12000 -> 900
      expect(settings.fixedChargeFor(5000), 900.0);
      expect(settings.fixedChargeFor(12000), 900.0);

      // maxPrice: 33000 -> 1800
      expect(settings.fixedChargeFor(12001), 1800.0);
      expect(settings.fixedChargeFor(33000), 1800.0);

      // maxPrice: null -> 0
      expect(settings.fixedChargeFor(33001), 0.0);
      expect(settings.fixedChargeFor(100000), 0.0);
    });

    test('CalculatorSettings correctly resolves shipping weight tiers', () {
      final config = AppConfig.fromJsonString(defaultConfigContent);
      final settings = CalculatorSettings.fromConfig(config);

      final tier0_3 = settings.shippingTierFor(0.25);
      expect(tier0_3.maxWeight, 0.3);

      final tier1_0 = settings.shippingTierFor(0.9);
      expect(tier1_0.maxWeight, 1.0);

      final tierMax = settings.shippingTierFor(9999);
      expect(tierMax.maxWeight, greaterThanOrEqualTo(180));
    });

    test('CalculatorSettings correctly resolves category commission rates', () {
      final config = AppConfig.fromJsonString(defaultConfigContent);
      final settings = CalculatorSettings.fromConfig(config);

      final electronicsClassic = settings.commissionRateFor(
        categoryId: 'electronics',
        publicationTypeId: 'classic',
      );
      expect(electronicsClassic, 0.15);

      final electronicsPremium = settings.commissionRateFor(
        categoryId: 'electronics',
        publicationTypeId: 'premium',
      );
      expect(electronicsPremium, closeTo(0.1714, 0.0001));

      // Non-existent category fallback
      final fallbackRate = settings.commissionRateFor(
        categoryId: 'non_existent_category',
        publicationTypeId: 'classic',
      );
      expect(fallbackRate, settings.sellerFeeRate);
    });

    test('AdvancedModeOverrides applies custom overrides cleanly', () {
      final config = AppConfig.fromJsonString(defaultConfigContent);
      final baseSettings = CalculatorSettings.fromConfig(config);

      const overrides = AdvancedModeOverrides(
        sellerFeeRate: 0.20,
        unitCostBelowThreshold: 3500.0,
        freeShippingThreshold: 40000.0,
        installmentRates: {'5': 0.02},
      );

      final applied = overrides.applyTo(baseSettings);
      expect(applied.sellerFeeRate, 0.20);
      expect(applied.unitCostBelowThreshold, 3500.0);
      expect(applied.freeShippingThreshold, 40000.0);
      expect(applied.installmentRateFor('5'), 0.02);
    });
  });
}
