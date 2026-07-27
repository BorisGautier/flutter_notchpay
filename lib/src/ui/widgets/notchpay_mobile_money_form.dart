import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/notchpay_localizations.dart';
import '../../models/notchpay_channel.dart';
import '../../utils/notchpay_phone_utils.dart';
import '../theme/notchpay_theme.dart';
import 'notchpay_channel_badge.dart';
import 'notchpay_primary_button.dart';

/// A phone number form for Mobile Money channels.
///
/// As the customer types, the operator badge automatically switches
/// between MTN and Orange based on the number's prefix, giving instant
/// visual confirmation that they picked the right channel.
class NotchPayMobileMoneyForm extends StatefulWidget {
  /// Creates a Mobile Money form pre-selecting [initialKind]'s badge.
  const NotchPayMobileMoneyForm({
    super.key,
    required this.initialKind,
    required this.loading,
    required this.onSubmit,
    this.errorText,
  });

  /// The operator badge to show before the customer has typed a number.
  final NotchPayChannelKind initialKind;

  /// Whether a submission is in flight; disables the form and shows a
  /// spinner on the submit button.
  final bool loading;

  /// Called with the normalized phone number once the form is valid and
  /// submitted.
  final ValueChanged<String> onSubmit;

  /// An error message to show below the phone field, e.g. from a failed
  /// submission.
  final String? errorText;

  @override
  State<NotchPayMobileMoneyForm> createState() =>
      _NotchPayMobileMoneyFormState();
}

class _NotchPayMobileMoneyFormState extends State<NotchPayMobileMoneyForm> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  NotchPayChannelKind _detectedKind = NotchPayChannelKind.mobileMoney;

  @override
  void initState() {
    super.initState();
    _detectedKind = widget.initialKind;
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final kind = NotchPayPhoneUtils.detectCameroonOperator(_controller.text);
    if (kind != _detectedKind) setState(() => _detectedKind = kind);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(NotchPayPhoneUtils.normalize(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);
    final l10n = NotchPayLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mobileMoneyNumber,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.mutedColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              NotchPayChannelBadge(kind: _detectedKind, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  style: TextStyle(fontSize: 17, color: theme.onSurfaceColor),
                  decoration: InputDecoration(
                    hintText: l10n.phoneHint,
                    errorText: widget.errorText,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(theme.borderRadius * 0.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterPhoneNumber;
                    }
                    if (!NotchPayPhoneUtils.isValidCameroonMobile(value)) {
                      return l10n.enterValidPhoneNumber;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          NotchPayPrimaryButton(
            label: l10n.payNow,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
