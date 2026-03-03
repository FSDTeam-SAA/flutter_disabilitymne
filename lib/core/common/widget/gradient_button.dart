import 'package:flutter/material.dart';
import 'package:disabilitymne/core/theme/app_colors.dart';

/// Reusable gradient button with #4D7EA9 → #89C9E6
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final double borderRadius;

  static const LinearGradient defaultGradient = AppColors.buttonGradient;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: defaultGradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
