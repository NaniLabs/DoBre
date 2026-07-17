import 'package:dobre/models/advanced_mode_overrides.dart';
import 'package:dobre/models/app_config.dart';
import 'package:dobre/models/calculation_options.dart';
import 'package:dobre/models/calculator_settings.dart';
import 'package:dobre/repositories/advanced_mode_repository.dart';
import 'package:flutter/foundation.dart';

class AdvancedModeProvider extends ChangeNotifier {
  AdvancedModeProvider(this._repository);

  final AdvancedModeRepository _repository;

  bool _enabled = false;
  AdvancedModeOverrides _overrides = const AdvancedModeOverrides();
  CalculationOptions? _options;
  bool _isLoaded = false;
  bool _modeHintSeen = false;

  bool get enabled => _enabled;
  AdvancedModeOverrides get overrides => _overrides;
  CalculationOptions? get options => _options;
  bool get isLoaded => _isLoaded;
  bool get shouldShowModeHint => !_modeHintSeen;

  Future<void> initialize({required AppConfig config}) async {
    _enabled = _repository.loadEnabled(
      fallback: config.advancedMode.enabledByDefault,
    );
    _overrides = _repository.loadOverrides();
    _options = _repository.loadOptions() ?? _buildNormalModeDefaults(config);
    _modeHintSeen = _repository.loadModeHintSeen();
    _isLoaded = true;
    notifyListeners();
  }

  CalculatorSettings resolveSettings(AppConfig config) {
    final base = config.calculatorSettings;
    if (!_enabled) {
      return base;
    }

    return _overrides.applyTo(base);
  }

  CalculationOptions resolveOptions(AppConfig config) {
    final defaults = _buildNormalModeDefaults(config);
    if (!_enabled) {
      return defaults;
    }

    return _mergeOptions(defaults, _options);
  }

  Future<void> save({
    required bool enabled,
    required AdvancedModeOverrides overrides,
    required CalculationOptions options,
  }) async {
    _enabled = enabled;
    _overrides = overrides;
    _options = options;
    await _repository.save(
      enabled: enabled,
      overrides: overrides,
      options: options,
    );
    notifyListeners();
  }

  Future<void> setMode({
    required bool enabled,
    required AppConfig config,
    CalculationOptions? fallbackOptions,
  }) async {
    _enabled = enabled;
    _options ??= fallbackOptions ?? _buildNormalModeDefaults(config);
    await _repository.save(
      enabled: _enabled,
      overrides: _overrides,
      options: _options!,
    );
    notifyListeners();
  }

  Future<void> reset({required AppConfig config}) async {
    _enabled = config.advancedMode.enabledByDefault;
    _overrides = const AdvancedModeOverrides();
    _options = _buildNormalModeDefaults(config);
    await _repository.reset(
      enabledFallback: config.advancedMode.enabledByDefault,
    );
    notifyListeners();
  }

  Future<void> markModeHintSeen() async {
    if (_modeHintSeen) {
      return;
    }

    _modeHintSeen = true;
    await _repository.saveModeHintSeen();
    notifyListeners();
  }

  CalculationOptions _buildNormalModeDefaults(AppConfig config) {
    final publicationType =
        config.publicationTypes
            .where((entry) => entry.id == 'classic')
            .firstOrNull ??
        config.publicationTypes.firstOrNull;

    final publicationTypeId = publicationType?.id ?? '';
    final standardRate = config.tariffs.sellerFeeRate;

    CategoryConfig? closestCategory;
    var closestDistance = double.infinity;
    for (final category in config.categories) {
      final distance = (category.fees.rateFor(publicationTypeId) - standardRate)
          .abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestCategory = category;
      }
    }

    final installmentId = config.installments.defaultOptionId;

    return CalculationOptions(
      categoryId: closestCategory?.id ?? '',
      publicationTypeId: publicationTypeId,
      weightKg: 1.0,
      installmentOptionId: installmentId,
      freeShipping: false,
    );
  }

  CalculationOptions _mergeOptions(
    CalculationOptions defaults,
    CalculationOptions? current,
  ) {
    if (current == null) {
      return defaults;
    }

    return CalculationOptions(
      categoryId: current.categoryId.isNotEmpty
          ? current.categoryId
          : defaults.categoryId,
      publicationTypeId: current.publicationTypeId.isNotEmpty
          ? current.publicationTypeId
          : defaults.publicationTypeId,
      weightKg: current.weightKg > 0 ? current.weightKg : defaults.weightKg,
      installmentOptionId: current.installmentOptionId.isNotEmpty
          ? current.installmentOptionId
          : defaults.installmentOptionId,
      freeShipping: current.freeShipping,
    );
  }
}
