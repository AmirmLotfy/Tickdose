import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/constants/dimens.dart';

class AdherenceChart extends StatelessWidget {
  final Map<int, double> weeklyData; // Day of week (1-7) -> adherence %
  final String title;

  const AdherenceChart({
    super.key,
    required this.weeklyData,
    this.title = 'Weekly Adherence',
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppColors.textSecondary(context);
    final borderLight = AppColors.borderLight(context);

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
            Text(
              title,
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: Dimens.spaceMd),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // Modern fl_chart uses tooltipBgColor instead of getTooltipColor
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(0)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          if (value.toInt() >= 1 && value.toInt() <= 7) {
                            return Text(
                              days[value.toInt() - 1],
                              style: TextStyle(
                                fontSize: Dimens.fontXs,
                                color: textSecondary,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: Dimens.fontXs,
                              color: textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: borderLight,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(7, (index) {
      final day = index + 1;
      final adherence = weeklyData[day] ?? 0;
      
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: adherence,
            color: _getColorForAdherence(adherence),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Color _getColorForAdherence(double adherence) {
    if (adherence >= 90) return AppColors.successGreen;
    if (adherence >= 70) return AppColors.warningOrange;
    return AppColors.errorRed;
  }
}
