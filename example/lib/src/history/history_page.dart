import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:intl/intl.dart';

import 'cubit/history_cubit.dart';
import 'data/local_database.dart';

/// Lists payments previously completed through the checkout flow, read
/// from the on-device [LocalDatabase] cache.
class HistoryPage extends StatelessWidget {
  /// Creates the history screen.
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment history')),
      body: BlocBuilder<HistoryCubit, List<PaymentRecord>>(
        builder: (context, records) {
          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No payments yet. Completed payments will show up here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                leading: const Icon(Icons.receipt_long_rounded),
                title: Text(
                  NotchPayCurrencyFormatter.format(
                    record.amount,
                    record.currency,
                  ),
                ),
                subtitle: Text(
                  '${record.reference}\n${DateFormat.yMMMd().add_Hm().format(record.createdAt)}',
                ),
                isThreeLine: true,
                trailing: Chip(label: Text(record.status)),
              );
            },
          );
        },
      ),
    );
  }
}
