import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/pages/car_detail_page.dart';
import 'package:rent_cars_app/services/user_service.dart';
import 'package:rent_cars_app/theme/app_colors.dart';
import 'package:rent_cars_app/widgets/inquiry_sheet.dart';

class CarItem extends StatefulWidget {
  final String id;
  final String name;
  final String image;
  final String price;
  final String specs;
  final List<String> colors;
  final String status;
  final int views;

  const CarItem({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.specs,
    required this.colors,
    this.status = 'available',
    this.views = 0,
  });

  factory CarItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CarItem(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: "${data['price'] ?? 0} DT",
      specs: data['specs'] ?? '',
      colors: List<String>.from(data['colors'] ?? []),
      status: data['status'] ?? 'available',
      views: (data['views'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  State<CarItem> createState() => _CarItemState();
}

class _CarItemState extends State<CarItem> {
  bool _isFavorite = false;
  bool _favLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await UserService.instance.isFavorite(widget.id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    setState(() => _favLoading = true);
    try {
      await UserService.instance.toggleFavorite(widget.id);
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur favoris : $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _favLoading = false);
    }
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

  Color _statusColor() {
    switch (widget.status) {
      case 'sold':
        return AppColors.statusSold;
      case 'reserved':
        return AppColors.statusReserved;
      default:
        return AppColors.statusAvailable;
    }
  }

  String _statusLabel() {
    switch (widget.status) {
      case 'sold':
        return 'Vendue';
      case 'reserved':
        return 'Réservée';
      default:
        return 'Disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CarDetailPage(carId: widget.id),
            ),
          );
        },
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + badge statut + favori
          Stack(
            children: [
              Image.network(
                widget.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.secondary.withOpacity(0.5),
                  child: const Center(
                    child: Icon(Icons.directions_car_rounded,
                        size: 56, color: AppColors.textHint),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white.withOpacity(0.9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _favLoading ? null : _toggleFavorite,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _favLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _isFavorite
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.specs,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (widget.views > 0)
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined,
                              size: 16, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.views}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                if (widget.colors.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        "Couleurs : ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      ...widget.colors.map((colorName) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: colorFromName(colorName),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        );
                      }),
                    ],
                  ),
                ],

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.status == 'sold'
                            ? null
                            : () {
                                showInquirySheet(
                                  context,
                                  carId: widget.id,
                                  carName: widget.name,
                                );
                              },
                        child: const Text("Acheter"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarDetailPage(carId: widget.id),
                            ),
                          );
                        },
                        child: const Text("Détails"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}