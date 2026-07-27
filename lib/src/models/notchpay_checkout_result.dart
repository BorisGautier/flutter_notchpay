import 'notchpay_payment.dart';

/// The final outcome of a checkout started with [NotchPay.checkout].
enum NotchPayCheckoutStatus {
  /// The payment completed successfully.
  success,

  /// The customer closed the checkout sheet before completing the payment.
  cancelled,

  /// The payment failed, expired, or was rejected.
  failed;

  /// Whether this status represents a successful payment.
  bool get isSuccess => this == NotchPayCheckoutStatus.success;
}

/// The result returned by [NotchPay.checkout] once the checkout sheet is
/// dismissed.
class NotchPayCheckoutResult {
  /// Creates a checkout result directly. Prefer the [NotchPayCheckoutResult.
  /// success], [NotchPayCheckoutResult.cancelled] and [NotchPayCheckoutResult.
  /// failed] constructors below.
  const NotchPayCheckoutResult({
    required this.status,
    this.payment,
    this.message,
  });

  /// The customer completed the payment successfully.
  const NotchPayCheckoutResult.success(NotchPayPayment payment)
      : this(status: NotchPayCheckoutStatus.success, payment: payment);

  /// The customer closed the checkout sheet without completing the payment.
  const NotchPayCheckoutResult.cancelled([String? message])
      : this(status: NotchPayCheckoutStatus.cancelled, message: message);

  /// The payment failed, expired, or was rejected.
  const NotchPayCheckoutResult.failed(String message,
      {NotchPayPayment? payment})
      : this(
            status: NotchPayCheckoutStatus.failed,
            message: message,
            payment: payment);

  /// The overall outcome of the checkout.
  final NotchPayCheckoutStatus status;

  /// The last known state of the transaction, when available.
  final NotchPayPayment? payment;

  /// A human readable explanation, populated for cancelled/failed results.
  final String? message;

  /// Whether [status] is [NotchPayCheckoutStatus.success].
  bool get isSuccess => status.isSuccess;

  @override
  String toString() =>
      'NotchPayCheckoutResult($status${message != null ? ', $message' : ''})';
}
