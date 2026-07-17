import 'package:dobre/models/app_config.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.value,
    required this.categories,
    required this.onSelected,
    this.label = 'Categoria',
  });

  final String value;
  final List<CategoryConfig> categories;
  final ValueChanged<String> onSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      key: ValueKey(value),
      initialSelection: value,
      expandedInsets: EdgeInsets.zero,
      enableFilter: true,
      enableSearch: true,
      requestFocusOnTap: false,
      leadingIcon: const Icon(Icons.category_outlined),
      label: Text(label),
      dropdownMenuEntries: categories
          .map(
            (category) => DropdownMenuEntry<String>(
              value: category.id,
              label: category.name,
            ),
          )
          .toList(growable: false),
      onSelected: (selected) {
        if (selected != null) {
          onSelected(selected);
        }
      },
    );
  }
}
