import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_cars_app/homePage.dart';
import 'package:rent_cars_app/searchPage.dart';
import 'package:rent_cars_app/chatPage.dart';
import 'package:rent_cars_app/profilePage.dart';
import 'package:rent_cars_app/login/login.dart';
import 'package:rent_cars_app/theme/app_colors.dart';
import 'package:rent_cars_app/pages/tools_hub_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _page = 0;

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    ChatPage(),
    ProfilePage(),
  ];

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondary,
        centerTitle: false,
        toolbarHeight: 60,
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset(
              'assets/logo_clear.png',
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/logo.png',
                height: 34,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.primary,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'AUTOMARKET',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2E6BE5),
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.handyman_outlined),
            color: AppColors.primary,
            tooltip: 'Outils',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ToolsHubPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
            tooltip: 'Plus',
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'notif') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aucune notification')),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'notif',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.notifications_none_rounded),
                  title: Text('Notifications'),
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Se déconnecter'),
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _page,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _page,
            onTap: (index) => setState(() => _page = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.iconInactive,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: "Accueil",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search_rounded),
                label: "Recherche",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: "Assistant",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}