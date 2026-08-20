import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/item_car.dart';
import 'package:rent_cars_app/services/inquiry_service.dart';
import 'package:rent_cars_app/pages/tools_hub_page.dart';
import 'package:rent_cars_app/services/user_service.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _emailController.text = currentUser?.email ?? '';
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await UserService.instance.ensureUserDocument();
    final doc = await UserService.instance.getUserDoc();
    if (doc != null && doc.exists && mounted) {
      final data = doc.data();
      setState(() {
        _displayNameController.text = data?['displayName'] ?? '';
        _phoneController.text = data?['phone'] ?? '';
      });
    }
  }

  Future<void> _reauthenticate(String currentPassword) async {
    if (currentPassword.isEmpty) {
      throw FirebaseAuthException(
        code: 'empty-password',
        message: 'Veuillez entrer votre mot de passe actuel.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: currentUser!.email!,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> updateEmail() async {
    final newEmail = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text;
    if (newEmail.isEmpty || newEmail == currentUser?.email) return;

    setState(() => _isLoading = true);
    try {
      await _reauthenticate(currentPassword);
      await currentUser!.verifyBeforeUpdateEmail(newEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Un email de vérification a été envoyé à $newEmail.",
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _currentPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      _showAuthError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> updatePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final currentPassword = _currentPasswordController.text;

    if (newPassword.isEmpty || newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _reauthenticate(currentPassword);
      await currentUser!.updatePassword(newPassword);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mot de passe mis à jour"),
          backgroundColor: AppColors.success,
        ),
      );
      _newPasswordController.clear();
      _currentPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      _showAuthError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> updateProfileInfo() async {
    setState(() => _isLoading = true);
    try {
      await UserService.instance.updateProfile(
        displayName: _displayNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil mis à jour"),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'wrong-password':
        message = 'Mot de passe actuel incorrect.';
        break;
      case 'invalid-email':
        message = 'Adresse email invalide.';
        break;
      case 'email-already-in-use':
        message = 'Cette adresse email est déjà utilisée.';
        break;
      case 'requires-recent-login':
        message = 'Veuillez vous reconnecter.';
        break;
      case 'empty-password':
        message = e.message ?? 'Mot de passe requis.';
        break;
      default:
        message = e.message ?? 'Erreur';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  backgroundImage: (currentUser?.photoURL ?? '').isNotEmpty
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: (currentUser?.photoURL ?? '').isEmpty
                      ? Text(
                          (_displayNameController.text.isNotEmpty
                                  ? _displayNameController.text[0]
                                  : (currentUser?.email?[0] ?? 'U'))
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  _displayNameController.text.isNotEmpty
                      ? _displayNameController.text
                      : (currentUser?.displayName ?? 'Utilisateur'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Profil"),
              Tab(text: "Favoris"),
              Tab(text: "Demandes"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildFavoritesTab(),
                _buildRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _dashboardStats(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ToolsHubPage()),
              );
            },
            icon: const Icon(Icons.handyman_outlined),
            label: const Text('Outils (financement, quiz, comparateur...)'),
          ),
          const SizedBox(height: 20),
          const Text(
            "Informations personnelles",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              hintText: "Nom d'affichage",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: "Téléphone",
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : updateProfileInfo,
            child: const Text("Enregistrer le profil"),
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            "Sécurité",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              hintText: "Mot de passe actuel",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              hintText: "Nouvel email",
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : updateEmail,
            child: const Text("Changer l'email"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              hintText: "Nouveau mot de passe",
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : updatePassword,
            child: const Text("Changer le mot de passe"),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }


  Widget _dashboardStats() {
    return StreamBuilder<List<String>>(
      stream: UserService.instance.favoritesStream(),
      builder: (context, favSnap) {
        final favCount = favSnap.data?.length ?? 0;
        return StreamBuilder(
          stream: InquiryService.instance.myInquiriesStream(),
          builder: (context, inqSnap) {
            final inqCount = inqSnap.hasData ? inqSnap.data!.docs.length : 0;
            return StreamBuilder(
              stream: TestDriveService.instance.myTestDrivesStream(),
              builder: (context, tdSnap) {
                final tdCount = tdSnap.hasData ? tdSnap.data!.docs.length : 0;
                return Row(
                  children: [
                    _statCard('Favoris', '$favCount', Icons.favorite_rounded),
                    const SizedBox(width: 8),
                    _statCard('Achats', '$inqCount', Icons.shopping_bag_outlined),
                    const SizedBox(width: 8),
                    _statCard('Essais', '$tdCount', Icons.directions_car_outlined),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return StreamBuilder<List<String>>(
      stream: UserService.instance.favoritesStream(),
      builder: (context, favSnap) {
        if (!favSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final ids = favSnap.data!;
        if (ids.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded,
                    size: 56, color: AppColors.textHint),
                SizedBox(height: 12),
                Text(
                  "Aucun favori",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('cars').snapshots(),
          builder: (context, carSnap) {
            if (!carSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final favCars = carSnap.data!.docs
                .where((doc) => ids.contains(doc.id))
                .toList();

            if (favCars.isEmpty) {
              return const Center(
                child: Text(
                  "Aucune voiture favorite trouvée",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, top: 8),
              itemCount: favCars.length,
              itemBuilder: (context, index) {
                return CarItem.fromDocument(favCars[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: "Achats"),
              Tab(text: "Essais"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _inquiriesList(),
                _testDrivesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inquiriesList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: InquiryService.instance.myInquiriesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Erreur de chargement : ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Aucune demande d'achat",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final ta = a.data()['createdAt'];
            final tb = b.data()['createdAt'];
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return (tb as Timestamp).compareTo(ta as Timestamp);
          });
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return _requestCard(
              title: data['carName'] ?? 'Voiture',
              subtitle: data['message'] ?? '',
              status: data['status'] ?? 'pending',
            );
          },
        );
      },
    );
  }

  Widget _testDrivesList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: TestDriveService.instance.myTestDrivesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Erreur de chargement : ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Aucune demande d'essai",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final ta = a.data()['createdAt'];
            final tb = b.data()['createdAt'];
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return (tb as Timestamp).compareTo(ta as Timestamp);
          });
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            String dateStr = '';
            if (data['preferredDate'] != null) {
              final ts = data['preferredDate'] as Timestamp;
              final d = ts.toDate();
              dateStr = "${d.day}/${d.month}/${d.year}";
            }
            return _requestCard(
              title: data['carName'] ?? 'Voiture',
              subtitle: dateStr.isNotEmpty
                  ? "Date souhaitée : $dateStr\n${data['message'] ?? ''}"
                  : (data['message'] ?? ''),
              status: data['status'] ?? 'pending',
            );
          },
        );
      },
    );
  }

  Widget _requestCard({
    required String title,
    required String subtitle,
    required String status,
  }) {
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'contacted':
      case 'confirmed':
        statusColor = AppColors.info;
        statusLabel = status == 'confirmed' ? 'Confirmé' : 'Contacté';
        break;
      case 'closed':
      case 'completed':
        statusColor = AppColors.success;
        statusLabel = 'Terminé';
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = AppColors.error;
        statusLabel = 'Annulé';
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = 'En attente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}