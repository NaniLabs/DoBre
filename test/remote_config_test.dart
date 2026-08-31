import 'dart:convert';
import 'package:dobre/models/app_config.dart';
import 'package:dobre/repositories/app_config_repository.dart';
import 'package:dobre/services/remote_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleJson = {
    'version': '2026.08.01',
    'lastUpdate': '2026-08-01T00:00:00Z',
    'message': 'Nueva actualización disponible',
    'maintenanceMode': false,
    'minimumSupportedVersion': '0.1.0',
    'publicationTypes': [
      {'id': 'classic', 'name': 'Clásica'},
      {'id': 'premium', 'name': 'Premium'}
    ],
    'tariffs': {'sellerFeeRate': 0.14, 'unitCostBelowThreshold': 2800.0},
    'percentages': {'sellerFeeRate': 0.14},
    'fixedCharges': [
      {'maxPrice': 33000, 'charge': 1800},
      {'maxPrice': null, 'charge': 0}
    ],
    'shipping': {
      'freeShippingThreshold': 33000.0,
      'weightTable': [
        {
          'maxWeight': 1.0,
          'below33000': 9800,
          'between33000And49999': 7000,
          'above50000': 7470
        }
      ]
    },
    'installments': {
      'defaultOptionId': '5',
      'options': [
        {'id': '5', 'label': 'Sin cuotas', 'rate': 0.0}
      ]
    },
    'categories': [
      {
        'id': 'electronics',
        'name': 'Electrónica',
        'fees': {'classic': 0.15, 'premium': 0.17}
      }
    ],
    'advancedMode': {
      'enabledByDefault': false,
      'parameters': {'notes': 'Notas de prueba'}
    },
    'input': {'minAllowedPrice': 1000.0, 'maxAllowedPrice': 999999999.0}
  };

  group('RemoteConfigService unit tests', () {
    test('Throws ArgumentError if endpoint is not HTTPS', () {
      expect(
        () => RemoteConfigService(endpoint: 'http://insecure.endpoint.com/config'),
        throwsArgumentError,
      );
    });

    test('Fetches and decodes config successfully on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(sampleJson), 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final service = RemoteConfigService(
        endpoint: 'https://example.com/config',
        client: mockClient,
      );

      final result = await service.fetchConfig();
      expect(result['version'], '2026.08.01');
      expect(result['message'], 'Nueva actualización disponible');
    });

    test('Throws RemoteConfigException on HTTP 500 or error status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = RemoteConfigService(
        endpoint: 'https://example.com/config',
        client: mockClient,
      );

      expect(() => service.fetchConfig(), throwsA(isA<RemoteConfigException>()));
    });
  });

  group('AppConfigRepository fallback & caching tests', () {
    late SharedPreferences preferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
    });

    test('Falls back to cached config when remote fails', () async {
      // Seed cache
      final appConfig = AppConfig.fromJson(sampleJson);
      await preferences.setString(
        AppConfigRepository.localConfigKey,
        appConfig.toJsonString(),
      );

      final failingClient = MockClient((request) async {
        return http.Response('Error', 503);
      });

      final repository = AppConfigRepository(
        preferences: preferences,
        remoteConfigService: RemoteConfigService(
          endpoint: 'https://example.com/config',
          client: failingClient,
        ),
        bundledAssetPath: 'assets/config/default_config.json',
      );

      final result = await repository.loadInitialConfig();
      expect(result.source, AppConfigSource.cached);
      expect(result.config.version, '2026.08.01');
    });
  });
}
