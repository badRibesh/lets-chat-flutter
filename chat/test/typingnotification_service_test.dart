import 'package:chat/src/models/Typing_Event.dart';
import 'package:chat/src/models/User.dart';
import 'package:chat/src/services/typing/typingnotification_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper/helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  TypingNotificationService sut;

  setUp(() async {
    connection = await r.connect();
    await createdDb(r, connection);
    sut = TypingNotificationService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user = User.fromJson({
    'id': '1234',
    'active': true,
    'lastseen': DateTime.now(),
  });

  final user2 =
      User.fromJson({'id': '1111', 'active': true, 'lastseen': DateTime.now()});

  test('sent typing notification sucessfully', () async {
    TypingEvent typingEvent =
        TypingEvent(from: user2.id, to: user.id, event: Typing.start);
    final res = await sut.send(event: typingEvent, to: user);
    expect(res, true);
  });

  test('sucessfully subscribe and receive typing events', () async {
    sut.subscribe(user2, [user.id]).listen(expectAsync1((event) {
      expect(event.from, user.id);
    }, count: 2));

    TypingEvent typing =
        TypingEvent(from: user2.id, to: user.id, event: Typing.start);
    TypingEvent stopTyping =
        TypingEvent(from: user2.id, to: user.id, event: Typing.stop);

    await sut.send(event: typing, to: user2);
    await sut.send(event: stopTyping, to: user2);
  });
}
