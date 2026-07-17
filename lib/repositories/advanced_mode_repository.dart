import 'package:dobre/models/advanced_mode_overrides.dart';
import 'package:dobre/models/calculation_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedModeRepository {
  AdvancedModeRepository(this._preferences);

  static const enabledKey = 'advanced_mode_enabled';
  static const overridesKey = 'advanced_mode_overrides';
  static const optionsKey = 'advanced_mode_options';
  static const modeHintSeenKey = 'mode_hint_seen';

  final SharedPreferences _preferences;

  bool loadEnabled({required bool fallback}) {
    return _preferences.getBool(enabledKey) ?? fallback;
  }

  AdvancedModeOverrides loadOverrides() {
    final rawValue = _preferences.getString(overridesKey);
    if (rawValue == null || rawValue.isEmpty) {
      return const AdvancedModeOverrides();
    }

    return AdvancedModeOverrides.fromJsonString(rawValue);
  }

  CalculationOptions? loadOptions() {
    final rawValue = _preferences.getString(optionsKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return CalculationOptions.fromJsonString(rawValue);
  }

  Future<void> save({
    required bool enabled,
    required AdvancedModeOverrides overrides,
    required CalculationOptions options,
  }) async {
    await _preferences.setBool(enabledKey, enabled);
    await _preferences.setString(overridesKey, overrides.toJsonString());
    await _preferences.setString(optionsKey, options.toJsonString());
  }

  Future<void> reset({required bool enabledFallback}) async {
    await _preferences.setBool(enabledKey, enabledFallback);
    await _preferences.remove(overridesKey);
    await _preferences.remove(optionsKey);
  }

  bool loadModeHintSeen() {
    return _preferences.getBool(modeHintSeenKey) ?? false;
  }

  Future<void> saveModeHintSeen() async {
    await _preferences.setBool(modeHintSeenKey, true);
  }
}
