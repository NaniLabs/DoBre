import 'package:dobre/models/app_config.dart';
import 'package:dobre/providers/theme_provider.dart';
import 'package:dobre/widgets/donaciones_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfiguracionSheet extends StatelessWidget {
  const ConfiguracionSheet({super.key, required this.config});

  final AppConfig? config;

  void _abrirDonaciones(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => DonacionesSheet(
        donationsConfig: config?.donations ?? const DonationsConfig(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Ajustes",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              title: const Text("Modo oscuro"),
              value: theme.modoOscuro,
              onChanged: theme.cambiarTema,
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              leading: Icon(
                Icons.volunteer_activism_rounded,
                color: colorScheme.primary,
              ),
              title: const Text("Apoyar a DoBre"),
              subtitle: const Text("Colaborá voluntariamente con el proyecto"),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _abrirDonaciones(context),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.secondary,
                child: const Icon(Icons.cloud_done_rounded, size: 20),
              ),
              title: const Text("Configuración de tarifas"),
              subtitle: Text(
                config == null
                    ? "Cargando..."
                    : "Versión ${config!.version} (Actualizable)",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

