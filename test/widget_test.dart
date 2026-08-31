import 'dart:convert';
import 'package:dobre/providers/advanced_mode_provider.dart';
import 'package:dobre/providers/app_config_provider.dart';
import 'package:dobre/providers/theme_provider.dart';
import 'package:dobre/repositories/advanced_mode_repository.dart';
import 'package:dobre/repositories/app_config_repository.dart';
import 'package:dobre/services/pricing_calculator.dart';
import 'package:dobre/services/remote_config_service.dart';
import 'package:dobre/widgets/precio_textfield.dart';
import 'package:dobre/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const sampleJson = {
    'version': '2026.08.01',
    'lastUpdate': '2026-08-01T00:00:00Z',
    'message': null,
    'maintenanceMode': false,
    'minimumSupportedVersion': '0.1.0',
    'publicationTypes': [
      {'id': 'classic', 'name': 'Clásica'},
      {'id': 'premium', 'name': 'Premium'}
    ],
    'tariffs': {'sellerFeeRate': 0.15, 'unitCostBelowThreshold': 2800.0},
    'percentages': {'sellerFeeRate': 0.15},
    'fixedCharges': [
      {'maxPrice': 12000, 'charge': 900},
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
        'name': 'Electrónica, Audio y Video',
        'fees': {'classic': 0.15, 'premium': 0.1714}
      }
    ],
    'advancedMode': {
      'enabledByDefault': false,
      'parameters': {'notes': 'Notas'}
    },
    'input': {'minAllowedPrice': 1000.0, 'maxAllowedPrice': 999999999.0}
  };

  testWidgets('DoBre main screen loads and calculates price correctly', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final mockClient = MockClient((request) async {
      return http.Response(jsonEncode(sampleJson), 200, headers: {
        'content-type': 'application/json; charset=utf-8',
      });
    });

    final remoteConfigService = RemoteConfigService(
      endpoint: 'https://example.com/config',
      client: mockClient,
    );

    final appConfigRepository = AppConfigRepository(
      preferences: preferences,
      remoteConfigService: remoteConfigService,
      bundledAssetPath: 'assets/config/default_config.json',
    );
    final advancedModeRepository = AdvancedModeRepository(preferences);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: const PricingCalculator()),
          ChangeNotifierProvider(create: (_) => ThemeProvider(preferences)),
          ChangeNotifierProvider(
            create: (_) => AppConfigProvider(appConfigRepository)..initialize(),
          ),
          ChangeNotifierProxyProvider<AppConfigProvider, AdvancedModeProvider>(
            create: (_) => AdvancedModeProvider(advancedModeRepository),
            update: (_, configProvider, advancedProvider) {
              final provider =
                  advancedProvider ??
                  AdvancedModeProvider(advancedModeRepository);
              final config = configProvider.config;
              if (!provider.isLoaded && config != null) {
                provider.initialize(config: config);
              }
              return provider;
            },
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial UI elements
    expect(find.text('DoBre'), findsOneWidget);
    expect(find.text('Calcular precio'), findsOneWidget);
    expect(find.text('Resultado'), findsOneWidget);

    // Enter a target net amount
    final priceInput = find.descendant(
      of: find.byType(PrecioTextField),
      matching: find.byType(TextField),
    );
    expect(priceInput, findsOneWidget);
    await tester.enterText(priceInput, '50000');
    await tester.pumpAndSettle();

    // Tap calculate button
    final calcButton = find.text('Calcular precio');
    await tester.ensureVisible(calcButton);
    await tester.tap(calcButton);
    await tester.pumpAndSettle();

    // Verify suggested price and breakdown are rendered
    expect(find.text('Precio sugerido de publicación'), findsOneWidget);
    expect(find.text('Desglose estimado de la venta'), findsOneWidget);
    expect(find.text('Copiar precio'), findsOneWidget);
  });
}
