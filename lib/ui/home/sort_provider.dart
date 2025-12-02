import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/enums.dart';

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
