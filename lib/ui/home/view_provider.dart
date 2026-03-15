import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/settings_repository.dart';

enum ViewOption { list, grid, gridWithDetails }

const _kViewPrefKey = 'home_view_option';

class ViewNotifier extends Notifier<ViewOption> {
  static const _values = ViewOption.values;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  ViewOption build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_kViewPrefKey);
    return _values.firstWhere(
      (v) => v.name == saved,
      orElse: () => ViewOption.list,
    );
  }

  void setView(ViewOption option) {
    state = option;
    _prefs.setString(_kViewPrefKey, option.name);
  }

  void toggle() {
    final next = _values[(_values.indexOf(state) + 1) % _values.length];
    setView(next);
  }
}

final viewProvider = NotifierProvider<ViewNotifier, ViewOption>(
  ViewNotifier.new,
);
