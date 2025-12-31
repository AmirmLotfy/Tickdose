import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/constants/dimens.dart';

class MonthlyAdherencePieChart extends StatelessWidget {
  final int taken;
  final int missed;
  final int skipped;

  const MonthlyAdherencePieChart({
    super.key,
    required this.taken,
    required this.missed,
    required this.skipped,
  });

  @override
  Widget build(BuildContext context) {
    final total = taken + missed + skipped;
    
    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Dimens.spaceLg),
          child: Center(
            child: Text('No data available'),
          ),
        ),
      );
    }

    return Card(
      elevation: Dimens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: Dimens.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Dimens.spaceMd),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(context),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {},
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimens.spaceMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Taken', taken, AppColors.taken, total, context),
                    const SizedBox(height: Dimens.spaceXs),
                    _buildLegendItem('Missed', missed, AppColors.missed, total, context),
                    const SizedBox(height: Dimens.spaceXs),
                    _buildLegendItem('Skipped', skipped, AppColors.skipped, total, context),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(BuildContext context) {
    final total = taken + missed + skipped;
    
    return [
      PieChartSectionData(
        value: taken.toDouble(),
        title: '${((taken / total) * 100).toStringAsFixed(0)}%',
        color: AppColors.taken,
        radius: 50,
        titleStyle: TextStyle(
          fontSize: Dimens.fontSm,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      PieChartSectionData(
        value: missed.toDouble(),
        title: '${((missed / total) * 100).toStringAsFixed(0)}%',
        color: AppColors.missed,
        radius: 50,
        titleStyle: TextStyle(
          fontSize: Dimens.fontSm,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      PieChartSectionData(
        value: skipped.toDouble(),
        title: '${((skipped / total) * 100).toStringAsFixed(0)}%',
        color: AppColors.skipped,
        radius: 50,
        titleStyle: TextStyle(
          fontSize: Dimens.fontSm,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    ];
  }

  Widget _buildLegendItem(String label, int count, Color color, int total, BuildContext context) {
    final percentage = total > 0 ? (count / total) * 100 : 0;
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: Dimens.spaceXs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: Dimens.fontXs,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: Dimens.fontXs,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
