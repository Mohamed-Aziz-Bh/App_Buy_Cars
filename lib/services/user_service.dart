import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service pour gérer les documents utilisateurs dans Firestore.
/// Crée automatiquement le document users/{uid} à la connexion / inscription.
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Crée le document utilisateur s'il n'existe pas encore.
  /// Appelé après login / signup / Google Sign-In.
  Future<void> ensureUserDocument({
    String? displayName,
    String? phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _users.doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': displayName ??
            user.displayName ??
            (user.email?.split('@').first ?? 'Utilisateur'),
        'phone': phone ?? '',
        'photoUrl': user.photoURL ?? '',
        'favoriteCarIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Met à jour les infos de base si elles ont changé (ex: photo Google)
      final data = snapshot.data();
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if ((data?['email'] ?? '') != (user.email ?? '')) {
        updates['email'] = user.email ?? '';
      }
      if ((user.photoURL ?? '').isNotEmpty &&
          (data?['photoUrl'] ?? '') != user.photoURL) {
        updates['photoUrl'] = user.photoURL;
      }

      if (updates.length > 1) {
        await docRef.update(updates);
      }
    }
  }

  /// Stream du document utilisateur courant
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _users.doc(uid).snapshots();
  }

  /// Récupère le document utilisateur une fois
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDoc() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _users.doc(uid).get();
  }

  /// Met à jour le profil (displayName, phone, photoUrl)
  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? photoUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) updates['displayName'] = displayName;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _users.doc(uid).update(updates);

    // Met aussi à jour Firebase Auth displayName si fourni
    if (displayName != null && _auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(displayName);
    }
  }

  /// Ajoute / retire une voiture des favoris
  Future<void> toggleFavorite(String carId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _users.doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await ensureUserDocument();
    }

    final data = (await docRef.get()).data();
    final List<String> favorites =
        List<String>.from(data?['favoriteCarIds'] ?? []);

    if (favorites.contains(carId)) {
      favorites.remove(carId);
    } else {
      favorites.add(carId);
    }

    await docRef.update({
      'favoriteCarIds': favorites,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Vérifie si une voiture est en favoris
  Future<bool> isFavorite(String carId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return false;

    final List<String> favorites =
        List<String>.from(snapshot.data()?['favoriteCarIds'] ?? []);
    return favorites.contains(carId);
  }

  /// Stream des IDs favoris
  Stream<List<String>> favoritesStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return <String>[];
      return List<String>.from(snap.data()?['favoriteCarIds'] ?? []);
    });
  }
}
