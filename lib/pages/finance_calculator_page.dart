import 'package:flutter/material.dart';
import 'package:rent_cars_app/theme/app_colors.dart';

class FinanceCalculatorPage extends StatefulWidget {
  final double? initialPrice;

  const FinanceCalculatorPage({super.key, this.initialPrice});

  @override
  State<FinanceCalculatorPage> createState() => _FinanceCalculatorPageState();
}

class _FinanceCalculatorPageState extends State<FinanceCalculatorPage> {
  late final TextEditingController _priceCtrl;
  final _downCtrl = TextEditingController(text: '0');
  double _years = 5;
  double _rate = 9; // % annuel approximatif

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.initialPrice != null
          ? widget.initialPrice!.toStringAsFixed(0)
          : '50000',
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _downCtrl.dispose();
    super.dispose();
  }

  double get _price => double.tryParse(_priceCtrl.text.replaceAll(' ', '')) ?? 0;
  double get _down => double.tryParse(_downCtrl.text.replaceAll(' ', '')) ?? 0;
  double get _loan => (_price - _down).clamp(0, double.infinity);
  int get _months => (_years * 12).round();

  double get _monthly {
    if (_loan <= 0 || _months <= 0) return 0;
    final r = _rate / 100 / 12;
    if (r == 0) return _loan / _months;
    return _loan * r * (1 + r)._pow(_months) / ((1 + r)._pow(_months) - 1);
  }

  double get _total => _monthly * _months + _down;
  double get _interest => _total - _price;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calculateur de financement'),
        backgroundColor: AppColors.secondary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Estimez vos mensualités',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulation indicative — les conditions réelles dépendent de la banque.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          const Text(
            'Prix du véhicule (DT)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Ex: 50000',
              prefixIcon: Icon(Icons.directions_car_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          const Text(
            'Apport (DT)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _downCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Ex: 10000',
              prefixIcon: Icon(Icons.savings_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text('Durée : ${_years.toInt()} an(s)',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _years,
            min: 1,
            max: 7,
            divisions: 6,
            activeColor: AppColors.primary,
            label: '${_years.toInt()} ans',
            onChanged: (v) => setState(() => _years = v),
          ),
          Text('Taux annuel : ${_rate.toStringAsFixed(1)} %',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _rate,
            min: 5,
            max: 15,
            divisions: 20,
            activeColor: AppColors.primary,
            label: '${_rate.toStringAsFixed(1)} %',
            onChanged: (v) => setState(() => _rate = v),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.primary.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Mensualité estimée',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    '${_monthly.toStringAsFixed(0)} DT / mois',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 28),
                  _row('Montant emprunté', '${_loan.toStringAsFixed(0)} DT'),
                  _row('Coût total', '${_total.toStringAsFixed(0)} DT'),
                  _row('Intérêts estimés', '${_interest.toStringAsFixed(0)} DT'),
                  _row('Nombre d\'échéances', '$_months'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

extension on double {
  double _pow(int n) {
    double r = 1;
    for (var i = 0; i < n; i++) {
      r *= this;
    }
    return r;
  }
}