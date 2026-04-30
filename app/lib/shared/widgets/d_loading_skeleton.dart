import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/tokens.dart';

/// 로딩 스켈레톤 (shimmer 박스). 리스트/카드/그리드 형태별 사용.
class DSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const DSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = DTokens.r8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DTokens.surfaceDark2,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(
          begin: 0.4,
          end: 0.85,
          duration: 900.ms,
        );
  }
}

/// 카드 스켈레톤 — 리스트 아이템용
class DCardSkeleton extends StatelessWidget {
  final double height;
  const DCardSkeleton({super.key, this.height = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(color: DTokens.borderDark),
      ),
      padding: const EdgeInsets.all(DTokens.s16),
      child: Row(
        children: [
          DSkeleton(width: 56, height: 56, radius: DTokens.r12),
          const SizedBox(width: DTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                DSkeleton(height: 14, width: 180),
                SizedBox(height: 8),
                DSkeleton(height: 12, width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 리스트 스켈레톤 (N개 카드)
class DListSkeleton extends StatelessWidget {
  final int count;
  final EdgeInsets padding;
  const DListSkeleton({
    super.key,
    this.count = 5,
    this.padding = const EdgeInsets.all(DTokens.s16),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: count,
      separatorBuilder: (e, s) => const SizedBox(height: DTokens.s12),
      itemBuilder: (context, i) => const DCardSkeleton(),
    );
  }
}
