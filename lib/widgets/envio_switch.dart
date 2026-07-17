import 'package:flutter/material.dart';

class EnvioSwitch extends StatelessWidget {
  const EnvioSwitch({
    super.key,
    required this.envioGratis,
    required this.freeShippingThreshold,
    required this.publishedPrice,
    required this.onChanged,
  });

  final bool envioGratis;
  final double freeShippingThreshold;
  final double publishedPrice;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final forced = publishedPrice >= freeShippingThreshold;

    return Card(
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: const Text('Envio gratis'),
        subtitle: Text(
          forced
              ? 'Se activa automaticamente desde \$${freeShippingThreshold.toStringAsFixed(0)}.'
              : 'Activalo si queres absorber el envio.',
        ),
        value: envioGratis,
        onChanged: forced ? null : onChanged,
      ),
    );
  }
}
