import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local_database.dart';

/// Streams the locally cached payment history for the history screen.
class HistoryCubit extends Cubit<List<PaymentRecord>> {
  /// Creates the cubit and starts listening to [database] right away.
  HistoryCubit(this.database) : super(const []) {
    _subscription = database.watchHistory().listen(emit);
  }

  /// The database this cubit reads from.
  final LocalDatabase database;

  late final StreamSubscription<List<PaymentRecord>> _subscription;

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
