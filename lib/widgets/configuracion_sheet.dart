import 'package:dobre/models/app_config.dart';
import 'package:dobre/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfiguracionSheet extends StatelessWidget {
  const ConfiguracionSheet({super.key, required this.config});

  final AppConfig? config;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
              "Configuracion",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
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
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.secondary,
                child: const Icon(Icons.info_outline_rounded),
              ),
              title: const Text("Configuracion remota"),
              subtitle: Text(
                config == null ? "Cargando..." : "Version ${config!.version}",
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
