import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPay Models Comprehensive JSON Parsing & Serialization', () {
    test('NotchPayAddress parses and converts to JSON', () {
      final json = {
        'address_line1': '123 Main St',
        'address_line2': 'Apt 4B',
        'city': 'Douala',
        'country': 'CM',
      };
      final address = NotchPayAddress.fromJson(json);

      expect(address.addressLine1, '123 Main St');
      expect(address.addressLine2, 'Apt 4B');
      expect(address.city, 'Douala');
      expect(address.country, 'CM');

      final serialized = address.toJson();
      expect(serialized['address_line1'], '123 Main St');
      expect(serialized['address_line2'], 'Apt 4B');
      expect(serialized['city'], 'Douala');
      expect(serialized['country'], 'CM');
    });

    test('NotchPayBalance parses balance payload', () {
      final json = {
        'available': 120000.0,
        'pending': 30000.0,
        'currency': 'XAF',
      };
      final balance = NotchPayBalance.fromJson(json);

      expect(balance.available, 120000.0);
      expect(balance.pending, 30000.0);
      expect(balance.currency, 'XAF');
    });

    test('NotchPayCountry parses country payload', () {
      final json = {
        'code': 'CM',
        'name': 'Cameroon',
        'currency': 'XAF',
        'dial_code': '+237',
        'flag': '🇨🇲',
      };
      final country = NotchPayCountry.fromJson(json);

      expect(country.code, 'CM');
      expect(country.name, 'Cameroon');
      expect(country.currency, 'XAF');
      expect(country.dialCode, '+237');
      expect(country.flag, '🇨🇲');
    });

    test('NotchPayCurrency parses currency payload', () {
      final json = {
        'code': 'XAF',
        'name': 'CFA Franc BCEAO',
        'symbol': 'FCFA',
      };
      final currency = NotchPayCurrency.fromJson(json);

      expect(currency.code, 'XAF');
      expect(currency.name, 'CFA Franc BCEAO');
      expect(currency.symbol, 'FCFA');
    });

    test('NotchPayIdentity parses identity payload', () {
      final json = {
        'account_number': '670123456',
        'name': 'John Doe',
        'status': 'valid',
      };
      final identity = NotchPayIdentity.fromJson(json);

      expect(identity.accountNumber, '670123456');
      expect(identity.name, 'John Doe');
      expect(identity.valid, isTrue);
    });

    test('NotchPayPaymentMethod parses payment method payload', () {
      final json = {
        'reference': 'pm_ref_123',
        'type': 'card',
        'brand': 'visa',
        'last4': '4242',
      };
      final pm = NotchPayPaymentMethod.fromJson(json);

      expect(pm.reference, 'pm_ref_123');
      expect(pm.type, 'card');
      expect(pm.brand, 'visa');
      expect(pm.last4, '4242');
    });

    test('NotchPayRecipient parses recipient payload', () {
      final json = {
        'reference': 'rec_ref_123',
        'name': 'Jane Doe',
        'country': 'CM',
        'currency': 'XAF',
        'channel': 'cm.mtn',
        'account_number': '671112233',
        'phone': '+237671112233',
      };
      final recipient = NotchPayRecipient.fromJson(json);

      expect(recipient.reference, 'rec_ref_123');
      expect(recipient.name, 'Jane Doe');
      expect(recipient.country, 'CM');
      expect(recipient.currency, 'XAF');
      expect(recipient.channel, 'cm.mtn');
      expect(recipient.accountNumber, '671112233');
      expect(recipient.phone, '+237671112233');

      final serialized = recipient.toJson();
      expect(serialized['name'], 'Jane Doe');
      expect(serialized['account_number'], '671112233');
    });

    test('NotchPayRefund parses refund payload', () {
      final json = {
        'reference': 'ref_ref_123',
        'amount': 2500.0,
        'currency': 'XAF',
        'status': 'complete',
        'reason': 'Customer request',
      };
      final refund = NotchPayRefund.fromJson(json);

      expect(refund.reference, 'ref_ref_123');
      expect(refund.amount, 2500.0);
      expect(refund.currency, 'XAF');
      expect(refund.status, NotchPayPaymentStatus.complete);
      expect(refund.reason, 'Customer request');
    });

    test('NotchPaySyncAccount parses sync account payload', () {
      final json = {
        'reference': 'sync_ref_123',
        'callback': 'https://example.com/cb',
        'permissions': ['payments', 'customers'],
      };
      final sync = NotchPaySyncAccount.fromJson(json);

      expect(sync.reference, 'sync_ref_123');
      expect(sync.callback, 'https://example.com/cb');
      expect(sync.permissions, contains('payments'));
    });

    test('NotchPayTransfer parses transfer payload', () {
      final json = {
        'reference': 'trf_ref_123',
        'amount': 5000.0,
        'currency': 'XAF',
        'status': 'complete',
        'description': 'Payout for order',
      };
      final transfer = NotchPayTransfer.fromJson(json);

      expect(transfer.reference, 'trf_ref_123');
      expect(transfer.amount, 5000.0);
      expect(transfer.currency, 'XAF');
      expect(transfer.status, NotchPayPaymentStatus.complete);
      expect(transfer.description, 'Payout for order');
    });
  });
}
