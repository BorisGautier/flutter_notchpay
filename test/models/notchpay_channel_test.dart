import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayChannelKind.fromCode', () {
    test(
        'recognizes MTN',
        () => expect(
            NotchPayChannelKind.fromCode('cm.mtn'), NotchPayChannelKind.mtn));
    test(
      'recognizes Orange',
      () => expect(NotchPayChannelKind.fromCode('cm.orange'),
          NotchPayChannelKind.orange),
    );
    test(
      'recognizes generic mobile money',
      () => expect(NotchPayChannelKind.fromCode('cm.mobile'),
          NotchPayChannelKind.mobileMoney),
    );
    test(
        'recognizes card',
        () => expect(
            NotchPayChannelKind.fromCode('card'), NotchPayChannelKind.card));
    test(
      'falls back to other for unrecognized codes',
      () => expect(NotchPayChannelKind.fromCode('xx.unknown'),
          NotchPayChannelKind.other),
    );
  });

  test('NotchPayChannel.fromJson parses code, name and lists', () {
    final channel = NotchPayChannel.fromJson({
      'code': 'cm.mtn',
      'name': 'MTN Mobile Money',
      'countries': ['CM'],
      'currencies': ['XAF'],
    });

    expect(channel.code, 'cm.mtn');
    expect(channel.name, 'MTN Mobile Money');
    expect(channel.countries, ['CM']);
    expect(channel.currencies, ['XAF']);
    expect(channel.kind, NotchPayChannelKind.mtn);
  });
}
