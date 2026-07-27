/// The lifecycle status of a NotchPay transaction.
enum NotchPayPaymentStatus {
  /// The transaction was created but no payment channel has been submitted
  /// yet.
  pending,

  /// The customer submitted a payment channel and is completing the
  /// transaction (e.g. validating a Mobile Money USSD prompt).
  processing,

  /// The transaction was paid successfully.
  complete,

  /// The transaction failed (declined, insufficient funds, ...).
  failed,

  /// The transaction was cancelled by the customer or the merchant.
  canceled,

  /// The transaction was rejected by NotchPay or the payment provider.
  rejected,

  /// The transaction expired before it was completed.
  expired,

  /// A status not yet known to this version of the package.
  unknown;

  /// Parses the API's raw status string into a [NotchPayPaymentStatus].
  static NotchPayPaymentStatus parse(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return NotchPayPaymentStatus.pending;
      case 'processing':
        return NotchPayPaymentStatus.processing;
      case 'complete':
      case 'completed':
      case 'success':
        return NotchPayPaymentStatus.complete;
      case 'failed':
        return NotchPayPaymentStatus.failed;
      case 'canceled':
      case 'cancelled':
        return NotchPayPaymentStatus.canceled;
      case 'rejected':
      case 'declined':
        return NotchPayPaymentStatus.rejected;
      case 'expired':
        return NotchPayPaymentStatus.expired;
      default:
        return NotchPayPaymentStatus.unknown;
    }
  }

  /// Whether this status represents a final, non-recoverable outcome.
  bool get isFinal => switch (this) {
        NotchPayPaymentStatus.complete ||
        NotchPayPaymentStatus.failed ||
        NotchPayPaymentStatus.canceled ||
        NotchPayPaymentStatus.rejected ||
        NotchPayPaymentStatus.expired =>
          true,
        _ => false,
      };

  /// Whether this status represents a successful payment.
  bool get isSuccess => this == NotchPayPaymentStatus.complete;
}
