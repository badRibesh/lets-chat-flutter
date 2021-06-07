import 'package:chat/src/models/Message.dart';
import 'package:chat/src/models/User.dart';
import 'package:chat/src/services/encyption/encryption_service_impl.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper/helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  MessageService sut;

  setUp(() async {
    connection = await r.connect(host: 'localhost', port: 28015);
    final encryption = EncryptionService(Encrypter(AES(Key.fromLength(32))));
    await createdDb(r, connection);
    sut = MessageService(connection, r, encryption);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user =
      User.fromJson({'id': '1234', 'active': true, 'lastseen': DateTime.now()});

  final user2 =
      User.fromJson({'id': '1111', 'active': true, 'lastseen': DateTime.now()});

  test('sent message sucessfully', () async {
    Message message = Message(
      from: user.id,
      to: '3456',
      timestamp: DateTime.now(),
      contents: 'This is a message',
    );

    final res = await sut.send(message);
    expect(res, true);
  });

  test('successfully subscribe and recived messages', () async {
    final contents = 'this is a message';
    sut.messages(activeUser: user2).listen(expectAsync1((message) {
          expect(message.to, user2.id);
          expect(message.id, isNotEmpty);
          expect(message.contents, contents);
        }, count: 2));

    Message message = Message(
        from: user.id,
        to: user2.id,
        timestamp: DateTime.now(),
        contents: contents);

    Message secondMessage = Message(
        from: user.id,
        to: user2.id,
        timestamp: DateTime.now(),
        contents: contents);

    await sut.send(message);
    await sut.send(secondMessage);
  });

  test('sucessfully subscribe and recivied new messages', () async {
    Message message = Message(
      from: user.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: 'this is a message',
    );
    Message secondMessage = Message(
      from: user.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: 'this is a another message',
    );
    await sut.send(message);

    await sut.send(secondMessage).whenComplete(
        () => sut.messages(activeUser: user2).listen(expectAsync1((message) {
              expect(message.to, user2.id);
            }, count: 2)));
  });
}
