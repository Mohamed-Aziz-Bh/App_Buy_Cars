import 'package:cloud_firestore/cloud_firestore.dart';

class CarService {
  CarService._();
  static final CarService instance = CarService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _cars =>
      _db.collection('cars');

  /// Incrémente le compteur de vues (champ optionnel, créé s'il n'existe pas)
  Future<void> incrementViews(String carId) async {
    try {
      await _cars.doc(carId).update({
        'views': FieldValue.increment(1),
      });
    } catch (_) {
      // Si le champ n'existe pas encore, on l'initialise
      try {
        await _cars.doc(carId).set({
          'views': 1,
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Met à jour le statut (available / sold / reserved)
  /// Utile côté admin plus tard ; pour l'instant disponible si besoin
  Future<void> updateStatus(String carId, String status) async {
    await _cars.doc(carId).set({
      'status': status,
    }, SetOptions(merge: true));
  }

  /// Stream d'une voiture
  Stream<DocumentSnapshot<Map<String, dynamic>>> carStream(String carId) {
    return _cars.doc(carId).snapshots();
  }

  /// Récupère une voiture
  Future<DocumentSnapshot<Map<String, dynamic>>> getCar(String carId) {
    return _cars.doc(carId).get();
  }
}
