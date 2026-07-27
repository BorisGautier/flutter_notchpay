import 'package:flutter/material.dart';

import '../theme/notchpay_theme.dart';

/// The main call-to-action button used across the checkout sheet.
///
/// Shows a spinner in place of [label] while [loading] is true, and
/// disables itself automatically whenever [onPressed] is null.
class NotchPayPrimaryButton extends StatelessWidget {
  /// Creates a primary button showing [label], invoking [onPressed] when
  /// tapped unless [loading] is true.
  const NotchPayPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  /// The text shown on the button when not [loading].
  final String label;

  /// Called when the button is tapped. The button is disabled when this is
  /// null or while [loading] is true.
  final VoidCallback? onPressed;

  /// Whether to show a spinner instead of [label].
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);
    final enabled = onPressed != null && !loading;

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.onPrimaryColor,
          disabledBackgroundColor: theme.primaryColor.withValues(alpha: 0.5),
          disabledForegroundColor: theme.onPrimaryColor.withValues(alpha: 0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius * 0.7),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: loading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(theme.onPrimaryColor),
                  ),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}
