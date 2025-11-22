import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewOption { list, grid, gridWithDetails }

class ViewNotifier extends Notifier<ViewOption> {
  @override
  ViewOption build() {
    return ViewOption.list;
  }

  void setView(ViewOption option) {
    state = option;
  }

  void toggle() {
    switch (state) {
      case ViewOption.list:
        state = ViewOption.grid;
        break;
      case ViewOption.grid:
        state = ViewOption.gridWithDetails;
        break;
      case ViewOption.gridWithDetails:
        state = ViewOption.list;
        break;
    }
  }
}

final viewProvider = NotifierProvider<ViewNotifier, ViewOption>(
  ViewNotifier.new,
);
