import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../client/notchpay_exception.dart';
import '../l10n/notchpay_localizations.dart';
import '../models/notchpay_channel.dart';
import '../models/notchpay_checkout_request.dart';
import '../models/notchpay_checkout_result.dart';
import '../models/notchpay_environment.dart';
import '../models/notchpay_payment.dart';
import '../models/notchpay_payment_status.dart';
import '../services/notchpay_payment_service.dart';
import '../services/notchpay_resource_service.dart';
import '../utils/notchpay_phone_utils.dart';
import '../utils/notchpay_currency_formatter.dart';
import 'theme/notchpay_theme.dart';
import 'widgets/notchpay_channel_grid.dart';
import 'widgets/notchpay_email_form.dart';
import 'widgets/notchpay_mobile_money_form.dart';
import 'widgets/notchpay_status_view.dart';

const _pollInterval = Duration(seconds: 4);
const _pollTimeout = Duration(minutes: 5);

/// Beyond this width (tablets, desktop, web) the sheet stops stretching
/// edge-to-edge and instead stays a comfortably readable card centered at
/// the bottom of the screen.
const _maxSheetWidth = 480.0;

const _mobileMoneyKinds = {
  NotchPayChannelKind.mtn,
  NotchPayChannelKind.orange,
  NotchPayChannelKind.yoomee,
  NotchPayChannelKind.moov,
  NotchPayChannelKind.wave,
  NotchPayChannelKind.airtel,
  NotchPayChannelKind.vodafone,
  NotchPayChannelKind.mpesa,
  NotchPayChannelKind.free,
  NotchPayChannelKind.eumm,
  NotchPayChannelKind.glo,
  NotchPayChannelKind.tigo,
  NotchPayChannelKind.halopesa,
  NotchPayChannelKind.equitel,
  NotchPayChannelKind.tkash,
  NotchPayChannelKind.mobileMoney,
};

/// Opens NotchPay's built-in checkout bottom sheet and drives a full
/// payment to completion, returning once the sheet is dismissed.
///
/// You normally don't call this directly — use `NotchPay.checkout` instead,
/// which supplies [paymentService] and [resourceService] for you.
Future<NotchPayCheckoutResult> showNotchPayCheckout(
  BuildContext context, {
  required NotchPayPaymentService paymentService,
  required NotchPayResourceService resourceService,
  required NotchPayCheckoutRequest request,
  String countryCode = 'cm',
  NotchPayThemeData theme = const NotchPayThemeData(),
  NotchPayLocalizations? localizations,
  NotchPayEnvironment environment = NotchPayEnvironment.live,
}) async {
  final resolvedTheme = theme.resolve(context);
  final result = await showModalBottomSheet<NotchPayCheckoutResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final sheet = NotchPayTheme(
        data: resolvedTheme,
        child: _NotchPayCheckoutSheet(
          paymentService: paymentService,
          resourceService: resourceService,
          request: request,
          countryCode: countryCode,
          environment: environment,
        ),
      );
      if (localizations == null) return sheet;
      return NotchPayLocalizationsProvider(data: localizations, child: sheet);
    },
  );
  return result ?? const NotchPayCheckoutResult.cancelled();
}

enum _Step {
  loading,
  selectChannel,
  mobileMoneyForm,
  emailForm,
  processing,
  result
}

class _NotchPayCheckoutSheet extends StatefulWidget {
  const _NotchPayCheckoutSheet({
    required this.paymentService,
    required this.resourceService,
    required this.request,
    required this.countryCode,
    required this.environment,
  });

  final NotchPayPaymentService paymentService;
  final NotchPayResourceService resourceService;
  final NotchPayCheckoutRequest request;
  final String countryCode;
  final NotchPayEnvironment environment;

  @override
  State<_NotchPayCheckoutSheet> createState() => _NotchPayCheckoutSheetState();
}

class _NotchPayCheckoutSheetState extends State<_NotchPayCheckoutSheet> {
  _Step _step = _Step.loading;
  List<NotchPayChannel> _channels = const [];
  NotchPayChannel? _selectedChannel;
  NotchPayPayment? _payment;
  String? _mobileMoneyError;
  String? _failureMessage;
  bool _submitting = false;
  Timer? _pollTimer;
  DateTime? _pollStartedAt;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final phone = widget.request.customer?.phone;
      final detectedCountry =
          phone != null ? NotchPayPhoneUtils.detectCountryCode(phone) : null;
      final country = detectedCountry ?? widget.countryCode;

      final channels = await widget.resourceService.channels(country: country);
      if (mounted) {
        setState(() {
          _channels = channels;
          _step = _Step.selectChannel;
        });
      }

      final payment = await widget.paymentService.initialize(widget.request);
      if (mounted) {
        setState(() {
          _payment = payment;
        });
      }
    } on NotchPayException catch (error) {
      if (!mounted) return;
      if (_channels.isNotEmpty) {
        // If channels were already loaded, stay on selectChannel and log failure on submission
      } else {
        setState(() {
          _failureMessage = error.message;
          _step = _Step.result;
        });
      }
    } catch (error) {
      if (!mounted) return;
      if (_channels.isEmpty) {
        setState(() {
          _failureMessage = error.toString();
          _step = _Step.result;
        });
      }
    }
  }

  void _selectChannel(NotchPayChannel channel) {
    _selectedChannel = channel;
    _mobileMoneyError = null;

    if (_mobileMoneyKinds.contains(channel.kind)) {
      setState(() {
        _step = _Step.mobileMoneyForm;
      });
      return;
    }

    final email = widget.request.customer?.email;
    if (email != null && email.trim().isNotEmpty) {
      setState(() {
        _step = _Step.loading;
      });
      unawaited(_startRedirectFlow(channel, email: email));
    } else {
      setState(() {
        _step = _Step.emailForm;
      });
    }
  }

  Future<void> _submitMobileMoney(String phone) async {
    final channel = _selectedChannel;
    if (channel == null) return;

    setState(() {
      _submitting = true;
      _mobileMoneyError = null;
    });
    try {
      var payment = _payment;
      if (payment == null) {
        final req = widget.request.customer == null
            ? NotchPayCheckoutRequest(
                amount: widget.request.amount,
                currency: widget.request.currency,
                description: widget.request.description,
                reference: widget.request.reference,
                metadata: widget.request.metadata,
                customer: NotchPayCheckoutCustomer(phone: phone),
              )
            : widget.request;
        payment = await widget.paymentService.initialize(req);
      }

      final updated = await widget.paymentService.complete(
        payment.reference,
        channel: channel.code,
        data: {'phone': phone},
      );
      if (!mounted) return;
      setState(() {
        _payment = updated;
        _submitting = false;
        _step = _Step.processing;
      });
      _startPolling();
    } on NotchPayException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _mobileMoneyError = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _mobileMoneyError = error.toString();
      });
    }
  }

  Future<void> _submitEmail(String email) async {
    final channel = _selectedChannel;
    if (channel == null) return;
    setState(() {
      _submitting = true;
      _mobileMoneyError = null;
      _step = _Step.loading;
    });
    await _startRedirectFlow(channel, email: email);
  }

  Future<void> _startRedirectFlow(NotchPayChannel channel,
      {String? email}) async {
    try {
      var current = _payment;
      if (current == null) {
        final existingCust = widget.request.customer;
        final cust = existingCust != null
            ? NotchPayCheckoutCustomer(
                email: email ?? existingCust.email,
                phone: existingCust.phone,
                name: existingCust.name,
              )
            : NotchPayCheckoutCustomer(email: email);
        final req = NotchPayCheckoutRequest(
          amount: widget.request.amount,
          currency: widget.request.currency,
          description: widget.request.description,
          reference: widget.request.reference,
          metadata: widget.request.metadata,
          customer: cust,
        );
        current = await widget.paymentService.initialize(req);
      }
      if (current.authorizationUrl == null) {
        final Map<String, dynamic> data = email != null
            ? <String, dynamic>{'email': email}
            : const <String, dynamic>{};
        current = await widget.paymentService
            .complete(current.reference, channel: channel.code, data: data);
      }
      if (!mounted) return;
      setState(() {
        _payment = current;
        _submitting = false;
      });

      final url = current.authorizationUrl;
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        }
      }
      if (!mounted) return;
      setState(() => _step = _Step.processing);
      _startPolling();
    } on NotchPayException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _failureMessage = error.message;
        _step = _Step.result;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _failureMessage = error.toString();
        _step = _Step.result;
      });
    }
  }

  void _startPolling() {
    _pollStartedAt = DateTime.now();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(_poll()));
  }

  Future<void> _poll() async {
    final payment = _payment;
    if (payment == null) return;

    final startedAt = _pollStartedAt;
    if (startedAt != null &&
        DateTime.now().difference(startedAt) > _pollTimeout) {
      _pollTimer?.cancel();
      if (!mounted) return;
      setState(() => _step = _Step.result);
      return;
    }

    try {
      final updated = await widget.paymentService.fetch(payment.reference);
      if (!mounted) return;
      setState(() => _payment = updated);
      if (updated.status.isFinal) {
        _pollTimer?.cancel();
        setState(() => _step = _Step.result);
      }
    } on NotchPayException {
      // Transient network hiccup while polling: keep trying until timeout.
    }
  }

  void _close([NotchPayCheckoutResult? result]) {
    Navigator.of(context)
        .pop(result ?? const NotchPayCheckoutResult.cancelled());
  }

  bool get _canGoBack =>
      (_step == _Step.mobileMoneyForm ||
          _step == _Step.emailForm ||
          (_step == _Step.result && _payment?.status.isSuccess != true)) &&
      !_submitting;

  void _goBack() {
    if (!_canGoBack) return;
    setState(() {
      _step = _Step.selectChannel;
      _selectedChannel = null;
      _mobileMoneyError = null;
      _failureMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = NotchPayTheme.of(context);
    final l10n = NotchPayLocalizations.of(context);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxSheetWidth),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(theme.borderRadius),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: (theme.mutedColor ?? Colors.grey)
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (widget.environment.isSandbox) ...[
                  _SandboxBanner(theme: theme, label: l10n.sandboxModeBanner),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    if (_canGoBack) ...[
                      IconButton(
                        onPressed: _goBack,
                        icon: Icon(Icons.arrow_back_rounded,
                            color: theme.onSurfaceColor),
                        tooltip:
                            MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Image.asset(
                      'assets/logo.png',
                      package: 'flutter_notchpay',
                      height: 28,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/logo.png',
                        height: 28,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        NotchPayCurrencyFormatter.format(
                          widget.request.amount,
                          widget.request.currency,
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.onSurfaceColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _close,
                      icon: Icon(Icons.close_rounded, color: theme.mutedColor),
                      tooltip: l10n.close,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      child: _buildStep(theme, l10n),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 12, color: theme.mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      'Secured by ',
                      style: TextStyle(fontSize: 11, color: theme.mutedColor),
                    ),
                    Image.asset(
                      'assets/logo.png',
                      package: 'flutter_notchpay',
                      height: 14,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/logo.png',
                        height: 14,
                        errorBuilder: (_, __, ___) => Text(
                          'NotchPay',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.mutedColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(NotchPayThemeData theme, NotchPayLocalizations l10n) {
    switch (_step) {
      case _Step.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        );
      case _Step.selectChannel:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.choosePaymentMethod,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.mutedColor,
                ),
              ),
              const SizedBox(height: 12),
              NotchPayChannelGrid(
                  channels: _channels, onSelected: _selectChannel),
            ],
          ),
        );
      case _Step.mobileMoneyForm:
        return NotchPayMobileMoneyForm(
          initialKind:
              _selectedChannel?.kind ?? NotchPayChannelKind.mobileMoney,
          loading: _submitting,
          countryCode: widget.countryCode,
          errorText: _mobileMoneyError,
          onSubmit: _submitMobileMoney,
        );
      case _Step.emailForm:
        return NotchPayEmailForm(
          initialKind: _selectedChannel?.kind ?? NotchPayChannelKind.card,
          loading: _submitting,
          initialEmail: widget.request.customer?.email,
          errorText: _mobileMoneyError,
          onSubmit: _submitEmail,
        );
      case _Step.processing:
        final message = switch (_selectedChannel?.kind) {
          NotchPayChannelKind.mtn => l10n.mtnInstructions,
          NotchPayChannelKind.orange => l10n.orangeInstructions,
          NotchPayChannelKind.yoomee => l10n.yoomeeInstructions,
          _ => _mobileMoneyKinds.contains(_selectedChannel?.kind)
              ? l10n.mobileMoneyInstructions
              : l10n.redirectInstructions,
        };
        return NotchPayProcessingView(message: message);
      case _Step.result:
        return _buildResult(l10n);
    }
  }

  Widget _buildResult(NotchPayLocalizations l10n) {
    final payment = _payment;
    final failureMessage = _failureMessage;

    if (failureMessage != null || payment == null || !payment.status.isFinal) {
      final message = failureMessage ?? l10n.genericErrorMessage;
      return NotchPayResultView(
        success: false,
        title: l10n.paymentFailedTitle,
        message: message,
        doneLabel: l10n.done,
        onDone: () =>
            _close(NotchPayCheckoutResult.failed(message, payment: payment)),
      );
    }

    if (payment.status.isSuccess) {
      return NotchPayResultView(
        success: true,
        title: l10n.paymentSuccessTitle,
        message: l10n.paymentSuccessMessage,
        doneLabel: l10n.done,
        onDone: () => _close(NotchPayCheckoutResult.success(payment)),
      );
    }

    final (title, statusMessage) = switch (payment.status) {
      NotchPayPaymentStatus.canceled => (
          l10n.paymentCancelledTitle,
          l10n.paymentCancelledMessage,
        ),
      NotchPayPaymentStatus.expired => (
          l10n.paymentExpiredTitle,
          l10n.paymentExpiredMessage,
        ),
      _ => (
          l10n.paymentFailedTitle,
          l10n.genericErrorMessage,
        ),
    };
    final message = failureMessage ?? payment.message ?? statusMessage;
    return NotchPayResultView(
      success: false,
      title: title,
      message: message,
      doneLabel: l10n.done,
      onDone: () =>
          _close(NotchPayCheckoutResult.failed(message, payment: payment)),
    );
  }
}

/// A small amber banner warning that the current key is a sandbox/test
/// key, so nobody mistakes a test payment for a real one (or vice versa).
class _SandboxBanner extends StatelessWidget {
  const _SandboxBanner({required this.theme, required this.label});

  final NotchPayThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFB45309);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(theme.borderRadius * 0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.science_outlined, size: 16, color: amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
