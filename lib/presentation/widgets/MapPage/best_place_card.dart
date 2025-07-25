import 'package:aurora_app/logger.dart';
import 'package:aurora_app/presentation/pages/MapPage/best_aurora_places_page.dart';
import 'package:aurora_app/utils/constants/paddings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BestPlaceCard extends StatelessWidget {
  const BestPlaceCard({
    super.key,
    this.height = 175,
    this.width = double.infinity,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const BestAuroraPlacesPage());
        logger.i('Navigated to Best Aurora Places Page');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: largePadding,
          vertical: smallPadding,
        ),
        height: height,
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(mediumPadding),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/aurora_pic.jpg', fit: BoxFit.cover),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: mediumPadding),
                color: const Color.fromARGB(94, 0, 0, 0),
                child: Text(
                  'Best places to see Aurora right now',
                  textAlign: TextAlign.center,
                  style: Get.theme.textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
