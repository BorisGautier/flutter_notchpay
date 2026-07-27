import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';

import '../../history/data/local_database.dart';
import 'checkout_state.dart';

/// Drives the example app's checkout flow: opens the `flutter_notchpay`
/// checkout sheet, then records the outcome to the local history cache.
class CheckoutCubit extends Cubit<CheckoutState> {
  /// Creates the cubit.
  CheckoutCubit({required this.notchPay, required this.database})
    : super(const CheckoutIdle());

  /// The configured SDK instance used to start checkouts.
  final NotchPay notchPay;

  /// Where completed payments are cached for the history screen.
  final LocalDatabase database;

  /// Opens the checkout sheet for the given [amount]/[currency], paid by
  /// [phone], and updates state as the flow progresses.
  Future<void> pay(
    BuildContext context, {
    required double amount,
    required String currency,
    String? phone,
    String? description,
  }) async {
    emit(const CheckoutInProgress());

    final result = await notchPay.checkout(
      context,
      request: NotchPayCheckoutRequest(
        amount: amount,
        currency: currency,
        description: description,
        customer: phone != null && phone.trim().isNotEmpty
            ? NotchPayCheckoutCustomer(phone: phone)
            : null,
      ),
    );

    switch (result.status) {
      case NotchPayCheckoutStatus.success:
        final payment = result.payment!;
        await database.recordPayment(
          PaymentRecordsCompanion.insert(
            reference: payment.reference,
            amount: payment.amount,
            currency: payment.currency,
            status: payment.status.name,
            description: Value(payment.description),
          ),
        );
        emit(CheckoutSucceeded(payment));
      case NotchPayCheckoutStatus.cancelled:
        emit(const CheckoutCancelled());
      case NotchPayCheckoutStatus.failed:
        emit(CheckoutFailed(result.message ?? 'Payment failed'));
    }
  }

  /// Returns to [CheckoutIdle], e.g. after showing a result to the user.
  void reset() => emit(const CheckoutIdle());
}
