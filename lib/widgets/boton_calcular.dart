import 'package:flutter/material.dart';

class BotonCalcular extends StatelessWidget {
  const BotonCalcular({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.auto_graph_rounded),
        label: const Text("Calcular precio"),
      ),
    );
  }
}
