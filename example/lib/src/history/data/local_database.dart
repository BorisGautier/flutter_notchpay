import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

/// A single completed or failed payment, cached locally so the example
/// app's history screen works even offline.
///
/// This table lives only in the example app: the `flutter_notchpay`
/// package itself has no local storage of its own, since the source of
/// truth for a transaction's status is always the NotchPay API.
class PaymentRecords extends Table {
  /// The NotchPay transaction reference, e.g. `trx.RoOvUhfZXi79G7ZrAkL3JUBt`.
  TextColumn get reference => text()();

  /// The paid amount, in the currency's major unit.
  RealColumn get amount => real()();

  /// ISO 4217 currency code, e.g. `XAF`.
  TextColumn get currency => text()();

  /// The transaction's status at the time it was recorded, e.g. `complete`.
  TextColumn get status => text()();

  /// The description given to the transaction, if any.
  TextColumn get description => text().nullable()();

  /// When this record was saved on the device.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {reference};
}

/// The example app's local SQLite database, storing a read-only cache of
/// past payments for the history screen.
@DriftDatabase(tables: [PaymentRecords])
class LocalDatabase extends _$LocalDatabase {
  /// Opens (or creates) the on-disk database.
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Saves or updates the cached record for a payment.
  Future<void> recordPayment(PaymentRecordsCompanion entry) {
    return into(paymentRecords).insertOnConflictUpdate(entry);
  }

  /// Streams the payment history, most recent first.
  Stream<List<PaymentRecord>> watchHistory() {
    return (select(
      paymentRecords,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'flutter_notchpay_example');
}
