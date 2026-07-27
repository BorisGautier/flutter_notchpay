import 'package:flutter/material.dart';

import '../../l10n/notchpay_localizations.dart';
import '../../models/notchpay_channel.dart';
import '../theme/notchpay_theme.dart';
import 'notchpay_channel_badge.dart';
import 'notchpay_primary_button.dart';

/// An email input form for Card and hosted payment channels.
class NotchPayEmailForm extends StatefulWidget {
  /// Creates an Email form.
  const NotchPayEmailForm({
    super.key,
    required this.initialKind,
    required this.loading,
    required this.onSubmit,
    this.initialEmail,
    this.errorText,
  });

  /// The channel badge to display.
  final NotchPayChannelKind initialKind;

  /// Whether a submission is in flight.
  final bool loading;

  /// Initial email value if any.
  final String? initialEmail;

  /// Called with the email once valid.
  final ValueChanged<String> onSubmit;

  /// An error message to show below the field.
  final String? errorText;

  @override
  State<NotchPayEmailForm> createState() => _NotchPayEmailFormState();
}

class _NotchPayEmailFormState extends State<NotchPayEmailForm> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      widget.onSubmit(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);
    final l10n = NotchPayLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: NotchPayChannelBadge(kind: widget.initialKind, size: 56),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emailAddress,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.mutedColor,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _controller,
            enabled: !widget.loading,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.onSurfaceColor,
            ),
            decoration: InputDecoration(
              hintText: l10n.emailHint,
              hintStyle: TextStyle(color: theme.mutedColor),
              filled: true,
              fillColor: theme.mutedColor?.withValues(alpha: 0.08),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.borderRadius * 0.5),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.borderRadius * 0.5),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              errorText: widget.errorText,
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return l10n.enterEmailAddress;
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(text)) {
                return l10n.enterValidEmailAddress;
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          NotchPayPrimaryButton(
            label: l10n.continueToPayment,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
