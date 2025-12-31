import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/features/doctors/models/doctor_model.dart';
import 'package:tickdose/core/utils/logger.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  DoctorService(this.userId);

  CollectionReference get _doctorsCollection =>
      _firestore.collection('users').doc(userId).collection('doctors');

  Future<void> addDoctor(Doctor doctor) async {
    try {
      await _doctorsCollection.doc(doctor.id).set(doctor.toMap());
      Logger.info('Doctor added successfully: ${doctor.name}');
    } catch (e) {
      Logger.error('Error adding doctor: $e');
      rethrow;
    }
  }

  Future<void> updateDoctor(Doctor doctor) async {
    try {
      await _doctorsCollection.doc(doctor.id).update(doctor.toMap());
      Logger.info('Doctor updated successfully: ${doctor.name}');
    } catch (e) {
      Logger.error('Error updating doctor: $e');
      rethrow;
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      await _doctorsCollection.doc(id).delete();
      Logger.info('Doctor deleted successfully: $id');
    } catch (e) {
      Logger.error('Error deleting doctor: $e');
      rethrow;
    }
  }

  Stream<List<Doctor>> getDoctors() {
    return _doctorsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
