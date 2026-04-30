import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

enum DButtonVariant { filled, outline, ghost }

class DButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const DButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final disabled = onPressed == null || loading;

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
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: DTokens.s8),
              ],
              Text(label),
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
