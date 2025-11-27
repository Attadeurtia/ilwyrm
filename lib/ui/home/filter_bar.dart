import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'filter_provider.dart';

import '../../data/database.dart';
import 'tag_filter_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilters = ref.watch(filterProvider);
    final selectedTagId = ref.watch(selectedTagProvider);
    final database = ref.watch(databaseProvider);

    return SizedBox(
      height: 50,
      child: FutureBuilder<List<Tag>>(
        future: database.getAllTags(),
        builder: (context, snapshot) {
          final tags = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: tags.length + 1, // +1 for Favoris
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Favoris Filter
                final isSelected = selectedFilters.contains('Favoris');
                return FilterChip(
                  label: const Text('Favoris'),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(filterProvider.notifier).toggleFilter('Favoris');
                  },
                );
              }

              final tag = tags[index - 1];
              final isSelected = selectedTagId == tag.id;
              return ChoiceChip(
                label: Text(tag.name),
                selected: isSelected,
                onSelected: (selected) {
                  ref
                      .read(selectedTagProvider.notifier)
                      .set(selected ? tag.id : null);
                },
              );
            },
          );
        },
      ),
    );
  }
}
