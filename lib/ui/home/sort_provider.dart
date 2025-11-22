import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortOption { dateAdded, title, author }

class SortNotifier extends Notifier<SortOption> {
  @override
  SortOption build() {
    return SortOption.dateAdded;
  }

  void setSort(SortOption option) {
    state = option;
  }
}

final sortProvider = NotifierProvider<SortNotifier, SortOption>(
  SortNotifier.new,
);
