import 'package:equatable/equatable.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';

/// The state of the checkout flow shown on [CheckoutPage].
sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// No payment is in flight yet.
class CheckoutIdle extends CheckoutState {
  /// Creates the idle state.
  const CheckoutIdle();
}

/// The checkout sheet is open and a payment is being processed.
class CheckoutInProgress extends CheckoutState {
  /// Creates the in-progress state.
  const CheckoutInProgress();
}

/// The payment completed successfully.
class CheckoutSucceeded extends CheckoutState {
  /// Creates the success state for [payment].
  const CheckoutSucceeded(this.payment);

  /// The completed transaction.
  final NotchPayPayment payment;

  @override
  List<Object?> get props => [payment];
}

/// The customer closed the checkout sheet without paying.
class CheckoutCancelled extends CheckoutState {
  /// Creates the cancelled state.
  const CheckoutCancelled();
}

/// The payment failed, expired, or was rejected.
class CheckoutFailed extends CheckoutState {
  /// Creates the failed state with an explanatory [message].
  const CheckoutFailed(this.message);

  /// A human readable explanation of the failure.
  final String message;

  @override
  List<Object?> get props => [message];
}
