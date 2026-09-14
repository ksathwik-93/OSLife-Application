import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ActionButtonVariant { primary, secondary, outline }

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ActionButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const ActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ActionButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case ActionButtonVariant.primary:
        bg = AppColors.primaryContainer;
        fg = AppColors.onPrimaryContainer;
        break;
      case ActionButtonVariant.secondary:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurface;
        break;
      case ActionButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.onSurface;
        border = const BorderSide(color: AppColors.outlineVariant);
        break;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: variant == ActionButtonVariant.primary ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: border,
          ),
        ),
        child: content,
      ),
    );
  }
}
