import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/consumption_model.dart';

const List<String> _dayLabels = [
  '0h', '3h', '6h', '9h', '12h', '15h', '18h', '21h', //
];
const List<String> _weekLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

/// Graphique en barres de la consommation (F7), avec sélecteur de
/// période. Les libellés de l'axe horizontal s'adaptent à la période
/// (heures, jours de la semaine, ou semaines du mois).
class ConsumptionChartCard extends StatelessWidget {
  final List<ConsumptionEntry> entries;
  final ConsumptionPeriod period;
  final ValueChanged<ConsumptionPeriod> onPeriodChanged;

  const ConsumptionChartCard({
    super.key,
    required this.entries,
    required this.period,
    required this.onPeriodChanged,
  });

  String _labelFor(int index) {
    switch (period) {
      case ConsumptionPeriod.day:
        return index < _dayLabels.length ? _dayLabels[index] : '';
      case ConsumptionPeriod.week:
        return index < _weekLabels.length ? _weekLabels[index] : '';
      case ConsumptionPeriod.month:
        return 'S${index + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<double>(0, (sum, e) => sum + e.kwh);
    final maxValue = entries.isEmpty
        ? 1.0
        : entries.map((e) => e.kwh).reduce((a, b) => a > b ? a : b);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.25;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consommation',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${total.toStringAsFixed(1)} kWh • ${period.label.toLowerCase()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ConsumptionPeriod>(
            showSelectedIcon: false,
            segments: ConsumptionPeriod.values
                .map(
                  (p) => ButtonSegment(
                    value: p,
                    label: Text(p.label),
                  ),
                )
                .toList(),
            selected: {period},
            onSelectionChanged: (selection) =>
                onPeriodChanged(selection.first),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: entries.isEmpty
                ? const SizedBox.shrink()
                : BarChart(
                    BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _labelFor(index),
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(entries.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: entries[i].kwh,
                              color: AppColors.primary,
                              width: period == ConsumptionPeriod.day ? 10 : 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
