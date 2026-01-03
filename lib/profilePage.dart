import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _emailController.text = currentUser?.email ?? '';
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Un email de vérification a été envoyé à $newEmail. "
            "Cliquez sur le lien pour confirmer le changement.",
          ),
          backgroundColor: Colors.green,
        ),
      );

      _currentPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Mot de passe actuel incorrect.';
          break;
        case 'invalid-email':
          message = 'Nouvelle adresse email invalide.';
          break;
        case 'email-already-in-use':
          message = 'Cette adresse email est déjà utilisée.';
          break;
        case 'requires-recent-login':
          message = 'Veuillez vous reconnecter pour effectuer cette opération.';
          break;
        case 'empty-password':
          message = e.message ?? 'Mot de passe actuel requis.';
          break;
        default:
          message = 'Erreur : ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> updatePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final currentPassword = _currentPasswordController.text;

    if (newPassword.isEmpty || newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nouveau mot de passe doit faire au moins 6 caractères.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _reauthenticate(currentPassword);

      await currentUser!.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe mis à jour avec succès !")),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Mot de passe actuel incorrect.';
          break;
        case 'weak-password':
          message = 'Le nouveau mot de passe est trop faible.';
          break;
        default:
          message = 'Erreur : ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: "Mot de passe actuel (obligatoire)",
                      filled: true,
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: "Nouvelle adresse email",
                      filled: true,
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      "Changer l'email",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Nouveau mot de passe",
                      filled: true,
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      "Changer le mot de passe",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
