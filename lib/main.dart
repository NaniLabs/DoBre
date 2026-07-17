import 'dart:async';

import 'package:dobre/models/app_config.dart';
import 'package:dobre/models/calculation_options.dart';
import 'package:dobre/models/calculator_settings.dart';
import 'package:dobre/providers/advanced_mode_provider.dart';
import 'package:dobre/providers/app_config_provider.dart';
import 'package:dobre/providers/theme_provider.dart';
import 'package:dobre/repositories/advanced_mode_repository.dart';
import 'package:dobre/repositories/app_config_repository.dart';
import 'package:dobre/screens/advanced_mode_screen.dart';
import 'package:dobre/screens/credits_screen.dart';
import 'package:dobre/services/pricing_calculator.dart';
import 'package:dobre/services/remote_config_service.dart';
import 'package:dobre/theme/app_theme.dart';
import 'package:dobre/widgets/boton_calcular.dart';
import 'package:dobre/widgets/category_selector.dart';
import 'package:dobre/widgets/configuracion_sheet.dart';
import 'package:dobre/widgets/cuotas_dropdown.dart';
import 'package:dobre/widgets/envio_switch.dart';
import 'package:dobre/widgets/footer.dart';
import 'package:dobre/widgets/precio_textfield.dart';
import 'package:dobre/widgets/resultado.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _remoteConfigUrl = String.fromEnvironment(
  'DOBRE_REMOTE_CONFIG_URL',
  defaultValue: 'https://dobre-config-worker.igforeversal.workers.dev/config',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final remoteConfigService = RemoteConfigService(endpoint: _remoteConfigUrl);
  final appConfigRepository = AppConfigRepository(
    preferences: preferences,
    remoteConfigService: remoteConfigService,
    bundledAssetPath: 'assets/config/default_config.json',
  );
  final advancedModeRepository = AdvancedModeRepository(preferences);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: const PricingCalculator()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
              unawaited(provider.initialize(config: config));
            }

            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'DoBre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.themeMode,
      home: const MyHomePage(),
    );
  }
}

enum _HomeMenuAction {
  normalMode,
  advancedMode,
  openAdvancedSettings,
  openCredits,
  openSettings,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double precioML = 0.0;
  bool envioGratis = false;
  Timer? _debounce;
  final TextEditingController precioController = TextEditingController();
  String _selectedCategoryId = '';
  String _selectedInstallmentId = '';
  bool _modeHintHandled = false;
  bool _eggTutucaSeen = false;
  bool _eggThresholdSeen = false;
  double precio = 0.0;

  AppConfig? get _configOrNull => context.read<AppConfigProvider>().config;

  CalculatorSettings? _effectiveSettingsOrNull() {
    final config = _configOrNull;
    if (config == null) {
      return null;
    }

    return context.read<AdvancedModeProvider>().resolveSettings(config);
  }

  CalculationOptions _buildNormalModeOptions(AppConfig config) {
    final providerDefaults = context
        .read<AdvancedModeProvider>()
        .resolveOptions(config);
    final categoryId = _selectedCategoryId.isNotEmpty
        ? _selectedCategoryId
        : providerDefaults.categoryId;
    final installmentOptionId = _selectedInstallmentId.isNotEmpty
        ? _selectedInstallmentId
        : config.installments.defaultOptionId;

    return CalculationOptions(
      categoryId: categoryId,
      publicationTypeId: providerDefaults.publicationTypeId,
      weightKg: 1.0,
      installmentOptionId: installmentOptionId,
      freeShipping: envioGratis,
    );
  }

  CalculationOptions? _effectiveOptionsOrNull() {
    final config = _configOrNull;
    if (config == null) {
      return null;
    }

    final advancedProvider = context.read<AdvancedModeProvider>();
    if (advancedProvider.enabled) {
      return advancedProvider.resolveOptions(config);
    }

    return _buildNormalModeOptions(config);
  }

  void _ensureInitialSelections(AppConfig config) {
    final defaults = context.read<AdvancedModeProvider>().resolveOptions(
      config,
    );
    if (_selectedCategoryId.isEmpty) {
      _selectedCategoryId = defaults.categoryId;
    }
    if (_selectedInstallmentId.isEmpty) {
      _selectedInstallmentId = config.installments.defaultOptionId;
    }
  }

  void _maybeShowModeHint(AdvancedModeProvider provider) {
    if (_modeHintHandled || !provider.shouldShowModeHint) {
      return;
    }

    _modeHintHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Podes cambiar entre modo normal y avanzado desde el menu superior.',
          ),
          action: SnackBarAction(
            label: 'Entendido',
            onPressed: () {
              context.read<AdvancedModeProvider>().markModeHintSeen();
            },
          ),
        ),
      );
    });
  }

  void buscarMejorPrecio() {
    final settings = _effectiveSettingsOrNull();
    final options = _effectiveOptionsOrNull();
    if (settings == null || options == null) {
      return;
    }

    final calculator = context.read<PricingCalculator>();

    final optimalPrice = calculator.findOptimalPrice(
      targetNetAmount: precio,
      settings: settings,
      options: options,
    );

    setState(() {
      precioML = optimalPrice;
      if (!context.read<AdvancedModeProvider>().enabled &&
          precioML >= settings.freeShippingThreshold) {
        envioGratis = true;
      }
    });
  }

  void _onPrecioChanged(String value) {
    final settings = _effectiveSettingsOrNull();
    if (value.isEmpty || settings == null) {
      return;
    }

    setState(() {
      precio = double.tryParse(value) ?? 0.0;
    });

    _debounce?.cancel();

    _debounce = Timer(const Duration(seconds: 2), () {
      final parsedPrice = double.tryParse(value);
      if (parsedPrice == null) {
        return;
      }

      if (parsedPrice < settings.minAllowedPrice) {
        _replaceInputValue(settings.minAllowedPrice);
        _showMessage(
          "El precio no puede ser menor a \$${settings.minAllowedPrice.toStringAsFixed(0)}",
        );
      } else if (parsedPrice > settings.maxAllowedPrice) {
        _replaceInputValue(settings.maxAllowedPrice);
        _showMessage(
          "El precio no puede ser mayor a \$${settings.maxAllowedPrice.toStringAsFixed(0)}",
        );
      }

      _checkEasterEggs(parsedPrice);
      buscarMejorPrecio();
    });
  }

  void _checkEasterEggs(double parsedPrice) {
    if (parsedPrice == 2204 && !_eggTutucaSeen) {
      _eggTutucaSeen = true;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🐹'),
          content: const Text('❤️ N + O = TUTUCA ❤️'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aww'),
            ),
          ],
        ),
      );
    } else if (parsedPrice == 33000 && !_eggThresholdSeen) {
      _eggThresholdSeen = true;
      _showMessage(
        'Umbral detectado: Mercado Libre ya te pide envio gratis 🚚',
      );
    }
  }

  void _replaceInputValue(double value) {
    final formatted = value.toStringAsFixed(1);
    precioController
      ..text = formatted
      ..selection = TextSelection.collapsed(offset: formatted.length);
    precio = value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _copiarPrecio() {
    Clipboard.setData(ClipboardData(text: precioML.toStringAsFixed(0)));
    _showMessage("Precio copiado al portapapeles");
  }

  Future<void> _setMode(bool enabled) async {
    final config = _configOrNull;
    if (config == null) {
      return;
    }

    final provider = context.read<AdvancedModeProvider>();
    await provider.setMode(
      enabled: enabled,
      config: config,
      fallbackOptions: _buildNormalModeOptions(config),
    );
    await provider.markModeHintSeen();
    if (mounted) {
      setState(() {});
      buscarMejorPrecio();
    }
  }

  void _openAdvancedSettings() {
    final config = _configOrNull;
    if (config == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdvancedModeScreen(config: config),
      ),
    );
  }

  void _openSettingsSheet() {
    final config = _configOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ConfiguracionSheet(config: config),
    );
  }

  Future<void> _onMenuSelected(_HomeMenuAction action) async {
    switch (action) {
      case _HomeMenuAction.normalMode:
        await _setMode(false);
      case _HomeMenuAction.advancedMode:
        await _setMode(true);
      case _HomeMenuAction.openAdvancedSettings:
        _openAdvancedSettings();
      case _HomeMenuAction.openCredits:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CreditsScreen()));
      case _HomeMenuAction.openSettings:
        _openSettingsSheet();
    }
  }

  Widget _buildHero(BuildContext context, bool advancedMode) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            advancedMode ? 'Modo avanzado' : 'Modo normal',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Calcula el precio sugerido.',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteMessage(AppConfig config) {
    if (config.message == null || config.message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.campaign_outlined),
              const SizedBox(width: 12),
              Expanded(child: Text(config.message!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedSummary(BuildContext context, AppConfig config) {
    final options = context.read<AdvancedModeProvider>().resolveOptions(config);
    final category = config.categories
        .where((entry) => entry.id == options.categoryId)
        .firstOrNull;
    final publicationType = config.publicationTypes
        .where((entry) => entry.id == options.publicationTypeId)
        .firstOrNull;
    final installment = config.installments.options
        .where((entry) => entry.id == options.installmentOptionId)
        .firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuracion activa',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text('Categoria: ${category?.name ?? options.categoryId}'),
            Text(
              'Publicacion: ${publicationType?.name ?? options.publicationTypeId}',
            ),
            Text('Peso: ${options.weightKg.toStringAsFixed(2)} kg'),
            Text(
              'Cuotas: ${installment?.label ?? options.installmentOptionId}',
            ),
            Text('Envio gratis: ${options.freeShipping ? 'Si' : 'No'}'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _openAdvancedSettings,
              child: const Text('Editar modo avanzado'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalControls(
    BuildContext context,
    AppConfig config,
    CalculatorSettings settings,
  ) {
    final advancedMode = context.read<AdvancedModeProvider>().enabled;
    if (advancedMode) {
      return _buildAdvancedSummary(context, config);
    }

    final publishedPriceForShipping = precioML > 0 ? precioML : precio;

    return Column(
      children: [
        CategorySelector(
          value: _selectedCategoryId,
          categories: config.categories,
          onSelected: (categoryId) {
            setState(() {
              _selectedCategoryId = categoryId;
            });
            buscarMejorPrecio();
          },
        ),
        const SizedBox(height: 18),
        CuotasDropdown(
          value: _selectedInstallmentId,
          options: config.installments.options,
          onChanged: (value) {
            setState(() {
              _selectedInstallmentId = value ?? _selectedInstallmentId;
            });
            buscarMejorPrecio();
          },
        ),
        const SizedBox(height: 18),
        EnvioSwitch(
          envioGratis: envioGratis,
          freeShippingThreshold: settings.freeShippingThreshold,
          publishedPrice: publishedPriceForShipping,
          onChanged: (value) {
            setState(() {
              envioGratis = value;
            });
            buscarMejorPrecio();
          },
        ),
      ],
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    AppConfig config,
    CalculatorSettings settings,
  ) {
    final advancedMode = context.read<AdvancedModeProvider>().enabled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              advancedMode ? 'Calculo' : 'Venta',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            PrecioTextField(
              controller: precioController,
              onChanged: _onPrecioChanged,
            ),
            const SizedBox(height: 18),
            _buildNormalControls(context, config, settings),
            const SizedBox(height: 24),
            BotonCalcular(onPressed: buscarMejorPrecio),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Resultado',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Resultado(precioML: precioML, onCopiar: _copiarPrecio),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AppConfig config,
    CalculatorSettings settings,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildHero(context, context.read<AdvancedModeProvider>().enabled),
              const SizedBox(height: 24),
              _buildRemoteMessage(config),
              _buildFormCard(context, config, settings),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(flex: 4, child: _buildResultCard(context)),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AppConfig config,
    CalculatorSettings settings,
  ) {
    return Column(
      children: [
        _buildHero(context, context.read<AdvancedModeProvider>().enabled),
        const SizedBox(height: 20),
        _buildRemoteMessage(config),
        _buildFormCard(context, config, settings),
        const SizedBox(height: 20),
        _buildResultCard(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final configProvider = context.watch<AppConfigProvider>();
    final advancedProvider = context.watch<AdvancedModeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("DoBre"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0.85,
                end: advancedProvider.shouldShowModeHint ? 1.08 : 1.0,
              ),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: PopupMenuButton<_HomeMenuAction>(
                tooltip: 'Menu',
                onOpened: () {
                  advancedProvider.markModeHintSeen();
                },
                onSelected: _onMenuSelected,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _HomeMenuAction.normalMode,
                    child: Row(
                      children: [
                        Icon(
                          advancedProvider.enabled
                              ? Icons.radio_button_unchecked
                              : Icons.check_circle_rounded,
                        ),
                        const SizedBox(width: 12),
                        const Text('Modo normal'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _HomeMenuAction.advancedMode,
                    child: Row(
                      children: [
                        Icon(
                          advancedProvider.enabled
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                        ),
                        const SizedBox(width: 12),
                        const Text('Modo avanzado'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: _HomeMenuAction.openAdvancedSettings,
                    child: Text('Editar modo avanzado'),
                  ),
                  const PopupMenuItem(
                    value: _HomeMenuAction.openCredits,
                    child: Text('Informacion'),
                  ),
                  const PopupMenuItem(
                    value: _HomeMenuAction.openSettings,
                    child: Text('Ajustes'),
                  ),
                ],
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: advancedProvider.shouldShowModeHint
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.tune_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: configProvider.isLoading && !configProvider.hasConfig
              ? const Center(child: CircularProgressIndicator())
              : !configProvider.hasConfig
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      configProvider.lastError ??
                          "No se pudo cargar la configuracion.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final config = configProvider.config!;
                    _ensureInitialSelections(config);
                    _maybeShowModeHint(advancedProvider);
                    final settings = _effectiveSettingsOrNull()!;
                    final isWide = constraints.maxWidth >= 980;
                    final horizontalPadding = constraints.maxWidth >= 1280
                        ? 32.0
                        : constraints.maxWidth >= 720
                        ? 24.0
                        : 16.0;

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: Column(
                            children: [
                              isWide
                                  ? _buildDesktopLayout(
                                      context,
                                      config,
                                      settings,
                                    )
                                  : _buildMobileLayout(
                                      context,
                                      config,
                                      settings,
                                    ),
                              const SizedBox(height: 24),
                              const Footer(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    precioController.dispose();
    super.dispose();
  }
}
