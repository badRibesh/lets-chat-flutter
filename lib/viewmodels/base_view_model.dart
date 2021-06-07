import 'package:flutter/foundation.dart';
import 'package:letschat/data/datasources/data_source_contract.dart';
import 'package:letschat/models/Chat.dart';
import 'package:letschat/models/Local_Message.dart';

abstract class BaseViewModal {
  IDatasource _datasource;

  BaseViewModal(this._datasource);

  @protected
  Future<void> addMessage(LocalMessage message) async {
    if (!await _isExistingChat(message.chatId))
      await _createNewChat(message.chatId);
    await _datasource.addMessage(message);
  }

  Future<bool> _isExistingChat(String chatId) async {
    return await _datasource.findChat(chatId) != null;
  }

  Future<void> _createNewChat(String chatId) async {
    final chat = Chat(chatId);
    await _datasource.addChat(chat);
  }
}
