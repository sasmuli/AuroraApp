import 'dart:async';
import 'package:aurora_app/domain/models/kp_index_entry.dart';
import 'package:aurora_app/domain/repositories/forecast_repository.dart';
import 'package:aurora_app/logger.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ForecastController extends GetxController {
  final ForecastRepository _forecastRepository;

  final Rx<KpHistoryData?> kpHistoryData = Rx<KpHistoryData?>(null);
  final Rx<KpShortTermForecastData?> kpShortTermForecast =
      Rx<KpShortTermForecastData?>(null);
  final Rx<KpLongTermForecastData?> kpLongTermForecast =
      Rx<KpLongTermForecastData?>(null);

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  Timer? _refreshTimer;

  ForecastController(this._forecastRepository);

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      logger.d('Auto-refreshing KP Index data');
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final allData = await _forecastRepository.getAllKpData();

      kpHistoryData.value = allData.history;

      logger.d('KP Index data loaded successfully');
    } catch (e) {
      logger.e('Error loading KP Index data: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load KP Index data';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _loadAllData();
    _startAutoRefresh();
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final local = dateTime.toLocal();

    if (local.day == today.day) {
      return DateFormat('h:00a').format(local);
    } else if (local.day == tomorrow.day) {
      return DateFormat('EEE d').format(local);
    } else {
      return DateFormat('EEE d').format(local);
    }
  }
}
