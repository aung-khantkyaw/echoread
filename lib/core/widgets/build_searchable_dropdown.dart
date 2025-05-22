import 'package:flutter/material.dart';

import 'build_text_field.dart';

Widget buildSearchableDropdown({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required List<Map<String, dynamic>> filteredItems,
  required String? selectedId,
  required Function(Map<String, dynamic>) onSelect,
  required String? Function(String?) validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildTextField(
        label: label,
        controller: controller,
        validator: validator,
      ),
      if (controller.text.isNotEmpty && filteredItems.isNotEmpty)
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (_, index) {
              final item = filteredItems[index];
              return ListTile(
                title: Text(item['name']),
                onTap: () {
                  onSelect(item);
                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
        ),
      const SizedBox(height: 16),
    ],
  );
}
