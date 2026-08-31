import 'package:dobre/models/app_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonacionesSheet extends StatelessWidget {
  const DonacionesSheet({super.key, required this.donationsConfig});

  final DonationsConfig donationsConfig;

  Future<void> _abrirLink(BuildContext context, String url, String concepto) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el link de $concepto.'),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () => launchUrl(uri, mode: LaunchMode.platformDefault),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con Mercado Pago para $concepto.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = donationsConfig;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      color: colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Apoyo voluntario a DoBre',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                config.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Elegí una opción de colaboración:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _DonationOptionTile(
                iconText: '☕',
                title: 'Café',
                subtitle: '\$ 1.000 por Mercado Pago',
                badgeText: '\$ 1.000',
                onTap: () => _abrirLink(context, config.cafeLink, 'Café (\$1.000)'),
              ),
              const SizedBox(height: 10),
              _DonationOptionTile(
                iconText: '❤️',
                title: 'Apoyo',
                subtitle: '\$ 2.500 por Mercado Pago',
                badgeText: '\$ 2.500',
                isHighlighted: true,
                onTap: () => _abrirLink(context, config.apoyoLink, 'Apoyo (\$2.500)'),
              ),
              const SizedBox(height: 10),
              _DonationOptionTile(
                iconText: '🚀',
                title: 'Impulso',
                subtitle: '\$ 5.000 por Mercado Pago',
                badgeText: '\$ 5.000',
                onTap: () => _abrirLink(context, config.impulsoLink, 'Impulso (\$5.000)'),
              ),
              const SizedBox(height: 10),
              _DonationOptionTile(
                iconText: '✨',
                title: 'Otro monto',
                subtitle: 'Elegí el monto que quieras aportar',
                badgeText: 'Monto libre',
                onTap: () => _abrirLink(context, config.customLink, 'Otro monto'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pago 100% seguro y directo en la plataforma oficial de Mercado Pago.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonationOptionTile extends StatelessWidget {
  const _DonationOptionTile({
    required this.iconText,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.onTap,
    this.isHighlighted = false,
  });

  final String iconText;
  final String title;
  final String subtitle;
  final String badgeText;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHighlighted
                ? colorScheme.primary.withValues(alpha: 0.08)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHighlighted
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant,
              width: isHighlighted ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Text(
                iconText,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isHighlighted
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: isHighlighted
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
