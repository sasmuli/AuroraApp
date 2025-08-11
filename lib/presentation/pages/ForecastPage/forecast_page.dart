import 'package:aurora_app/config/theme/aurora_theme.dart';
import 'package:aurora_app/domain/models/kp_index_entry.dart';
import 'package:aurora_app/presentation/controllers/forecastPage/forecast_controller.dart';
import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForecastPage extends GetView<ForecastController> {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: AuroraTheme.auroraRed),
                ),
                const SizedBox(height: largePadding),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // History chart
                if (controller.kpHistoryData.value != null) ...[
                  Text(
                    'KP Index - Last 24 Hours',
                    style: Get.theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: largePadding),
                  SizedBox(height: 200, child: _buildHistoryChart()),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHistoryChart() {
    final historyData = controller.kpHistoryData.value;
    if (historyData == null || historyData.entries.isEmpty) {
      return const Center(child: Text('No history data available'));
    }

    final entries = historyData.entries;

    return _buildBarChart(entries: entries, maxY: 9.0, title: '');
  }

  Widget _formatChartTimestampWidget(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOfTimestamp = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (dateOfTimestamp.isAtSameMomentAs(today)) {
      return Text('${timestamp.hour}:00', style: Get.theme.textTheme.bodySmall);
    } else {
      return SizedBox(
        height: 22.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${timestamp.month}/${timestamp.day}',
              style: Get.theme.textTheme.bodySmall,
            ),
            Text('${timestamp.hour}:00', style: Get.theme.textTheme.bodySmall),
          ],
        ),
      );
    }
  }

  Widget _buildBarChart({
    required List<KpIndexEntry> entries,
    required double maxY,
    required String title,
  }) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(enabled: true, handleBuiltInTouches: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: smallPadding),
                    child: _formatChartTimestampWidget(
                      entries[index].timestamp,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: extraSmallPadding),
                    child: Text(
                      '${value.toInt()},00',
                      style: Get.theme.textTheme.bodyLarge,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
            axisNameWidget: title.isNotEmpty ? Text(title) : null,
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.3), strokeWidth: 1),
        ),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final kpEntry = entry.value;
          final barColor = _getBarColor(kpEntry.kpValue);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: kpEntry.kpValue,
                color: barColor,
                width: 20,
                borderRadius: BorderRadius.zero,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getBarColor(double kpValue) {
    if (kpValue >= 4) {
      return AuroraTheme.auroraRed;
    } else if (kpValue >= 3) {
      return AuroraTheme.auroraOrange;
    } else {
      return AuroraTheme.auroraGreen;
    }
  }
}
