import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/item_car.dart';
import 'package:rent_cars_app/services/local_storage_service.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class RecentlyViewedPage extends StatefulWidget {
  const RecentlyViewedPage({super.key});

  @override
  State<RecentlyViewedPage> createState() => _RecentlyViewedPageState();
}

class _RecentlyViewedPageState extends State<RecentlyViewedPage> {
  List<String> _ids = [];

  @override
  void initState() {
    super.initState();
    LocalStorageService.instance.getRecentlyViewed().then((ids) {
      if (mounted) setState(() => _ids = ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Récemment consultées'),
        backgroundColor: AppColors.secondary,
      ),
      body: _ids.isEmpty
          ? const Center(
              child: Text(
                'Aucune voiture consultée récemment',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('cars').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final map = {
                  for (final d in snapshot.data!.docs) d.id: d,
                };
                final ordered = _ids
                    .where((id) => map.containsKey(id))
                    .map((id) => map[id]!)
                    .toList();
                if (ordered.isEmpty) {
                  return const Center(
                    child: Text('Aucune voiture trouvée'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 40, top: 8),
                  itemCount: ordered.length,
                  itemBuilder: (_, i) => CarItem.fromDocument(ordered[i]),
                );
              },
            ),
    );
  }
}
