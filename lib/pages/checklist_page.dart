import 'package:flutter/material.dart';
import 'package:rent_cars_app/services/local_storage_service.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  static const items = [
    ('id', 'Pièce d\'identité / CIN'),
    ('permis', 'Permis de conduire'),
    ('budget', 'Budget et apport définis'),
    ('banque', 'Accord de principe banque / financement'),
    ('ct', 'Contrôle technique à jour (si occasion)'),
    ('carte', 'Carte grise / documents du vendeur'),
    ('assurance', 'Devis assurance automobile'),
    ('essai', 'Essai routier effectué'),
    ('contrat', 'Contrat de vente lu et compris'),
    ('paiement', 'Mode de paiement sécurisé prévu'),
  ];

  Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await LocalStorageService.instance.getChecklistDone();
    if (mounted) setState(() => _done = s);
  }

  Future<void> _toggle(String id) async {
    final next = !_done.contains(id);
    await LocalStorageService.instance.setChecklistItem(id, next);
    setState(() {
      if (next) {
        _done.add(id);
      } else {
        _done.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _done.length / items.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checklist d\'achat'),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Progression : ${(_done.length)} / ${items.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.secondary,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Liste indicative pour un achat en Tunisie — adaptez selon votre situation.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...items.map((e) {
            final checked = _done.contains(e.$1);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: checked,
                onChanged: (_) => _toggle(e.$1),
                activeColor: AppColors.primary,
                title: Text(
                  e.$2,
                  style: TextStyle(
                    decoration:
                        checked ? TextDecoration.lineThrough : null,
                    color: checked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
