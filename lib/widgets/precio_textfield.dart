import 'package:flutter/material.dart';

class PrecioTextField extends StatelessWidget {
  const PrecioTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.done,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 14,
          decoration: InputDecoration(
            labelText: "Monto objetivo (lo que querés recibir)",
            hintText: "Ej. 35000",
            helperText: "Dinero neto libre de comisiones que querés cobrar",
            prefixIcon: const Icon(Icons.attach_money_rounded),
            counterText: "",
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    tooltip: "Borrar monto",
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}


