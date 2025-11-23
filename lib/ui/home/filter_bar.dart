import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'filter_provider.dart';

class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({super.key});

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  final List<String> _filters = [
    'Favoris',
    'BD',
    '2025',
    'Roman',
    'Label',
    '2024',
    'Sci-Fi',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedFilters = ref.watch(filterProvider);

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = selectedFilters.contains(filter);
          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              ref.read(filterProvider.notifier).toggleFilter(filter);
            },
          );
        },
      ),
    );
  }
}
