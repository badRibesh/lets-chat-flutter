import 'package:chat/chat.dart';
import 'package:letschat/data/datasources/data_source_contract.dart';
import 'package:letschat/models/Chat.dart';
import 'package:letschat/models/Local_Message.dart';
import 'package:letschat/viewmodels/base_view_model.dart';

class ChatsViewModel extends BaseViewModal {
  IDatasource _datasource;
  ChatsViewModel(this._datasource) : super(_datasource);

  Future<List<Chat>> getChats() async => await _datasource.findAllChats();

  Future<void> receivedMessage(Message message) async {
    LocalMessage localMessage =
        LocalMessage(message.from, message, ReceiptStatus.deleivered);
    await addMessage(localMessage);
  }
}
