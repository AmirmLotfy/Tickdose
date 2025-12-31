import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/tracking/services/tracking_service.dart';

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService();
});

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final logsForSelectedDateProvider = StreamProvider<List<MedicineLogModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final date = ref.watch(selectedDateProvider);
  final service = ref.watch(trackingServiceProvider);
  return service.watchLogsForDay(user.uid, date);
});

final logsForCurrentMonthProvider = StreamProvider<List<MedicineLogModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final date = ref.watch(selectedDateProvider); // Re-fetch when date changes (simplification)
  final service = ref.watch(trackingServiceProvider);
  return service.watchLogsForMonth(user.uid, date);
});

final trackingControllerProvider = AsyncNotifierProvider<TrackingController, void>(TrackingController.new);

class TrackingController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null; // Return null (void)
  }

  TrackingService get _service => ref.read(trackingServiceProvider);
  String get _userId => ref.read(authStateProvider).value?.uid ?? '';

  Future<void> logMedicine(MedicineLogModel log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.logMedicine(log));
  }

  Future<void> updateLog(MedicineLogModel log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.updateLog(_userId, log));
  }

  Future<void> deleteLog(String logId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.deleteLog(_userId, logId));
  }
}
