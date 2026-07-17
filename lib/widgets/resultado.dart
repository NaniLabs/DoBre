import 'package:flutter/material.dart';

class Resultado extends StatelessWidget {
  const Resultado({super.key, required this.precioML, required this.onCopiar});

  final double precioML;
  final VoidCallback onCopiar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (horizontal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Precio sugerido",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(
              "\$${precioML.toStringAsFixed(2)}",
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCopiar,
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text("Copiar precio"),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Precio sugerido",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "\$${precioML.toStringAsFixed(2)}",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
              letterSpacing: -0.8,
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCopiar,
            icon: const Icon(Icons.content_copy_rounded),
            label: const Text("Copiar precio"),
          ),
        ),
      ],
    );
  }
}
