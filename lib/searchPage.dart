import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/item_car.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rechercher des voitures"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Rechercher une voiture...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.deepPurple.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cars')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cars = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] as String).toLowerCase();
                  return name.contains(_searchText);
                }).toList();

                if (cars.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucune voiture trouvée",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    final List<String> colors = [];
                    if (car['colors'] != null) {
                      colors.addAll(List<String>.from(car['colors']));
                    }

                    return CarItem(
                      name: car['name'],
                      image: car['image'],
                      price: car['price'].toString()+ " DT",
                      specs: car['specs'],
                      colors: colors,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
