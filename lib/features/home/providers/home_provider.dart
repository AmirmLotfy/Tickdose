import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeTabProvider = NotifierProvider<HomeTabNotifier, int>(HomeTabNotifier.new);

class HomeTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

// Placeholder for future home data logic
final homeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'adherence': 85,
    'streak': 5,
  };
});
