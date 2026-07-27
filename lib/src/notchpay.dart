import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'client/notchpay_client.dart';
import 'client/notchpay_exception.dart';
import 'l10n/notchpay_localizations.dart';
import 'models/notchpay_checkout_request.dart';
import 'models/notchpay_checkout_result.dart';
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
    String baseUrl = 'https://api.notchpay.co',
    http.Client? httpClient,
  }) : this._(
          NotchPayClient(
            publicKey: publicKey,
            privateKey: privateKey,
            baseUrl: baseUrl,
            httpClient: httpClient,
          ),
        );

  NotchPay._(this._client)
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
    String baseUrl = 'https://api.notchpay.co',
    http.Client? httpClient,
  }) {
    _instance = NotchPay(
      publicKey: publicKey,
      privateKey: privateKey,
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

  /// Opens a beautiful, native checkout sheet and drives a full payment —
  /// initializing the transaction, letting the customer pick a channel
  /// (Mobile Money or Card), collecting the minimal information required,
  /// and polling NotchPay until the payment reaches a final state.
  ///
  /// [countryCode] controls which payment channels are offered (ISO
  /// 3166-1 alpha-2, defaults to `cm` for Cameroon). Customize the sheet's
  /// look with [theme], and override the built-in English/French strings
  /// with [localizations] if you need another language.
  Future<NotchPayCheckoutResult> checkout(
    BuildContext context, {
    required NotchPayCheckoutRequest request,
    String countryCode = 'cm',
    NotchPayThemeData theme = const NotchPayThemeData(),
    NotchPayLocalizations? localizations,
  }) {
    return showNotchPayCheckout(
      context,
      paymentService: payments,
      resourceService: resources,
      request: request,
      countryCode: countryCode,
      theme: theme,
      localizations: localizations,
    );
  }

  /// Releases the underlying HTTP client's resources. Call this when this
  /// instance (or your whole app) is being disposed of; you don't need to
  /// call it for the shared [instance].
  void dispose() => _client.close();
}
