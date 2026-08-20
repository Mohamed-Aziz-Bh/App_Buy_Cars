import 'package:flutter/material.dart';
import 'package:rent_cars_app/pages/car_quiz_page.dart';
import 'package:rent_cars_app/pages/checklist_page.dart';
import 'package:rent_cars_app/pages/compare_page.dart';
import 'package:rent_cars_app/pages/finance_calculator_page.dart';
import 'package:rent_cars_app/pages/recently_viewed_page.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class ToolsHubPage extends StatelessWidget {
  const ToolsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      (
        Icons.calculate_outlined,
        'Calculateur de financement',
        'Estimez vos mensualités',
        () => const FinanceCalculatorPage(),
      ),
      (
        Icons.quiz_outlined,
        'Quelle voiture pour moi ?',
        'Quiz personnalisé',
        () => const CarQuizPage(),
      ),
      (
        Icons.compare_arrows_rounded,
        'Comparateur',
        'Jusqu\'à 3 véhicules',
        () => const ComparePage(),
      ),
      (
        Icons.checklist_rtl_rounded,
        'Checklist d\'achat',
        'Documents & étapes',
        () => const ChecklistPage(),
      ),
      (
        Icons.history_rounded,
        'Récemment consultées',
        'Votre historique local',
        () => const RecentlyViewedPage(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Outils'),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = tools[i];
          return Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Icon(t.$1, color: AppColors.primary),
              ),
              title: Text(t.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(t.$3),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => t.$4()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
