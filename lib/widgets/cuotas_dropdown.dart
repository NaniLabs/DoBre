import 'package:dobre/models/app_config.dart';
import 'package:flutter/material.dart';

class CuotasDropdown extends StatelessWidget {
  const CuotasDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<InstallmentOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(20),
      icon: const Icon(Icons.expand_more_rounded),
      decoration: const InputDecoration(
        labelText: "Financiacion",
        prefixIcon: Icon(Icons.credit_score_rounded),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.id,
              child: Text(option.label),
            ),
          )
          .toList(growable: false),
    );
  }
}
