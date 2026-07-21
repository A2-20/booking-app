import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppMessages {
  static void showSuccess(BuildContext context, String message) {
    _showSnippet(
      context,
      message: message,
      backgroundColor: AppTheme.successColor,
      icon: Icons.check_circle_outline_rounded,
      gradient: AppTheme.successGradient,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnippet(
      context,
      message: message,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnippet(
      context,
      message: message,
      backgroundColor: AppTheme.warningColor,
      icon: Icons.warning_amber_rounded,
      gradient: AppTheme.warningGradient,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnippet(
      context,
      message: message,
      backgroundColor: AppTheme.primaryColor,
      icon: Icons.info_outline_rounded,
    );
  }

  static void _showSnippet(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    LinearGradient? gradient,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
