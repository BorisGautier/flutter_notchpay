import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';

import 'src/checkout/checkout_page.dart';
import 'src/checkout/cubit/checkout_cubit.dart';
import 'src/history/cubit/history_cubit.dart';
import 'src/history/data/local_database.dart';

void main() {
  // Only the public key is ever needed on the client. Pass your own with
  // `--dart-define=NOTCHPAY_PUBLIC_KEY=pk_test_xxx` when running this
  // example; it falls back to a placeholder that will fail real requests.
  NotchPay.init(
    publicKey: const String.fromEnvironment(
      'NOTCHPAY_PUBLIC_KEY',
      defaultValue:
          'pk_test.VbnmyXvKpw4mmE4fBvIsFHfgrZ03D3HZMbxWCaRqjuQZs6anRXmlyRMrpVKeD3gK1DGaa6urjQDvMvEbxG4Isr6MQMvGjxdJBDSdBRRTVv68Yb5uNvKN310XaP17d',
    ),
  );
  runApp(const NotchPayExampleApp());
}

/// Root widget of the `flutter_notchpay` example app.
class NotchPayExampleApp extends StatelessWidget {
  /// Creates the app.
  const NotchPayExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => LocalDatabase(),
      dispose: (database) => database.close(),
      child: Builder(
        builder: (context) {
          final database = context.read<LocalDatabase>();
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => HistoryCubit(database)),
              BlocProvider(
                create: (_) => CheckoutCubit(
                  notchPay: NotchPay.instance,
                  database: database,
                ),
              ),
            ],
            child: MaterialApp(
              title: 'flutter_notchpay example',
              theme: ThemeData(
                colorSchemeSeed: const Color(0xFF5B2A86),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorSchemeSeed: const Color(0xFF5B2A86),
                brightness: Brightness.dark,
                useMaterial3: true,
              ),
              home: const CheckoutPage(),
            ),
          );
        },
      ),
    );
  }
}
