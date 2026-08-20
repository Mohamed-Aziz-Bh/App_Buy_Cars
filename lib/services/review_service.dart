import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  Future<void> addReview({
    required String carId,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    if (rating < 1 || rating > 5) throw Exception('Note invalide');

    final existing = await _reviews
        .where('carId', isEqualTo: carId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _reviews.add({
        'carId': carId,
        'userId': user.uid,
        'userName':
            user.displayName ?? user.email?.split('@').first ?? 'Anonyme',
        'userEmail': user.email ?? '',
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Sans orderBy (évite index composite). Tri côté client.
  Stream<QuerySnapshot<Map<String, dynamic>>> reviewsForCar(String carId) {
    return _reviews.where('carId', isEqualTo: carId).snapshots();
  }

  Future<double> averageRating(String carId) async {
    try {
      final snap = await _reviews.where('carId', isEqualTo: carId).get();
      if (snap.docs.isEmpty) return 0;
      double sum = 0;
      for (final doc in snap.docs) {
        sum += (doc.data()['rating'] as num).toDouble();
      }
      return sum / snap.docs.length;
    } catch (_) {
      return 0;
    }
  }
}