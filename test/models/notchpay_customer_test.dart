import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayCustomer', () {
    test('parses a full API payload', () {
      final customer = NotchPayCustomer.fromJson({
        'reference': 'cus.xxLZjWte8fdc8YNY',
        'name': 'Chapdel KAMGA',
        'email': 'd512@schapdel5.me',
        'phone': '+237655728267',
        'description': 'My first customer',
        'locked': false,
        'address': {
          'country': 'cm',
          'city': 'Douala',
          'address_line1': 'Montee des soeurs',
        },
        'created_at': '2024-01-01T10:00:00.000Z',
      });

      expect(customer.reference, 'cus.xxLZjWte8fdc8YNY');
      expect(customer.name, 'Chapdel KAMGA');
      expect(customer.email, 'd512@schapdel5.me');
      expect(customer.address?.city, 'Douala');
      expect(customer.locked, isFalse);
      expect(customer.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
    });

    test('falls back to id when reference is missing', () {
      final customer =
          NotchPayCustomer.fromJson({'id': 'cus.legacy', 'name': 'Ada'});
      expect(customer.reference, 'cus.legacy');
    });

    test('serializes back to a request payload', () {
      const customer =
          NotchPayCustomer(name: 'Ada Lovelace', email: 'ada@example.com');
      expect(customer.toJson(),
          {'name': 'Ada Lovelace', 'email': 'ada@example.com'});
    });
  });
}
