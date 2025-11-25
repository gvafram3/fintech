import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class LoadingSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const LoadingSkeleton({
    Key? key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.border.withOpacity(0.5),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: List.generate(
                4,
                (index) => const LoadingSkeleton(height: 150),
              ),
            ),
            const SizedBox(height: 24),
            const LoadingSkeleton(height: 20, width: 100),
            const SizedBox(height: 12),
            const LoadingSkeleton(height: 200),
            const SizedBox(height: 24),
            const LoadingSkeleton(height: 20, width: 120),
            const SizedBox(height: 12),
            const LoadingSkeleton(height: 250),
          ],
        ),
      ),
    );
  }
}
