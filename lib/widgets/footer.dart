import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key, this.onOpenDonations});

  final VoidCallback? onOpenDonations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            'DoBre • Cálculo inverso para Mercado Libre',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Herramienta libre e independiente • v1.0.0',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          if (onOpenDonations != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onOpenDonations,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
              label: const Text(
                'Apoyar el proyecto',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
