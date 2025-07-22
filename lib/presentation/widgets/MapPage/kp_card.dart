import 'dart:async';
import 'package:aurora_app/logger.dart';
import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class KpCard extends StatefulWidget {
  final double kpValue;
  final String location;
  final int chancePercentage;
  final DateTime updateTime;

  const KpCard({
    super.key,
    required this.kpValue,
    required this.location,
    required this.chancePercentage,
    required this.updateTime,
  });

  @override
  State<KpCard> createState() => KpCardState();
}

class KpCardState extends State<KpCard> {
  late Timer _refreshTimer;
  final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      logger.i('Refreshing KpCard time display');
      refreshNotifier.value++; // Trigger rebuild
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    refreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refreshNotifier,
      builder: (context, _, __) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: largePadding,
            vertical: smallPadding,
          ),
          padding: const EdgeInsets.all(largePadding),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(mediumPadding),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/aurora.svg',
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(width: largePadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KP Index ${widget.kpValue.toStringAsFixed(2)}',
                      style: Get.theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: extraSmallPadding),
                    Text(
                      '${widget.chancePercentage}% chance of seeing the Northern Lights in your location',
                      style: Get.theme.textTheme.bodySmall,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Updated ${_formatUpdateTime(widget.updateTime)}',
                          style: Get.theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatUpdateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')} '
          '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';
    }
  }
}
