import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../history/history_page.dart';
import 'cubit/checkout_cubit.dart';
import 'cubit/checkout_state.dart';

/// The example app's home screen: a small checkout form that opens
/// `flutter_notchpay`'s built-in payment sheet.
class CheckoutPage extends StatefulWidget {
  /// Creates the checkout screen.
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '1500');
  final _phoneController = TextEditingController(text: '+237670123456');

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pay(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;
    final amount = double.parse(_amountController.text);
    context.read<CheckoutCubit>().pay(
      context,
      amount: amount,
      currency: 'XAF',
      phone: _phoneController.text,
      description: 'flutter_notchpay example purchase',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_notchpay example'),
        actions: [
          IconButton(
            tooltip: 'Payment history',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
            },
          ),
        ],
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          switch (state) {
            case CheckoutSucceeded():
              messenger.showSnackBar(
                const SnackBar(content: Text('Payment received. Thank you!')),
              );
            case CheckoutFailed(:final message):
              messenger.showSnackBar(SnackBar(content: Text(message)));
            case CheckoutCancelled():
              messenger.showSnackBar(
                const SnackBar(content: Text('Payment cancelled')),
              );
            case CheckoutIdle():
            case CheckoutInProgress():
              break;
          }
        },
        builder: (context, state) {
          final loading = state is CheckoutInProgress;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.storefront_rounded, size: 64),
                      const SizedBox(height: 12),
                      Text(
                        'Demo checkout',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (XAF)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: loading ? null : () => _pay(context),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text('Pay with NotchPay'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
