import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggleFilter(String filter) {
    if (state.contains(filter)) {
      state = {...state}..remove(filter);
    } else {
      state = {...state, filter};
    }
  }

  bool isSelected(String filter) {
    return state.contains(filter);
  }
}

final filterProvider = NotifierProvider<FilterNotifier, Set<String>>(() {
  return FilterNotifier();
});
