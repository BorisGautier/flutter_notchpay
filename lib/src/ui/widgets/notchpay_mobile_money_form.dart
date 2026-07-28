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
    this.countryCode,
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

  /// The active ISO country code (e.g. 'cm', 'ci', 'sn').
  final String? countryCode;

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
    final kind = NotchPayPhoneUtils.detectOperator(_controller.text);
    if (kind != _detectedKind && kind != NotchPayChannelKind.mobileMoney) {
      setState(() => _detectedKind = kind);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    var text = _controller.text.trim();
    if (!text.startsWith('+') && widget.countryCode != null) {
      final prefix = switch (widget.countryCode!.toLowerCase()) {
        'ci' => '+225',
        'ng' => '+234',
        'sn' => '+221',
        'ml' => '+223',
        'gn' => '+224',
        'ne' => '+227',
        'tg' => '+228',
        'ga' => '+241',
        'bj' => '+229',
        'bf' => '+226',
        'ug' => '+256',
        'rw' => '+250',
        'cd' => '+243',
        'tz' => '+255',
        'ke' => '+254',
        'gh' => '+233',
        'td' => '+235',
        'cf' => '+236',
        'cg' => '+242',
        'cm' => '+237',
        _ => '+237',
      };
      var digits = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.startsWith('0')) digits = digits.substring(1);
      text = '$prefix$digits';
    }
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);
    final l10n = NotchPayLocalizations.of(context);
    final dynamicHint = NotchPayPhoneUtils.getPhoneHint(
      _detectedKind,
      countryCode: widget.countryCode,
    );

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
                    LengthLimitingTextInputFormatter(16),
                  ],
                  style: TextStyle(fontSize: 17, color: theme.onSurfaceColor),
                  decoration: InputDecoration(
                    hintText: dynamicHint,
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
                    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
                    if (digits.length < 8) {
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
