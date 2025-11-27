import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedTagNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? tagId) {
    state = tagId;
  }
}

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, int?>(
  SelectedTagNotifier.new,
);
