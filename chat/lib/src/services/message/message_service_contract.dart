import 'package:chat/src/models/Message.dart';
import 'package:chat/src/models/User.dart';
import 'package:flutter/foundation.dart';

abstract class IMessageService {
  Future<bool> send(Message message);
  Stream<Message> messages({@required User activeUser});
  dispose();
}
