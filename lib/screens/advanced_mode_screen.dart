import 'package:dobre/models/app_config.dart';
import 'package:dobre/models/calculation_options.dart';
import 'package:dobre/providers/advanced_mode_provider.dart';
import 'package:dobre/widgets/category_selector.dart';
import 'package:dobre/widgets/cuotas_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvancedModeScreen extends StatefulWidget {
  const AdvancedModeScreen({super.key, required this.config});

  final AppConfig config;

  @override
  State<AdvancedModeScreen> createState() => _AdvancedModeScreenState();
}

class _AdvancedModeScreenState extends State<AdvancedModeScreen> {
  late final TextEditingController _weightController;
  late String _categoryId;
  late String _publicationTypeId;
  late String _installmentOptionId;
  bool _freeShipping = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdvancedModeProvider>();
    final effectiveOptions = provider.resolveOptions(widget.config);

    _categoryId = effectiveOptions.categoryId;
    _publicationTypeId = effectiveOptions.publicationTypeId;
    _installmentOptionId = effectiveOptions.installmentOptionId;
    _freeShipping = effectiveOptions.freeShipping;
    _weightController = TextEditingController(
      text: effectiveOptions.weightKg.toString(),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<AdvancedModeProvider>();
    final options = CalculationOptions(
      categoryId: _categoryId,
      publicationTypeId: _publicationTypeId,
      weightKg: _parseDouble(_weightController.text) ?? 1.0,
      installmentOptionId: _installmentOptionId,
      freeShipping: _freeShipping,
    );

    await provider.save(
      enabled: true,
      overrides: provider.overrides,
      options: options,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Modo avanzado actualizado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo avanzado'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Simular publicacion',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CategorySelector(
                    value: _categoryId,
                    categories: widget.config.categories,
                    onSelected: (value) {
                      setState(() {
                        _categoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _publicationTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de publicacion',
                    ),
                    items: widget.config.publicationTypes
                        .map(
                          (publicationType) => DropdownMenuItem<String>(
                            value: publicationType.id,
                            child: Text(publicationType.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        _publicationTypeId = value ?? _publicationTypeId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Peso en kg'),
                  ),
                  const SizedBox(height: 16),
                  CuotasDropdown(
                    value: _installmentOptionId,
                    options: widget.config.installments.options,
                    onChanged: (value) {
                      setState(() {
                        _installmentOptionId = value ?? _installmentOptionId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Envio gratis'),
                    value: _freeShipping,
                    onChanged: (value) {
                      setState(() {
                        _freeShipping = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim());
  }
}
