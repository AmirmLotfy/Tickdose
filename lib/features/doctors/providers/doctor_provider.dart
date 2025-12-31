import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/core/services/doctor_service.dart';
import 'package:tickdose/features/doctors/models/doctor_model.dart';

final doctorListProvider = StreamProvider<List<Doctor>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final doctorService = DoctorService(user.uid);
  return doctorService.getDoctors();
});
