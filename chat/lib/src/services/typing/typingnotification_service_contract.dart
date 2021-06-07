import 'package:chat/src/models/Typing_Event.dart';
import 'package:chat/src/models/User.dart';
import 'package:flutter/foundation.dart';

abstract class ITypingNotification {
  Future<bool> send({@required TypingEvent event});
  Stream<TypingEvent> subscribe(User user, List<String> userIds);
  void dispose();
}
