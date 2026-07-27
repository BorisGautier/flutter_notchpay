import 'package:flutter/material.dart';

import '../../l10n/notchpay_localizations.dart';
import '../theme/notchpay_theme.dart';
import 'notchpay_primary_button.dart';

/// The animated "please confirm on your phone" screen shown while a Mobile
/// Money payment is being processed and this package polls NotchPay for
/// the final status.
class NotchPayProcessingView extends StatefulWidget {
  /// Creates the processing view, showing [message] as instructions.
  const NotchPayProcessingView({super.key, required this.message});

  /// Instructions shown below the animated icon, e.g. how to confirm the
  /// payment on the customer's phone.
  final String message;

  @override
  State<NotchPayProcessingView> createState() => _NotchPayProcessingViewState();
}

class _NotchPayProcessingViewState extends State<NotchPayProcessingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final delay in [0.0, 0.33, 0.66])
                    _buildRipple(theme, (_controller.value + delay) % 1.0),
                  Icon(Icons.phone_iphone_rounded,
                      color: theme.primaryColor, size: 40),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          NotchPayLocalizations.of(context).confirmOnYourPhone,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: theme.mutedColor, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildRipple(NotchPayThemeData theme, double t) {
    final size = 40 + t * 56;
    return Opacity(
      opacity: (1 - t).clamp(0, 1),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}

/// The final screen shown once a payment reaches a terminal status.
class NotchPayResultView extends StatelessWidget {
  /// Creates a result screen. Use [success] to pick the green check or red
  /// cross treatment.
  const NotchPayResultView({
    super.key,
    required this.success,
    required this.title,
    required this.message,
    required this.onDone,
    this.doneLabel = 'Done',
  });

  /// Whether the payment succeeded.
  final bool success;

  /// The headline shown below the icon.
  final String title;

  /// A short explanation shown below [title].
  final String message;

  /// The label of the closing button. Defaults to `'Done'`; pass a
  /// localized string from [NotchPayLocalizations] instead.
  final String doneLabel;

  /// Called when the customer taps the closing button.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);
    final color = success ? theme.successColor : theme.errorColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(
            success ? Icons.check_rounded : Icons.close_rounded,
            color: color,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: theme.onSurfaceColor),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: theme.mutedColor, height: 1.4),
        ),
        const SizedBox(height: 24),
        NotchPayPrimaryButton(label: doneLabel, onPressed: onDone),
      ],
    );
  }
}
