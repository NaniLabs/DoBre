import 'package:flutter/material.dart';

class PrecioTextField extends StatelessWidget {
  const PrecioTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: 10,
      decoration: const InputDecoration(
        labelText: "Monto objetivo",
        hintText: "Ej. 25000",
        prefixIcon: Icon(Icons.attach_money_rounded),
      ),
    );
  }
}
