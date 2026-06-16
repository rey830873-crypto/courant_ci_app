import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/meter_reading_model.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/meter_viewmodel.dart';

/// Écran "Compteur" (F2) : configuration du numéro de compteur prépayé,
/// saisie de relevés de solde et historique. C'est cette série de
/// relevés qui alimente le suivi de consommation (F7) sur le Dashboard.
class MeterScreen extends StatefulWidget {
  const MeterScreen({super.key});

  @override
  State<MeterScreen> createState() => _MeterScreenState();
}

class _MeterScreenState extends State<MeterScreen> {
  late final TextEditingController _meterNumberController;
  final _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<MeterViewModel>();
    _meterNumberController = TextEditingController(text: vm.meterNumber ?? '');
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveMeterNumber() async {
    final number = _meterNumberController.text.trim();
    if (number.isEmpty) return;
    await context.read<MeterViewModel>().setMeterNumber(number);
  }

  Future<void> _editMeterNumber() async {
    final vm = context.read<MeterViewModel>();
    final controller = TextEditingController(text: vm.meterNumber ?? '');

    final result = await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le numéro de compteur'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Numéro de compteur'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result != null && result.isNotEmpty) {
      await vm.setMeterNumber(result);
    }
  }

  Future<void> _submitReading() async {
    final raw = _balanceController.text.trim().replaceAll(',', '.');
    final balance = double.tryParse(raw);
    final messenger = ScaffoldMessenger.of(context);

    if (balance == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Entre un solde valide en kWh.')),
      );
      return;
    }

    final vm = context.read<MeterViewModel>();
    await vm.addReading(balance);
    if (!mounted) return;

    if (vm.status == ReadingSubmissionStatus.success) {
      _balanceController.clear();
      messenger.showSnackBar(const SnackBar(content: Text('Relevé enregistré !')));
      // Le Dashboard (consommation F7, aperçu compteur) dépend de ces
      // relevés : on le rafraîchit pour qu'il reflète immédiatement le
      // nouveau relevé.
      await context.read<DashboardViewModel>().refresh();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Une erreur est survenue.')),
      );
    }
    vm.resetStatus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeterViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final hasMeterNumber = vm.meterNumber != null && vm.meterNumber!.isNotEmpty;
    final isSubmitting = vm.status == ReadingSubmissionStatus.submitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon compteur')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!hasMeterNumber) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configure ton compteur', style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Ce numéro identifie ton compteur prépayé CIE.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _meterNumberController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Numéro de compteur'),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Enregistrer',
                      onPressed: _saveMeterNumber,
                    ),
                  ],
                ),
              ),
            ] else ...[
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Compteur prépayé', style: textTheme.bodySmall),
                          Text('N° ${vm.meterNumber}', style: textTheme.titleMedium),
                        ],
                      ),
                    ),
                    TextButton(onPressed: _editMeterNumber, child: const Text('Modifier')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Nouveau relevé', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Saisis le solde affiché sur ton compteur pour suivre ta '
                'consommation.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _balanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Solde actuel',
                        suffixText: 'kWh',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    label: 'Ajouter',
                    expand: false,
                    isLoading: isSubmitting,
                    onPressed: _submitReading,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Historique des relevés', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              if (vm.isLoadingHistory)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (vm.history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Aucun relevé enregistré pour le moment.',
                    style: textTheme.bodyMedium,
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (var i = 0; i < vm.history.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _ReadingTile(reading: vm.history[i]),
                      ],
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final MeterReadingModel reading;

  const _ReadingTile({required this.reading});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy à HH:mm').format(reading.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.primaryDark, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(date, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '${reading.kwhBalance.toStringAsFixed(1)} kWh',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
