import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/services/car_service.dart';
import 'package:rent_cars_app/services/review_service.dart';
import 'package:rent_cars_app/services/user_service.dart';
import 'package:rent_cars_app/theme/app_colors.dart';
import 'package:rent_cars_app/widgets/inquiry_sheet.dart';
import 'package:rent_cars_app/widgets/test_drive_sheet.dart';
import 'package:rent_cars_app/services/local_storage_service.dart';
import 'package:rent_cars_app/pages/finance_calculator_page.dart';
import 'package:rent_cars_app/chatscreen.dart';

import 'package:flutter/services.dart';

class CarDetailPage extends StatefulWidget {
  final String carId;

  const CarDetailPage({super.key, required this.carId});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  bool _isFavorite = false;
  double _avgRating = 0;
  bool _viewsIncremented = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await LocalStorageService.instance.addRecentlyViewed(widget.carId);
    final fav = await UserService.instance.isFavorite(widget.carId);
    final avg = await ReviewService.instance.averageRating(widget.carId);
    if (!_viewsIncremented) {
      await CarService.instance.incrementViews(widget.carId);
      _viewsIncremented = true;
    }
    if (mounted) {
      setState(() {
        _isFavorite = fav;
        _avgRating = avg;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await UserService.instance.toggleFavorite(widget.carId);
    setState(() => _isFavorite = !_isFavorite);
  }

  Color colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'noir':
        return Colors.black;
      case 'blanc':
        return Colors.white;
      case 'rouge':
        return Colors.red;
      case 'bleu':
        return Colors.blue;
      case 'vert':
        return Colors.green;
      case 'jaune':
        return Colors.yellow;
      case 'gris':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      case 'violet':
        return Colors.purple;
      case 'marron':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: CarService.instance.carStream(widget.carId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text("Voiture introuvable"));
          }

          final data = snapshot.data!.data()!;
          final name = data['name'] ?? '';
          final image = data['image'] ?? '';
          final price = "${data['price'] ?? 0} DT";
          final specs = data['specs'] ?? '';
          final colors = List<String>.from(data['colors'] ?? []);
          final status = data['status'] ?? 'available';
          final views = (data['views'] as num?)?.toInt() ?? 0;

          return CustomScrollView(
            slivers: [
              // App bar avec image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.secondary,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: _isFavorite ? AppColors.error : null,
                      ),
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_rounded, size: 20),
                    ),
                    onPressed: () {
                      final text =
                          "🚗 $name\n💰 $price\n📋 $specs\n\nDisponible sur Buy Cars";
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fiche copiée — collez-la dans WhatsApp"),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.secondary,
                      child: const Icon(Icons.directions_car,
                          size: 80, color: AppColors.textHint),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_avgRating > 0)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 22),
                                const SizedBox(width: 4),
                                Text(
                                  _avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _chip(
                            status == 'sold'
                                ? 'Vendue'
                                : status == 'reserved'
                                    ? 'Réservée'
                                    : 'Disponible',
                            status == 'sold'
                                ? AppColors.statusSold
                                : status == 'reserved'
                                    ? AppColors.statusReserved
                                    : AppColors.statusAvailable,
                          ),
                          const SizedBox(width: 8),
                          _chip('$views vues', AppColors.textSecondary),
                          const SizedBox(width: 8),
                          _chip(
                            _trustLabel(views, _avgRating, status),
                            AppColors.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Caractéristiques",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        specs,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (colors.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          "Couleurs disponibles",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: colors.map((c) {
                            return Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colorFromName(c),
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Boutons d'action
                      if (status != 'sold') ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showInquirySheet(
                                context,
                                carId: widget.carId,
                                carName: name,
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                            label: const Text("Demande d'achat"),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showTestDriveSheet(
                                context,
                                carId: widget.carId,
                                carName: name,
                              );
                            },
                            icon: const Icon(Icons.directions_car_outlined, size: 20),
                            label: const Text("Demander un essai"),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final p = double.tryParse(
                                            (data['price'] ?? 0).toString()) ??
                                        0;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FinanceCalculatorPage(
                                          initialPrice: p,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.calculate_outlined, size: 18),
                                  label: const Text("Financement", style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final ok = await LocalStorageService.instance
                                        .toggleCompare(widget.carId);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? "Ajoutée au comparateur"
                                            : "Retirée ou limite de 3 atteinte"),
                                        backgroundColor: ok
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.compare_arrows, size: 18),
                                  label: const Text("Comparer", style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    initialMessage:
                                        "Je regarde la voiture \"$name\" à $price. "
                                        "Quels sont les points forts et points de vigilance pour un achat ?",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.smart_toy_outlined, size: 20),
                            label: const Text("Avis de l'assistant IA"),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),
                      const Text(
                        "Voitures similaires",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SimilarCars(
                        carId: widget.carId,
                        price: (data['price'] as num?)?.toDouble() ?? 0,
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        "Avis",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ReviewsSection(carId: widget.carId),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _trustLabel(int views, double rating, String status) {
    if (status == 'sold') return 'Vendue';
    int score = 40;
    if (views > 50) {
      score += 20;
    } else if (views > 10) {
      score += 10;
    }
    if (rating >= 4) {
      score += 30;
    } else if (rating >= 3) {
      score += 15;
    }
    if (status == 'available') score += 10;
    if (score >= 80) return 'Confiance élevée';
    if (score >= 55) return 'Bonne annonce';
    return 'Nouvelle annonce';
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final String carId;

  const _ReviewsSection({required this.carId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ReviewService.instance.reviewsForCar(carId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Impossible de charger les avis",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            final docs = (snapshot.data?.docs ?? []).toList()
              ..sort((a, b) {
                final ta = a.data()['createdAt'];
                final tb = b.data()['createdAt'];
                if (ta == null && tb == null) return 0;
                if (ta == null) return 1;
                if (tb == null) return -1;
                return (tb as Timestamp).compareTo(ta as Timestamp);
              });

            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Aucun avis pour le moment",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data();
                final rating = (data['rating'] as num?)?.toDouble() ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        (data['userName'] as String? ?? 'A')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(data['userName'] ?? 'Anonyme'),
                    subtitle: Text(data['comment'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(rating.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showAddReviewDialog(context, carId),
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text("Laisser un avis"),
        ),
      ],
    );
  }

  void _showAddReviewDialog(BuildContext context, String carId) {
    double rating = 5;
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text("Votre avis"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () => setLocal(() => rating = i + 1.0),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Votre commentaire",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final comment = commentCtrl.text.trim();
                    if (comment.isEmpty) return;
                    try {
                      await ReviewService.instance.addReview(
                        carId: carId,
                        rating: rating,
                        comment: comment,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Avis publié"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erreur : $e"),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Publier"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


class _SimilarCars extends StatelessWidget {
  final String carId;
  final double price;

  const _SimilarCars({required this.carId, required this.price});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final others = snapshot.data!.docs.where((d) {
          if (d.id == carId) return false;
          final data = d.data() as Map<String, dynamic>;
          if ((data['status'] ?? 'available') == 'sold') return false;
          final p = (data['price'] as num?)?.toDouble() ?? 0;
          return (p - price).abs() <= price * 0.35 + 5000;
        }).take(8).toList();

        if (others.isEmpty) {
          return const Text(
            'Aucune suggestion pour le moment',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        return SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: others.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final doc = others[index];
              final d = doc.data() as Map<String, dynamic>;
              final name = d['name'] ?? '';
              final img = d['image'] ?? '';
              final p = '${d['price'] ?? 0} DT';
              return SizedBox(
                width: 160,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 2,
                  shadowColor: AppColors.shadow,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarDetailPage(carId: doc.id),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Image.network(
                            img,
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 110,
                              color: AppColors.secondary,
                              child: const Icon(Icons.directions_car),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
            },
          ),
        );
      },
    );
  }
}