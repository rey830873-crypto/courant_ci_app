import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

class ConsumptionView extends StatefulWidget {
  const ConsumptionView({super.key});

  @override
  State<ConsumptionView> createState() => _ConsumptionViewState();
}

class _ConsumptionViewState extends State<ConsumptionView> {
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showChart = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Ma Consommation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Évolution mensuelle (KWh)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _showChart ? 1.0 : 0.0,
              child: SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil'];
                            if (value.toInt() < months.length) {
                              return Text(months[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: viewModel.consumptionData.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), _showChart ? e.value : 0);
                        }).toList(),
                        isCurved: true,
                        color: AppTheme.cieOrange,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.cieOrange.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 1000), // Animation du tracé
                  curve: Curves.easeInOutCubic,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildStatCard("Consommation ce mois", "170 KWh", Icons.flash_on, isDark),
            const SizedBox(height: 16),
            _buildStatCard("Estimation coût", "15 450 FCFA", Icons.monetization_on, isDark),
            const SizedBox(height: 16),
            _buildStatCard("Économie vs mois dernier", "-12%", Icons.trending_down, isDark, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isDark, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? AppTheme.cieOrange).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? AppTheme.cieOrange, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
