import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'filter_provider.dart';

import '../../data/database.dart';
import '../../data/repositories/books_repository.dart';
import 'tag_filter_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilters = ref.watch(filterProvider);
    final selectedTagId = ref.watch(selectedTagProvider);
    // Réactif : un tag créé depuis une fiche apparaît aussitôt ici.
    final tags = ref.watch(allTagsProvider).value ?? const <Tag>[];

    return SizedBox(
      height: 50,
      child: ListView.separated(
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
          final isSelected = selectedTagId.contains(tag.id);
          return FilterChip(
            label: Text(tag.name),
            selected: isSelected,
            onSelected: (selected) {
              ref.read(selectedTagProvider.notifier).toggle(tag.id);
            },
          );
        },
      ),
    );
  }
}
