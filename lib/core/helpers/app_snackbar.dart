import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppSnackbarType { info, success, error, warning }

class AppSnackbar {
  AppSnackbar._();

  static const _titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const _messageStyle = TextStyle(
    color: Color(0xFFE8EEF5),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static AppSnackbarType _typeFromTitle(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('error') ||
        normalized.contains('failed') ||
        normalized.contains('unavailable')) {
      return AppSnackbarType.error;
    }
    if (normalized.contains('success') ||
        normalized.contains('tracked') ||
        normalized.contains('added')) {
      return AppSnackbarType.success;
    }
    if (normalized.contains('warning') ||
        normalized.contains('incomplete') ||
        normalized.contains('no workout')) {
      return AppSnackbarType.warning;
    }
    if (normalized.contains('info')) {
      return AppSnackbarType.info;
    }
    return AppSnackbarType.info;
  }

  static void show(
    String title,
    String message, {
    AppSnackbarType? type,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) {
    final resolvedType = type ?? _typeFromTitle(title);
    final (backgroundColor, iconData, iconColor) = switch (resolvedType) {
      AppSnackbarType.success => (
          const Color(0xFF1F4D3A),
          Icons.check_circle_rounded,
          const Color(0xFF8DE4B6),
        ),
      AppSnackbarType.error => (
          const Color(0xFF5C1F1F),
          Icons.error_rounded,
          const Color(0xFFFF8A80),
        ),
      AppSnackbarType.warning => (
          const Color(0xFF4A3B18),
          Icons.warning_rounded,
          const Color(0xFFFFD180),
        ),
      AppSnackbarType.info => (
          const Color(0xFF243447),
          Icons.info_rounded,
          const Color(0xFF8AC5E5),
        ),
    };

    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      titleText: Text(title, style: _titleStyle),
      messageText: Text(message, style: _messageStyle),
      icon: Icon(iconData, color: iconColor, size: 28),
      margin: margin,
      borderRadius: 12,
      duration: duration,
      barBlur: 0,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static void success(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    show(
      title,
      message,
      type: AppSnackbarType.success,
      snackPosition: snackPosition,
    );
  }

  static void error(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    show(
      title,
      message,
      type: AppSnackbarType.error,
      snackPosition: snackPosition,
    );
  }

  static void info(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    show(
      title,
      message,
      type: AppSnackbarType.info,
      snackPosition: snackPosition,
    );
  }

  static void warning(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
  }) {
    show(
      title,
      message,
      type: AppSnackbarType.warning,
      snackPosition: snackPosition,
    );
  }
}
