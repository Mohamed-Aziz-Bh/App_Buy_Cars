import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/item_car.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String _sortBy = 'name';
  String _statusFilter = 'all'; // all | available | sold | reserved
  double? _minPrice;
  double? _maxPrice;
  String? _colorFilter;

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomSafe = MediaQuery.of(ctx).padding.bottom;
        final keyboard = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: keyboard),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomSafe),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Filtres avancés',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Statut', style: TextStyle(fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in [
                      ('all', 'Tous'),
                      ('available', 'Disponible'),
                      ('reserved', 'Réservée'),
                      ('sold', 'Vendue'),
                    ])
                      ChoiceChip(
                        label: Text(e.$2),
                        selected: _statusFilter == e.$1,
                        onSelected: (_) =>
                            setState(() => _statusFilter = e.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix min',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix max',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Couleur (ex: Noir)',
                  ),
                  onChanged: (v) =>
                      _colorFilter = v.trim().isEmpty ? null : v.trim(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _minPrice = double.tryParse(_minCtrl.text);
                      _maxPrice = double.tryParse(_maxCtrl.text);
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Appliquer'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _statusFilter = 'all';
                      _minPrice = null;
                      _maxPrice = null;
                      _colorFilter = null;
                      _minCtrl.clear();
                      _maxCtrl.clear();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchText = value.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: "Rechercher une voiture...",
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchText = "");
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _openFilters,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _sortChip('Nom', 'name'),
                const SizedBox(width: 8),
                _sortChip('Prix ↑', 'price_asc'),
                const SizedBox(width: 8),
                _sortChip('Prix ↓', 'price_desc'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('cars').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var cars = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] as String? ?? '').toLowerCase();
                  final specs = (data['specs'] as String? ?? '').toLowerCase();
                  final price = (data['price'] as num?)?.toDouble() ?? 0;
                  final status = data['status'] ?? 'available';
                  final colors = List<String>.from(data['colors'] ?? []);

                  if (_searchText.isNotEmpty &&
                      !name.contains(_searchText) &&
                      !specs.contains(_searchText)) {
                    return false;
                  }
                  if (_statusFilter != 'all' && status != _statusFilter) {
                    return false;
                  }
                  if (_minPrice != null && price < _minPrice!) return false;
                  if (_maxPrice != null && price > _maxPrice!) return false;
                  if (_colorFilter != null &&
                      !colors.any((c) =>
                          c.toLowerCase().contains(_colorFilter!.toLowerCase()))) {
                    return false;
                  }
                  return true;
                }).toList();

                cars.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  switch (_sortBy) {
                    case 'price_asc':
                      return ((da['price'] as num?) ?? 0)
                          .compareTo((db['price'] as num?) ?? 0);
                    case 'price_desc':
                      return ((db['price'] as num?) ?? 0)
                          .compareTo((da['price'] as num?) ?? 0);
                    default:
                      return ((da['name'] as String?) ?? '')
                          .compareTo((db['name'] as String?) ?? '');
                  }
                });

                if (cars.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 56, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text(
                          "Aucune voiture trouvée",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100, top: 8),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    return CarItem.fromDocument(cars[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final selected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _sortBy = value),
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}