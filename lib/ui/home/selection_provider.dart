import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final bool isSelecting;
  final Set<int> selectedIds;

  const SelectionState({this.isSelecting = false, this.selectedIds = const {}});

  SelectionState copyWith({bool? isSelecting, Set<int>? selectedIds}) {
    return SelectionState(
      isSelecting: isSelecting ?? this.isSelecting,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class SelectionNotifier extends Notifier<SelectionState> {
  @override
  SelectionState build() {
    return const SelectionState();
  }

  void select(int id) {
    final newIds = Set<int>.from(state.selectedIds)..add(id);
    state = state.copyWith(isSelecting: true, selectedIds: newIds);
  }

  void deselect(int id) {
    final newIds = Set<int>.from(state.selectedIds)..remove(id);
    if (newIds.isEmpty) {
      state = state.copyWith(isSelecting: false, selectedIds: {});
    } else {
      state = state.copyWith(selectedIds: newIds);
    }
  }

  void toggle(int id) {
    if (state.selectedIds.contains(id)) {
      deselect(id);
    } else {
      select(id);
    }
  }

  void clear() {
    state = const SelectionState();
  }
}

final selectionProvider = NotifierProvider<SelectionNotifier, SelectionState>(
  SelectionNotifier.new,
);
