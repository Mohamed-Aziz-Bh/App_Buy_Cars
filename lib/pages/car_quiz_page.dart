import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/item_car.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class CarQuizPage extends StatefulWidget {
  const CarQuizPage({super.key});

  @override
  State<CarQuizPage> createState() => _CarQuizPageState();
}

class _CarQuizPageState extends State<CarQuizPage> {
  int _step = 0;
  double? _budget;
  String? _usage; // city | mixed | family
  String? _priority; // price | comfort | style

  final budgets = [20000.0, 40000.0, 60000.0, 100000.0, 200000.0];
  final usages = [
    ('city', 'Ville / trajets courts'),
    ('mixed', 'Mixte ville-route'),
    ('family', 'Famille / longs trajets'),
  ];
  final priorities = [
    ('price', 'Le meilleur prix'),
    ('comfort', 'Confort & espace'),
    ('style', 'Style & prestige'),
  ];

  List<QueryDocumentSnapshot> _match(List<QueryDocumentSnapshot> all) {
    var list = all.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final price = (data['price'] as num?)?.toDouble() ?? 0;
      if (_budget != null && price > _budget!) return false;
      final status = data['status'] ?? 'available';
      if (status == 'sold') return false;
      return true;
    }).toList();

    list.sort((a, b) {
      final da = a.data() as Map<String, dynamic>;
      final db = b.data() as Map<String, dynamic>;
      final pa = (da['price'] as num?)?.toDouble() ?? 0;
      final pb = (db['price'] as num?)?.toDouble() ?? 0;
      if (_priority == 'price') return pa.compareTo(pb);
      // comfort/style: prefer mid-high price within budget as proxy
      return pb.compareTo(pa);
    });
    return list.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quelle voiture pour moi ?'),
        backgroundColor: AppColors.secondary,
      ),
      body: _step < 3 ? _questions() : _results(),
    );
  }

  Widget _questions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 3,
            color: AppColors.primary,
            backgroundColor: AppColors.secondary,
          ),
          const SizedBox(height: 24),
          if (_step == 0) ...[
            const Text('Quel est votre budget max ?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...budgets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _budget = b;
                      _step = 1;
                    }),
                    child: Text('Jusqu\'à ${b.toStringAsFixed(0)} DT'),
                  ),
                )),
          ],
          if (_step == 1) ...[
            const Text('Quel usage principal ?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...usages.map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _usage = u.$1;
                      _step = 2;
                    }),
                    child: Text(u.$2),
                  ),
                )),
          ],
          if (_step == 2) ...[
            const Text('Votre priorité ?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...priorities.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _priority = p.$1;
                      _step = 3;
                    }),
                    child: Text(p.$2),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _results() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final matched = _match(snapshot.data!.docs);
        return ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nos suggestions',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'Budget ≤ ${_budget?.toStringAsFixed(0)} DT'
                    '${_usage != null ? ' · $usage' : ''}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _step = 0;
                      _budget = null;
                      _usage = null;
                      _priority = null;
                    }),
                    child: const Text('Refaire le quiz'),
                  ),
                ],
              ),
            ),
            if (matched.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Aucune voiture ne correspond. Essayez un budget plus élevé.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ...matched.map((d) => CarItem.fromDocument(d)),
          ],
        );
      },
    );
  }

  String get usage {
    switch (_usage) {
      case 'city':
        return 'Ville';
      case 'family':
        return 'Famille';
      default:
        return 'Mixte';
    }
  }
}
