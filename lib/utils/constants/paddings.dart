import 'package:flutter/material.dart';

// This should be same as Breakpoints.mediumLargeAndUp.beginWidth
const double layoutMaxWidth = 820;

const double h = 16;
const double v = 16;
const double b = 16;
const double a = 16;

const double extraSmallPadding = 4;
const double smallPadding = 8;
const double mediumPadding = 12;
const double largePadding = 16;
const double extraLargePadding = 24;
const double extraExtraLargePadding = 32;

class AppPaddings {
  static EdgeInsets symmetricHorisontal() {
    return const EdgeInsets.symmetric(horizontal: h);
  }

  static EdgeInsets symmetricVertrical() {
    return const EdgeInsets.symmetric(vertical: h);
  }

  static EdgeInsets all() {
    return const EdgeInsets.all(a);
  }

  static EdgeInsets bottom() {
    return const EdgeInsets.only(bottom: b);
  }

  static EdgeInsets page() {
    return const EdgeInsets.only(top: h, right: v, bottom: b * 2, left: v);
  }

  static EdgeInsets cardPadding() {
    return const EdgeInsets.only(
      top: smallPadding,
      right: extraLargePadding,
      bottom: smallPadding,
      left: extraLargePadding,
    );
  }

  static SizedBox separator() {
    return const SizedBox(height: h);
  }

  static SizedBox separatorHalf() {
    return const SizedBox(height: h / 2);
  }

  static SizedBox separatorQuarter() {
    return const SizedBox(height: h / 4);
  }

  static SizedBox separatorHeading() {
    return const SizedBox(height: h * 2);
  }

  static SizedBox floatingActionButton() {
    return const SizedBox(height: h * 4);
  }

  static double height() {
    return h;
  }

  static double pageBottom() {
    return h * 2;
  }

  static double character() {
    return 4;
  }
}
