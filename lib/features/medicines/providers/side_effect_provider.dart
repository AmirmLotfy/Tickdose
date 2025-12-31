import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/side_effect_log_model.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/medicines/services/side_effect_service.dart';

final sideEffectServiceProvider = Provider<SideEffectService>((ref) {
  return SideEffectService();
});

final allSideEffectsProvider = StreamProvider<List<SideEffectLog>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final service = ref.watch(sideEffectServiceProvider);
  return service.watchSideEffects(user.uid);
});

final sideEffectControllerProvider = AsyncNotifierProvider<SideEffectController, void>(SideEffectController.new);

class SideEffectController extends AsyncNotifier<void> {
  SideEffectService get _service => ref.read(sideEffectServiceProvider);

  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> logSideEffect(SideEffectLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.logSideEffect(log));
  }

  Future<void> deleteSideEffect(String userId, String effectId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.deleteSideEffect(userId, effectId));
  }
}
