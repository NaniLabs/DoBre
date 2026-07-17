import 'package:dobre/models/app_config.dart';
import 'package:dobre/services/remote_config_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppConfigSource { remote, cached, bundled }

class AppConfigLoadResult {
  const AppConfigLoadResult({required this.config, required this.source});

  final AppConfig config;
  final AppConfigSource source;
}

class AppConfigRepository {
  AppConfigRepository({
    required this._preferences,
    required this._remoteConfigService,
    required this._bundledAssetPath,
  });

  static const localConfigKey = 'remote_config_payload';

  final SharedPreferences _preferences;
  final RemoteConfigService _remoteConfigService;
  final String _bundledAssetPath;

  Future<AppConfigLoadResult> loadInitialConfig() async {
    try {
      final remoteConfig = await _loadRemoteConfig();
      final cachedConfig = await loadLocalConfig();

      if (cachedConfig == null ||
          _compareVersions(remoteConfig.version, cachedConfig.version) != 0) {
        await cacheConfig(remoteConfig);
      }

      _logSource(AppConfigSource.remote);
      return AppConfigLoadResult(
        config: remoteConfig,
        source: AppConfigSource.remote,
      );
    } catch (error) {
      debugPrint('Remote config failed: $error');
    }

    try {
      final cachedConfig = await loadLocalConfig();
      if (cachedConfig != null) {
        _logSource(AppConfigSource.cached);
        return AppConfigLoadResult(
          config: cachedConfig,
          source: AppConfigSource.cached,
        );
      }
    } catch (error) {
      debugPrint('Cached config failed: $error');
    }

    final bundledConfig = await loadBundledConfig();
    _logSource(AppConfigSource.bundled);
    return AppConfigLoadResult(
      config: bundledConfig,
      source: AppConfigSource.bundled,
    );
  }

  Future<AppConfig?> loadLocalConfig() async {
    final rawConfig = _preferences.getString(localConfigKey);
    if (rawConfig == null || rawConfig.isEmpty) {
      return null;
    }

    return AppConfig.fromJsonString(rawConfig);
  }

  Future<AppConfig> loadBundledConfig() async {
    final bundledJson = await rootBundle.loadString(_bundledAssetPath);
    return AppConfig.fromJsonString(bundledJson);
  }

  Future<AppConfig?> syncWithRemote({required AppConfig currentConfig}) async {
    final remoteConfig = await _loadRemoteConfig();
    final cachedConfig = await loadLocalConfig();
    final versionComparison = _compareVersions(
      remoteConfig.version,
      currentConfig.version,
    );

    if (cachedConfig == null ||
        _compareVersions(remoteConfig.version, cachedConfig.version) != 0) {
      await cacheConfig(remoteConfig);
    }

    if (versionComparison != 0) {
      await cacheConfig(remoteConfig);
      debugPrint('Remote config refreshed: ${remoteConfig.version}');
      return remoteConfig;
    }

    return null;
  }

  Future<void> cacheConfig(AppConfig config) {
    return _preferences.setString(localConfigKey, config.toJsonString());
  }

  Future<AppConfig> _loadRemoteConfig() async {
    final remoteMap = await _remoteConfigService.fetchConfig();
    return AppConfig.fromJson(remoteMap);
  }

  void _logSource(AppConfigSource source) {
    switch (source) {
      case AppConfigSource.remote:
        debugPrint('Remote config');
      case AppConfigSource.cached:
        debugPrint('Cached config');
      case AppConfigSource.bundled:
        debugPrint('Bundled config');
    }
  }

  int _compareVersions(String left, String right) {
    if (left == right) {
      return 0;
    }

    final leftParts = _numericSegments(left);
    final rightParts = _numericSegments(right);
    final maxLength = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;

    for (var i = 0; i < maxLength; i++) {
      final leftValue = i < leftParts.length ? leftParts[i] : 0;
      final rightValue = i < rightParts.length ? rightParts[i] : 0;
      if (leftValue != rightValue) {
        return leftValue.compareTo(rightValue);
      }
    }

    return left.compareTo(right);
  }

  List<int> _numericSegments(String version) {
    return RegExp(r'\d+')
        .allMatches(version)
        .map((match) => int.tryParse(match.group(0) ?? '0') ?? 0)
        .toList(growable: false);
  }
}
