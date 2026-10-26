import 'package:flutter/material.dart';
import '../theme_tokens.dart';

enum SnackType { success, error, warning, info }

/// The single way the app shows transient status messages.
class SvcSnackbar {
  SvcSnackbar._();

  static void success(BuildContext context, String message) =>
      show(context, message, type: SnackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: SnackType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: SnackType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message, type: SnackType.info);

  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showOn(ScaffoldMessenger.of(context), message,
        type: type, actionLabel: actionLabel, onAction: onAction);
  }

  /// For call sites that captured the messenger before an async gap.
  static void showOn(
    ScaffoldMessengerState messenger,
    String message, {
    SnackType type = SnackType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final style = _styles[type]!;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: SvcColors.ink,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: type == SnackType.error
              ? const Duration(seconds: 5)
              : const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(style.icon, color: style.color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35),
                ),
              ),
            ],
          ),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: SvcColors.primary,
                  onPressed: onAction)
              : null,
        ),
      );
  }

  static const _styles = {
    SnackType.success:
        _SnackStyle(Icons.check_circle_rounded, Color(0xFF4ADE80)),
    SnackType.error: _SnackStyle(Icons.error_rounded, Color(0xFFF87171)),
    SnackType.warning:
        _SnackStyle(Icons.warning_amber_rounded, Color(0xFFFBBF24)),
    SnackType.info: _SnackStyle(Icons.info_rounded, Color(0xFF60A5FA)),
  };
}

class _SnackStyle {
  final IconData icon;
  final Color color;
  const _SnackStyle(this.icon, this.color);
}
