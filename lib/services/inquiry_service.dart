import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Demandes d'achat / contact vendeur
class InquiryService {
  InquiryService._();
  static final InquiryService instance = InquiryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _inquiries =>
      _db.collection('inquiries');

  Future<String> createInquiry({
    required String carId,
    required String carName,
    required String message,
    String? phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final doc = await _inquiries.add({
      'carId': carId,
      'carName': carName,
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'userName': user.displayName ?? '',
      'message': message,
      'phone': phone ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Sans orderBy pour éviter l'index composite obligatoire.
  /// Le tri se fait côté client.
  Stream<QuerySnapshot<Map<String, dynamic>>> myInquiriesStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _inquiries.where('userId', isEqualTo: uid).snapshots();
  }
}

/// Demandes d'essai routier
class TestDriveService {
  TestDriveService._();
  static final TestDriveService instance = TestDriveService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _testDrives =>
      _db.collection('test_drives');

  Future<String> createTestDrive({
    required String carId,
    required String carName,
    required DateTime preferredDate,
    String? message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final doc = await _testDrives.add({
      'carId': carId,
      'carName': carName,
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'userName': user.displayName ?? '',
      'preferredDate': Timestamp.fromDate(preferredDate),
      'message': message ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myTestDrivesStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _testDrives.where('userId', isEqualTo: uid).snapshots();
  }
}