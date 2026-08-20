import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cars_app/item_car.dart';
import 'package:rent_cars_app/offer_page.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        key: _refreshKey,
        color: AppColors.primary,
        onRefresh: () async {
          // Le StreamBuilder se met à jour automatiquement ;
          // on force un petit délai pour le feedback utilisateur
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) setState(() {});
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: OfferPage()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      "Nos véhicules",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.local_offer_outlined,
                        size: 18, color: AppColors.primary.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('cars').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          const Text(
                            "Erreur de connexion",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: const Text("Réessayer"),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "Aucune voiture disponible",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                final carsDocs = snapshot.data!.docs;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return CarItem.fromDocument(carsDocs[index]);
                    },
                    childCount: carsDocs.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
