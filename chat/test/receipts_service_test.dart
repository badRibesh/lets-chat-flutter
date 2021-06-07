import 'package:chat/src/models/Receipt.dart';
import 'package:chat/src/models/User.dart';
import 'package:chat/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper/helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  ReceiptService sut;

  setUp(() async {
    connection = await r.connect();
    await createdDb(r, connection);
    sut = ReceiptService(connection, r);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user = User.fromJson({
    'id': '1234',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent receipt sucessfully', () async {
    Receipt receipt = Receipt(
        recepient: '444',
        messageId: '1234',
        status: ReceiptStatus.deleivered,
        timestamp: DateTime.now());
    final res = await sut.send(receipt);
    expect(res, true);
  });

  test('sucessfully subscribe and recivied receipts', () async {
    sut.receipts(user).listen(expectAsync1((receipt) {
          expect(receipt.recepient, user.id);
        }, count: 2));

    Receipt receipt = Receipt(
      recepient: user.id,
      messageId: '1234',
      status: ReceiptStatus.deleivered,
      timestamp: DateTime.now(),
    );
    Receipt anotherReceipt = Receipt(
      recepient: user.id,
      messageId: '1234',
      status: ReceiptStatus.read,
      timestamp: DateTime.now(),
    );

    await sut.send(receipt);
    await sut.send(anotherReceipt);
  });
}
