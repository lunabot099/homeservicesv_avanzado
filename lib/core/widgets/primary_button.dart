/// primary_button.dart
/// Botón principal reutilizable de HomeServiceSV.
/// Muestra un indicador de carga cuando [isLoading] es true.
library;

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final Widget button = isOutlined
        ? OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            child: child,
          )
        : ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: backgroundColor != null
                ? ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    minimumSize: const Size.fromHeight(52),
                  )
                : null,
            child: child,
          );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}

/// Variante de botón secundario (color acento naranja).
class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AccentButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: AppColors.accent,
    );
  }
}
