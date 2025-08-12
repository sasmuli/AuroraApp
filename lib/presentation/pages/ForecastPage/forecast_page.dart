import 'dart:math';

import 'package:aurora_app/config/theme/aurora_theme.dart';
import 'package:aurora_app/domain/models/kp_index_entry.dart';
import 'package:aurora_app/presentation/controllers/forecastPage/forecast_controller.dart';
import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ForecastPage extends GetView<ForecastController> {
  const ForecastPage({super.key});

  // Logger instance for debugging
  static final logger = Logger();

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
                // 3-day forecast chart - only showing future time periods
                if (controller.kpShortTermForecast.value != null) ...[
                  Text('KP Index - Forecast', style: Get.textTheme.titleLarge),
                  const SizedBox(height: mediumPadding),
                  _buildForecastChart(),
                  const SizedBox(height: largePadding),
                ],
                // 27-day forecast chart
                if (controller.kpLongTermForecast.value != null) ...[
                  Text(
                    '27-Day KP Index Outlook',
                    style: Get.textTheme.titleLarge,
                  ),
                  const SizedBox(height: mediumPadding),
                  _buildLongTermForecastChart(),
                  const SizedBox(height: largePadding),
                ],
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

    return _buildBarChart(entries: entries, maxY: 9.0);
  }

  Widget _buildLongTermForecastChart() {
    final longTermData = controller.kpLongTermForecast.value;
    if (longTermData == null || longTermData.entries.isEmpty) {
      return const Center(child: Text('No long-term forecast data available'));
    }

    // Convert UTC timestamps to local time for display
    final localTimeEntries = longTermData.entries
        .map(
          (entry) => KpIndexEntry(
            timestamp: entry.timestamp.toLocal(),
            kpValue: entry.kpValue,
          ),
        )
        .toList();

    logger.d(
      'Displaying ${localTimeEntries.length} long-term KP index forecasts',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0, left: 8.0),
          child: Text(
            'Scroll horizontally to view all forecast data',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: max(
                MediaQuery.of(Get.context!).size.width,
                localTimeEntries.length * 50,
              ),
              child: _buildBarChart(
                entries: localTimeEntries,
                maxY: 9.0,
                isLongTerm: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _formatLongTermDateWidget(DateTime timestamp) {
    return Text(
      '${_getMonthAbbreviation(timestamp.month)} ${timestamp.day}',
      style: Get.theme.textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildForecastChart() {
    final forecastData = controller.kpShortTermForecast.value;
    if (forecastData == null || forecastData.entries.isEmpty) {
      return const Center(child: Text('No forecast data available'));
    }

    // Get the current time to filter only future forecasts
    final now = DateTime.now().toUtc();
    logger.d(
      'Current UTC time for forecast filtering: ${now.toIso8601String()}',
    );

    // Filter to only show future time periods
    final futureEntries = forecastData.entries.where((entry) {
      return entry.timestamp.isAfter(now);
    }).toList();

    if (futureEntries.isEmpty) {
      return const Center(child: Text('No upcoming forecast data available'));
    }

    // Convert UTC timestamps to local time for display
    final localTimeFutureEntries = futureEntries
        .map(
          (entry) => KpIndexEntry(
            timestamp: entry.timestamp.toLocal(),
            kpValue: entry.kpValue,
          ),
        )
        .toList();

    logger.d(
      'Displaying ${localTimeFutureEntries.length} future KP index forecasts in local time',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0, left: 8.0),
          child: Text(
            'Scroll horizontally to view all forecast data',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: max(
                MediaQuery.of(Get.context!).size.width,
                localTimeFutureEntries.length * 50,
              ),
              child: _buildBarChart(
                entries: localTimeFutureEntries,
                maxY: 9.0,
                isLongTerm: false,
              ),
            ),
          ),
        ),
      ],
    );
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
    bool isLongTerm = false,
  }) {
    // We'll control the scrolling externally with SingleChildScrollView
    // Set a fixed width for each bar to ensure consistent spacing
    final barWidth = 45.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: 9.0, // Always show up to 9
        minY: 0,

        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false, // we’re not using tap/hover
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (context) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 2,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final v = entries[group.x.toInt()].kpValue;
              return BarTooltipItem(
                v.toStringAsFixed(2), // e.g. 3.33
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),

        // Fixed interval values for Y axis labels
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  if (isLongTerm) {
                    return _formatLongTermDateWidget(entries[index].timestamp);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: smallPadding),
                      child: _formatChartTimestampWidget(
                        entries[index].timestamp,
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2, // Force interval of 2
              getTitlesWidget: (value, meta) {
                // Only show values: 0, 2, 4, 6, 8
                if (value % 2 == 0 && value <= (isLongTerm ? 8 : 8)) {
                  // Use consistent comma format for both chart types
                  final formattedValue = '${value.toInt()},00';

                  return Padding(
                    padding: const EdgeInsets.only(right: extraSmallPadding),
                    child: Text(
                      formattedValue,
                      style: Get.theme.textTheme.bodyLarge,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2,
          checkToShowHorizontalLine: (value) =>
              value == 0 ||
              value == 2 ||
              value == 4 ||
              value == 6 ||
              value == 8,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.3), strokeWidth: 1),
        ),
        barGroups: entries.asMap().entries.map((e) {
          final i = e.key;
          final kp = e.value.kpValue;
          return BarChartGroupData(
            x: i,
            showingTooltipIndicators: const [0],
            barRods: [
              BarChartRodData(
                toY: kp,
                width: barWidth,
                color: _getBarColor(kp),
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
