import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/constants/dimens.dart';

class PageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;

  const PageIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: WormEffect(
        dotHeight: Dimens.spaceXs * 2,
        dotWidth: Dimens.spaceXs * 2,
        activeDotColor: AppColors.primaryGreen,
        dotColor: AppColors.borderLight(context),
        spacing: Dimens.spaceXs,
      ),
    );
  }
}
