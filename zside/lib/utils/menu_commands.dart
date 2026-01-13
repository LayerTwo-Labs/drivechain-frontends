import 'package:flutter/material.dart';

class CommandItem {
  final String label;
  final String category;
  final VoidCallback onSelected;
  final String? shortcut;

  const CommandItem({
    required this.label,
    required this.category,
    required this.onSelected,
    this.shortcut,
  });

  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return label.toLowerCase().contains(lowerQuery) || category.toLowerCase().contains(lowerQuery);
  }
}
