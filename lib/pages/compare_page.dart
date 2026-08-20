import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/pages/car_detail_page.dart';
import 'package:rent_cars_app/services/local_storage_service.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  List<String> _ids = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await LocalStorageService.instance.getCompareIds();
    if (mounted) setState(() => _ids = ids);
  }

  Future<void> _clear() async {
    await LocalStorageService.instance.clearCompare();
    setState(() => _ids = []);
  }

  Future<void> _remove(String id) async {
    await LocalStorageService.instance.toggleCompare(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comparateur'),
        backgroundColor: AppColors.secondary,
        actions: [
          if (_ids.isNotEmpty)
            TextButton(onPressed: _clear, child: const Text('Vider')),
        ],
      ),
      body: _ids.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Ajoutez jusqu\'à 3 voitures depuis une fiche (bouton Comparer).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('cars').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cars = snapshot.data!.docs
                    .where((d) => _ids.contains(d.id))
                    .toList();
                if (cars.isEmpty) {
                  return const Center(child: Text('Aucune voiture à comparer'));
                }

                final width = MediaQuery.of(context).size.width;
                final cardW = cars.length == 1
                    ? width - 32
                    : (width - 24) / cars.length.clamp(1, 3);

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: cars.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            return SizedBox(
                              width: cardW.clamp(150.0, 280.0),
                              child: Card(
                                margin: const EdgeInsets.only(right: 10),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CarDetailPage(carId: doc.id),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Stack(
                                        children: [
                                          Image.network(
                                            d['image'] ?? '',
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              height: 120,
                                              color: AppColors.secondary,
                                              child: const Icon(
                                                  Icons.directions_car),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.white,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                iconSize: 16,
                                                onPressed: () =>
                                                    _remove(doc.id),
                                                icon: const Icon(Icons.close,
                                                    size: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d['name'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${d['price'] ?? 0} DT',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                            const Divider(height: 18),
                                            _line('Specs', d['specs'] ?? '—'),
                                            _line(
                                              'Statut',
                                              d['status'] ?? 'available',
                                            ),
                                            _line(
                                              'Vues',
                                              '${(d['views'] as num?)?.toInt() ?? 0}',
                                            ),
                                            if ((d['colors'] as List?)
                                                    ?.isNotEmpty ==
                                                true)
                                              _line(
                                                'Couleurs',
                                                (d['colors'] as List)
                                                    .join(', '),
                                              ),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          CarDetailPage(
                                                              carId: doc.id),
                                                    ),
                                                  );
                                                },
                                                child: const Text('Détails'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}