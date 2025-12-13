import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedTagNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void toggle(int tagId) {
    if (state.contains(tagId)) {
      state = {...state}..remove(tagId);
    } else {
      state = {...state, tagId};
    }
  }

  void clear() {
    state = {};
  }
}

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, Set<int>>(
  SelectedTagNotifier.new,
);
