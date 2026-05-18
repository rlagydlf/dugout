import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

enum DButtonVariant { filled, outline, ghost }

final Set<int> _arrowIconCodePoints = {
  for (final icon in [
    Icons.arrow_forward,
    Icons.arrow_forward_rounded,
    Icons.arrow_forward_ios,
    Icons.arrow_forward_ios_rounded,
    Icons.arrow_back,
    Icons.arrow_back_rounded,
    Icons.arrow_back_ios,
    Icons.arrow_back_ios_rounded,
    Icons.arrow_back_ios_new,
    Icons.arrow_back_ios_new_rounded,
    Icons.arrow_right,
    Icons.arrow_right_rounded,
    Icons.arrow_left,
    Icons.arrow_left_rounded,
    Icons.arrow_outward,
    Icons.arrow_outward_rounded,
    Icons.chevron_right,
    Icons.chevron_right_rounded,
    Icons.chevron_left,
    Icons.chevron_left_rounded,
    Icons.navigate_next,
    Icons.navigate_next_rounded,
    Icons.navigate_before,
    Icons.navigate_before_rounded,
    Icons.keyboard_arrow_right,
    Icons.keyboard_arrow_left,
    Icons.keyboard_arrow_up,
    Icons.keyboard_arrow_down,
    Icons.east,
    Icons.west,
    Icons.trending_flat,
    Icons.trending_flat_rounded,
  ])
    icon.codePoint,
};

bool _isArrowIcon(IconData icon) => _arrowIconCodePoints.contains(icon.codePoint);

class DButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DButtonVariant variant;
  final IconData? icon;
  final bool iconTrailing;
  final bool loading;
  final bool fullWidth;

  const DButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DButtonVariant.filled,
    this.icon,
    this.iconTrailing = false,
    this.loading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final disabled = onPressed == null || loading;
    final trailing =
        iconTrailing || (icon != null && _isArrowIcon(icon!));

    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_textColor(context, team)),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && !trailing) ...[
                Icon(icon, size: 18),
                const SizedBox(width: DTokens.s8),
              ],
              Text(label),
              if (icon != null && trailing) ...[
                const SizedBox(width: DTokens.s8),
                Icon(icon, size: 18),
              ],
            ],
          );

    Widget btn;
    switch (variant) {
      case DButtonVariant.filled:
        btn = ElevatedButton(
          onPressed: disabled ? null : onPressed,
          child: child,
        );
        break;
      case DButtonVariant.outline:
        btn = OutlinedButton(
          onPressed: disabled ? null : onPressed,
          child: child,
        );
        break;
      case DButtonVariant.ghost:
        btn = TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: team.primary,
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DTokens.r12),
            ),
          ),
          child: child,
        );
        break;
    }

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  Color _textColor(BuildContext context, dynamic team) {
    return variant == DButtonVariant.filled
        ? Colors.white
        : Theme.of(context).colorScheme.primary;
  }
}
