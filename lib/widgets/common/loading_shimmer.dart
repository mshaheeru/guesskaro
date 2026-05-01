import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 8,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgElevated,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Card-sized placeholder matching session loading.
class PhraseCardShimmer extends StatelessWidget {
  const PhraseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Shimmer.fromColors(
              baseColor: AppColors.bgCard,
              highlightColor: AppColors.bgElevated,
              child: Container(color: AppColors.bgCard),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const LoadingShimmer(height: 20),
        const SizedBox(height: 10),
        const LoadingShimmer(height: 50),
      ],
    );
  }
}

class LibraryGridShimmer extends StatelessWidget {
  const LibraryGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const LoadingShimmer(height: 180, borderRadius: 14),
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LoadingShimmer(height: 120, borderRadius: 16),
        SizedBox(height: 12),
        LoadingShimmer(height: 60, borderRadius: 12),
      ],
    );
  }
}

class SessionRowShimmer extends StatelessWidget {
  const SessionRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: LoadingShimmer(height: 58, borderRadius: 12),
    );
  }
}
