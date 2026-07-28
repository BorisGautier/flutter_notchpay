import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'client/notchpay_client.dart';
import 'client/notchpay_exception.dart';
import 'l10n/notchpay_localizations.dart';
import 'models/notchpay_checkout_request.dart';
import 'models/notchpay_checkout_result.dart';
import 'models/notchpay_environment.dart';
import 'models/notchpay_payment.dart';
import 'services/notchpay_balance_service.dart';
import 'services/notchpay_customer_service.dart';
import 'services/notchpay_identity_service.dart';
import 'services/notchpay_payment_method_service.dart';
import 'services/notchpay_payment_service.dart';
import 'services/notchpay_recipient_service.dart';
import 'services/notchpay_refund_service.dart';
import 'services/notchpay_resource_service.dart';
import 'services/notchpay_sync_service.dart';
import 'services/notchpay_transfer_service.dart';
import 'ui/notchpay_checkout_sheet.dart';
import 'ui/theme/notchpay_theme.dart';
import 'utils/notchpay_phone_utils.dart';

/// The entry point of the flutter_notchpay SDK.
///
/// ### Quick start
///
/// ```dart
/// void main() {
///   NotchPay.init(publicKey: 'pk_test_xxx');
///   runApp(const MyApp());
/// }
/// ```
///
/// Then, anywhere you have a [BuildContext]:
///
/// ```dart
/// final result = await NotchPay.instance.checkout(
///   context,
///   request: NotchPayCheckoutRequest(
///     amount: 1500,
///     currency: 'XAF',
///     description: 'Order #4831',
///     customer: NotchPayCheckoutCustomer(phone: '+237655728267'),
///   ),
/// );
///
/// if (result.isSuccess) {
///   // Payment confirmed.
/// }
/// ```
///
/// ### Security
///
/// Only ever pass [publicKey] when creating the instance your app ships
/// with. [privateKey] grants full account access (transfers, refunds,
/// balance, ...) and must **never** be embedded in a mobile app binary —
/// only supply it when using this package from trusted backend Dart code.
class NotchPay {
  /// Creates a standalone NotchPay instance.
  ///
  /// Prefer [NotchPay.init] + [NotchPay.instance] for typical app-wide use;
  /// construct an instance directly when you need multiple configurations
  /// side by side (e.g. in tests, or a multi-tenant backend).
  NotchPay({
    required String publicKey,
    String? privateKey,
    String defaultCountryCode = 'cm',
    String baseUrl = 'https://api.notchpay.co',
    http.Client? httpClient,
  }) : this._(
          NotchPayClient(
            publicKey: publicKey,
            privateKey: privateKey,
            baseUrl: baseUrl,
            httpClient: httpClient,
          ),
          defaultCountryCode: defaultCountryCode,
        );

  NotchPay._(this._client, {this.defaultCountryCode = 'cm'})
      : customers = NotchPayCustomerService(_client),
        payments = NotchPayPaymentService(_client),
        resources = NotchPayResourceService(_client),
        paymentMethods = NotchPayPaymentMethodService(_client),
        recipients = NotchPayRecipientService(_client),
        transfers = NotchPayTransferService(_client),
        refunds = NotchPayRefundService(_client),
        balance = NotchPayBalanceService(_client),
        sync = NotchPaySyncService(_client),
        identity = NotchPayIdentityService(_client);

  /// Default ISO country code used when initializing checkout sheets.
  final String defaultCountryCode;

  static NotchPay? _instance;

  /// The shared singleton instance, configured with [init].
  static NotchPay get instance {
    final instance = _instance;
    if (instance == null) {
      throw const NotchPayConfigurationException(
        'NotchPay has not been initialized. Call NotchPay.init(publicKey: '
        '"pk_...") once, near the start of your app, before using '
        'NotchPay.instance.',
      );
    }
    return instance;
  }

  /// Whether [init] has been called and [instance] is ready to use.
  static bool get isInitialized => _instance != null;

  /// Configures the shared [instance]. Safe to call again later (e.g. to
  /// switch environments); the latest call wins.
  static void init({
    required String publicKey,
    String? privateKey,
    String defaultCountryCode = 'cm',
    String baseUrl = 'https://api.notchpay.co',
    http.Client? httpClient,
  }) {
    _instance = NotchPay(
      publicKey: publicKey,
      privateKey: privateKey,
      defaultCountryCode: defaultCountryCode,
      baseUrl: baseUrl,
      httpClient: httpClient,
    );
  }

  final NotchPayClient _client;

  /// Create, list, update and block customers.
  final NotchPayCustomerService customers;

  /// Initialize, complete, fetch and list transactions. This is what
  /// powers [checkout] under the hood.
  final NotchPayPaymentService payments;

  /// Read-only reference data: channels, currencies and countries.
  final NotchPayResourceService resources;

  /// List saved payment methods.
  final NotchPayPaymentMethodService paymentMethods;

  /// Manage transfer recipients. Backend use only, see [privateKey] notes.
  final NotchPayRecipientService recipients;

  /// Send payouts. Backend use only, see [privateKey] notes.
  final NotchPayTransferService transfers;

  /// Read refunds. Backend use only, see [privateKey] notes.
  final NotchPayRefundService refunds;

  /// Read the account balance. Backend use only, see [privateKey] notes.
  final NotchPayBalanceService balance;

  /// Manage NotchPay Connect sub-accounts. Backend use only, see
  /// [privateKey] notes.
  final NotchPaySyncService sync;

  /// Look up and validate Mobile Money / bank account identities.
  final NotchPayIdentityService identity;

  /// Which environment [publicKey] belongs to, detected from the key
  /// itself (see [NotchPayEnvironment.detect]). [checkout] uses this to
  /// show a "Sandbox mode" banner so nobody mistakes a test payment for a
  /// real one, or vice versa.
  NotchPayEnvironment get environment => _client.environment;

  /// Shorthand for `environment.isSandbox`.
  bool get isSandbox => environment.isSandbox;

  /// Shorthand for `environment.isLive`.
  bool get isLive => environment.isLive;

  /// Opens a beautiful, native checkout sheet and drives a full payment —
  /// initializing the transaction, letting the customer pick a channel
  /// (Mobile Money or Card), collecting the minimal information required,
  /// and polling NotchPay until the payment reaches a final state.
  ///
  /// [countryCode] controls which payment channels are offered (ISO
  /// 3166-1 alpha-2, defaults to `cm` for Cameroon). Customize the sheet's
  /// look with [theme], and override the built-in English/French strings
  /// with [localizations] if you need another language.
  ///
  /// ### Optional callbacks
  ///
  /// [onSuccess], [onCancelled] and [onError] are called once the sheet is
  /// dismissed, as a convenience alternative to `await`-ing the returned
  /// [Future] and switching on [NotchPayCheckoutResult.status]:
  ///
  /// ```dart
  /// await NotchPay.instance.checkout(
  ///   context,
  ///   request: request,
  ///   onSuccess: (payment) => print('Paid: ${payment.reference}'),
  ///   onCancelled: () => print('Cancelled'),
  ///   onError: (error) => print('Error: $error'),
  /// );
  /// ```
  ///
  /// The [Future] is still returned and can be used alongside the callbacks —
  /// they are not mutually exclusive.
  Future<NotchPayCheckoutResult> checkout(
    BuildContext context, {
    required NotchPayCheckoutRequest request,
    String? countryCode,
    NotchPayThemeData theme = const NotchPayThemeData(),
    NotchPayLocalizations? localizations,
    void Function(NotchPayPayment payment)? onSuccess,
    void Function()? onCancelled,
    void Function(Object error)? onError,
  }) async {
    final phone = request.customer?.phone;
    final phoneCountry =
        phone != null ? NotchPayPhoneUtils.detectCountryCode(phone) : null;
    final deviceCountry =
        View.of(context).platformDispatcher.locale.countryCode;
    final resolvedCountry =
        (countryCode ?? phoneCountry ?? deviceCountry ?? defaultCountryCode)
            .toLowerCase();

    final result = await showNotchPayCheckout(
      context,
      paymentService: payments,
      resourceService: resources,
      request: request,
      countryCode: resolvedCountry,
      theme: theme,
      localizations: localizations,
      environment: environment,
    );

    switch (result.status) {
      case NotchPayCheckoutStatus.success:
        if (result.payment != null) {
          onSuccess?.call(result.payment!);
        }
      case NotchPayCheckoutStatus.cancelled:
        onCancelled?.call();
      case NotchPayCheckoutStatus.failed:
        onError?.call(result.message ?? 'Payment failed');
    }

    return result;
  }

  /// Releases the underlying HTTP client's resources. Call this when this
  /// instance (or your whole app) is being disposed of; you don't need to
  /// call it for the shared [instance].
  void dispose() => _client.close();
}
