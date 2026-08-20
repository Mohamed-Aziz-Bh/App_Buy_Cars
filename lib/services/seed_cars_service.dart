import 'package:cloud_firestore/cloud_firestore.dart';

/// Service pour ajouter rapidement des voitures d'exemple dans Firestore.
/// À appeler UNE SEULE FOIS, puis retirer le bouton / l'appel.
class SeedCarsService {
  SeedCarsService._();
  static final SeedCarsService instance = SeedCarsService._();

  final _cars = FirebaseFirestore.instance.collection('cars');

  /// Construit une URL d'image pointant vers un vrai fichier Wikimedia
  /// Commons, choisi et vérifié manuellement pour correspondre exactement
  /// à la marque/au modèle de la voiture (contrairement à une recherche
  /// par mots-clés sur Unsplash, qui peut renvoyer n'importe quelle
  /// voiture). `Special:FilePath` redirige toujours vers la version
  /// actuelle du fichier sur le CDN de Wikimedia.
  static String _wiki(String filename, {int width = 800}) {
    final path = Uri.encodeComponent(filename);
    return 'https://commons.wikimedia.org/wiki/Special:FilePath/$path?width=$width';
  }

  /// Liste de voitures (marché tunisien / général) avec des photos
  /// Wikimedia Commons correspondant réellement à la marque et au modèle
  /// indiqués (vérifié manuellement fichier par fichier).
  static final List<Map<String, dynamic>> sampleCars = [
    {
      'name': 'Peugeot 208 Allure',
      'image': _wiki(
          '2019 Peugeot 208 GT Line PureTech Automatic 1.2 Front.jpg'),
      'price': 52000,
      'specs': 'Essence · 1.2 PureTech · 2022 · 35 000 km · Automatique',
      'colors': ['Blanc', 'Gris', 'Noir'],
      'status': 'available',
      'views': 12,
    },
    {
      'name': 'Renault Clio 5 Intens',
      'image': _wiki('2019 Renault Clio Iconic Front.jpg'),
      'price': 48000,
      'specs': 'Essence · 1.0 TCe · 2021 · 42 000 km · Manuelle',
      'colors': ['Rouge', 'Blanc', 'Bleu'],
      'status': 'available',
      'views': 28,
    },
    {
      'name': 'Volkswagen Golf 8 Style',
      'image': _wiki('Volkswagen Golf VIII IMG 2044.jpg'),
      'price': 95000,
      'specs': 'Diesel · 2.0 TDI · 2023 · 18 000 km · Automatique DSG',
      'colors': ['Noir', 'Gris', 'Blanc'],
      'status': 'available',
      'views': 45,
    },
    {
      'name': 'Toyota Corolla Hybrid',
      'image':
          _wiki('2023 Toyota Corolla Hybrid (E210) hatchback IMG 9884.jpg'),
      'price': 88000,
      'specs': 'Hybride · 1.8 · 2022 · 25 000 km · Automatique',
      'colors': ['Blanc', 'Argent', 'Bleu'],
      'status': 'available',
      'views': 61,
    },
    {
      'name': 'Hyundai Tucson Creative',
      'image': _wiki('Hyundai Tucson (NX4) 1X7A0424.jpg'),
      'price': 115000,
      'specs': 'Diesel · 1.6 CRDi · 2023 · 12 000 km · Automatique',
      'colors': ['Noir', 'Blanc', 'Vert'],
      'status': 'available',
      'views': 33,
    },
    {
      'name': 'Kia Sportage GT-Line',
      'image': _wiki('2023 Kia Sportage (NQ5) in White, front left.jpg'),
      'price': 125000,
      'specs': 'Essence · 1.6 T-GDi · 2024 · 5 000 km · Automatique',
      'colors': ['Gris', 'Rouge', 'Noir'],
      'status': 'available',
      'views': 19,
    },
    {
      'name': 'Mercedes-Benz Classe A 200',
      'image': _wiki('Mercedes-Benz A 200 (W177, 2021) (54812650862).jpg'),
      'price': 145000,
      'specs': 'Essence · 1.3 · 2022 · 30 000 km · Automatique 7G-DCT',
      'colors': ['Blanc', 'Noir', 'Gris'],
      'status': 'available',
      'views': 72,
    },
    {
      'name': 'BMW Série 3 320d',
      'image': _wiki('BMW 3 Series (G20).jpg'),
      'price': 165000,
      'specs': 'Diesel · 2.0 · 2021 · 55 000 km · Automatique',
      'colors': ['Noir', 'Bleu', 'Blanc'],
      'status': 'available',
      'views': 88,
    },
    {
      'name': 'Audi A3 Sportback',
      'image': _wiki(
          'Audi A3 Sportback 35 TFSI S Line 8Y Manhattan Grey Metallic (5).jpg'),
      'price': 135000,
      'specs': 'Essence · 1.5 TFSI · 2022 · 28 000 km · S-tronic',
      'colors': ['Gris', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 41,
    },
    {
      'name': 'Dacia Duster Prestige',
      'image': _wiki('2024 Dacia Duster front.jpg'),
      'price': 62000,
      'specs': 'Diesel · 1.5 dCi · 2022 · 40 000 km · Manuelle 4x2',
      'colors': ['Orange', 'Blanc', 'Gris'],
      'status': 'available',
      'views': 55,
    },
    {
      'name': 'Seat Ibiza FR',
      'image': _wiki('2018 SEAT Ibiza SE Technology MPi 1.0 Front.jpg'),
      'price': 45000,
      'specs': 'Essence · 1.0 TSI · 2021 · 38 000 km · Manuelle',
      'colors': ['Rouge', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 22,
    },
    {
      'name': 'Fiat 500 Lounge',
      'image': _wiki('2016 Fiat 500 Lounge 1.2 Front.jpg'),
      'price': 38000,
      'specs': 'Essence · 1.2 · 2020 · 50 000 km · Manuelle',
      'colors': ['Blanc', 'Rouge', 'Jaune'],
      'status': 'available',
      'views': 17,
    },
    {
      'name': 'Ford Focus ST-Line',
      'image': _wiki('2018 Ford Focus ST-Line Front.jpg'),
      'price': 72000,
      'specs': 'Essence · 1.5 EcoBoost · 2022 · 32 000 km · Automatique',
      'colors': ['Bleu', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 29,
    },
    {
      'name': 'Nissan Qashqai Tekna',
      'image': _wiki('Nissan Qashqai (J12) IMG 4897.jpg'),
      'price': 98000,
      'specs': 'Essence · 1.3 DIG-T · 2023 · 15 000 km · Automatique',
      'colors': ['Gris', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 36,
    },
    {
      'name': 'Mazda CX-5 Exclusive',
      'image': _wiki('Mazda CX-5 (KF) 1X7A0333.jpg'),
      'price': 110000,
      'specs': 'Essence · 2.0 Skyactiv · 2022 · 22 000 km · Automatique',
      'colors': ['Rouge', 'Blanc', 'Gris'],
      'status': 'available',
      'views': 24,
    },
    {
      'name': 'Skoda Octavia Ambition',
      'image': _wiki('Škoda Octavia Mk3 Facelift.jpg'),
      'price': 78000,
      'specs': 'Diesel · 2.0 TDI · 2021 · 48 000 km · DSG',
      'colors': ['Blanc', 'Gris', 'Bleu'],
      'status': 'available',
      'views': 31,
    },
    {
      'name': 'Citroën C3 Shine',
      'image': _wiki('2021 Citroën C3 1.5 HDi facelift.jpg'),
      'price': 42000,
      'specs': 'Essence · 1.2 PureTech · 2021 · 45 000 km · Manuelle',
      'colors': ['Orange', 'Blanc', 'Gris'],
      'status': 'available',
      'views': 14,
    },
    {
      'name': 'Opel Corsa GS Line',
      'image': _wiki('2022 Opel Corsa 1.2T Edition.jpg'),
      'price': 46000,
      'specs': 'Essence · 1.2 Turbo · 2022 · 27 000 km · Automatique',
      'colors': ['Rouge', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 20,
    },
    {
      'name': 'Suzuki Swift Sport',
      'image': _wiki('Suzuki Swift Sport ZC33S.jpg'),
      'price': 55000,
      'specs': 'Essence · 1.4 Boosterjet · 2021 · 33 000 km · Manuelle',
      'colors': ['Jaune', 'Blanc', 'Noir'],
      'status': 'available',
      'views': 26,
    },
    {
      'name': 'Honda Civic Executive',
      'image': _wiki(
          '2022 Honda Civic Sedan EX in Platinum White Pearl, front left.jpg'),
      'price': 92000,
      'specs': 'Essence · 1.5 VTEC Turbo · 2022 · 20 000 km · CVT',
      'colors': ['Rouge', 'Blanc', 'Gris'],
      'status': 'available',
      'views': 39,
    },
    {
      'name': 'Tesla Model 3 Standard',
      'image': _wiki('2023 Tesla Model 3 Highland Long Range.jpg'),
      'price': 175000,
      'specs': 'Électrique · 450 km autonomie · 2023 · 10 000 km · Auto',
      'colors': ['Blanc', 'Noir', 'Rouge'],
      'status': 'available',
      'views': 95,
    },
    {
      'name': 'Peugeot 3008 GT',
      'image': _wiki('Peugeot 3008 2023.jpg'),
      'price': 118000,
      'specs': 'Hybride · 1.6 Hybrid · 2023 · 14 000 km · Automatique',
      'colors': ['Gris', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 47,
    },
    {
      'name': 'Renault Captur Techno',
      'image':
          _wiki('Renault Captur II TCe 140 GPF (2022) (53050845104).jpg'),
      'price': 68000,
      'specs': 'Essence · 1.3 TCe · 2022 · 29 000 km · Automatique',
      'colors': ['Orange', 'Bleu', 'Blanc'],
      'status': 'reserved',
      'views': 18,
    },
    {
      'name': 'Volkswagen T-Roc R-Line',
      'image': _wiki('Volkswagen T-Roc facelift 001.jpg'),
      'price': 105000,
      'specs': 'Essence · 1.5 TSI · 2023 · 11 000 km · DSG',
      'colors': ['Blanc', 'Noir', 'Gris'],
      'status': 'available',
      'views': 52,
    },
    {
      'name': 'Toyota RAV4 Hybrid',
      'image': _wiki(
          'Toyota RAV4 Hybrid 2.5 XLE XA50 FL Platinum White Pearl Mica (1).jpg'),
      'price': 155000,
      'specs': 'Hybride · 2.5 · 2023 · 8 000 km · Automatique AWD',
      'colors': ['Blanc', 'Gris', 'Bleu'],
      'status': 'available',
      'views': 67,
    },
    {
      'name': 'Mercedes GLC 220d',
      'image': _wiki('2023 Mercedes-Benz GLC 300 4MATIC front.jpg'),
      'price': 210000,
      'specs': 'Diesel · 2.0 · 2022 · 35 000 km · 9G-Tronic',
      'colors': ['Noir', 'Blanc', 'Gris'],
      'status': 'available',
      'views': 103,
    },
    {
      'name': 'BMW X1 sDrive18d',
      'image': _wiki(
          '2022 BMW X1 sDrive18d M Sport MHEV Automatic 2.0 Front.jpg'),
      'price': 148000,
      'specs': 'Diesel · 2.0 · 2022 · 27 000 km · Automatique',
      'colors': ['Blanc', 'Noir', 'Bleu'],
      'status': 'available',
      'views': 58,
    },
    {
      'name': 'Audi Q3 S-Line',
      'image':
          _wiki('Audi Q3 Sportback 35 TFSI S line (3AA-F3DFY) front.jpg'),
      'price': 168000,
      'specs': 'Essence · 2.0 TFSI · 2023 · 9 000 km · S-tronic',
      'colors': ['Gris', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 74,
    },
    {
      'name': 'Dacia Sandero Stepway',
      'image': _wiki('Dacia Sandero III 1X7A0329.jpg'),
      'price': 35000,
      'specs': 'Essence · 1.0 TCe · 2022 · 28 000 km · Manuelle',
      'colors': ['Orange', 'Blanc', 'Gris'],
      'status': 'available',
      'views': 43,
    },
    {
      'name': 'Hyundai i20 N Line',
      'image': _wiki('Hyundai i20 (BC3) IMG 5670.jpg'),
      'price': 49000,
      'specs': 'Essence · 1.0 T-GDi · 2023 · 16 000 km · Manuelle',
      'colors': ['Rouge', 'Noir', 'Blanc'],
      'status': 'available',
      'views': 21,
    },
  ];

  /// Ajoute toutes les voitures d'exemple (batch).
  /// Retourne le nombre de documents créés.
  Future<int> seedAll() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    var inBatch = 0;
    var total = 0;

    for (final car in sampleCars) {
      final ref = _cars.doc();
      batch.set(ref, {
        ...car,
        'createdAt': FieldValue.serverTimestamp(),
      });
      inBatch++;
      total++;
      if (inBatch >= 400) {
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();
        inBatch = 0;
      }
    }

    if (inBatch > 0) {
      await batch.commit();
    }
    return total;
  }
}
