import 'dart:async';

import 'package:dobre/models/app_config.dart';
import 'package:dobre/repositories/app_config_repository.dart';
import 'package:flutter/foundation.dart';

class AppConfigProvider extends ChangeNotifier {
  AppConfigProvider(this._repository);

  final AppConfigRepository _repository;

  AppConfig? _config;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _lastError;

  AppConfig? get config => _config;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get lastError => _lastError;
  bool get hasConfig => _config != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.loadInitialConfig();
      _config = result.config;
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    unawaited(refreshInBackground());
  }

  Future<void> refreshInBackground() async {
    final currentConfig = _config;
    if (currentConfig == null || _isRefreshing) {
      return;
    }

    _isRefreshing = true;
    notifyListeners();

    try {
      final updatedConfig = await _repository.syncWithRemote(
        currentConfig: currentConfig,
      );
      if (updatedConfig != null) {
        _config = updatedConfig;
      }
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
