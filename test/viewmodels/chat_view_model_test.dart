import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letschat/data/datasources/data_source_contract.dart';
import 'package:letschat/models/Chat.dart';
import 'package:letschat/models/Local_Message.dart';
import 'package:letschat/viewmodels/chat_view_model.dart';
import 'package:mockito/mockito.dart';

class MockDataSource extends Mock implements IDatasource {}

void main() {
  ChatViewModel sut;
  MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    sut = ChatViewModel(mockDataSource);
  });

  final message = Message.fromJson({
    'from': '111',
    'to': '222',
    'contents': 'hey',
    'timestamp': DateTime.parse('2021-04-01'),
    'id': '4444'
  });

  test('initial messages return empty list', () async {
    when(mockDataSource.findMessages(any)).thenAnswer((_) async => []);
    expect(await sut.getMessages('123'), isEmpty);
  });

  test('returns list of message from local storage', () async {
    final chat = Chat('123');
    final localMessage =
        LocalMessage(chat.id, message, ReceiptStatus.deleivered);
    when(mockDataSource.findMessages(chat.id))
        .thenAnswer((_) async => [localMessage]);
    final messages = await sut.getMessages('123');
    expect(messages, isNotEmpty);
    expect(messages.first.chatId, '123');
  });

  test('creates a new chat when sending first message', () async {
    when(mockDataSource.findChat(any)).thenAnswer((_) async => null);
    await sut.sentMessages(message);
    verify(mockDataSource.addChat(any)).called(1);
  });

  test('add new sent message to the chat', () async {
    final chat = Chat('123');
    final localMessage = LocalMessage(chat.id, message, ReceiptStatus.sent);
    when(mockDataSource.findMessages(chat.id))
        .thenAnswer((_) async => [localMessage]);
    await sut.getMessages(chat.id);
    await sut.sentMessages(message);

    verifyNever(mockDataSource.addChat(any));
    verify(mockDataSource.addMessage(any)).called(1);
  });

  test('add new received message to the chat', () async {
    final chat = Chat('111');
    final localMessage =
        LocalMessage(chat.id, message, ReceiptStatus.deleivered);
    when(mockDataSource.findMessages(chat.id))
        .thenAnswer((_) async => [localMessage]);
    when(mockDataSource.findChat(chat.id)).thenAnswer((_) async => chat);

    await sut.getMessages(chat.id);
    await sut.receivedMessage(message);

    verifyNever(mockDataSource.addChat(any));
    verify(mockDataSource.addMessage(any)).called(1);
  });

  test('created new chat when message received is not apart of this chat',
      () async {
    final chat = Chat('123');
    final localMessage =
        LocalMessage(chat.id, message, ReceiptStatus.deleivered);
    when(mockDataSource.findMessages(chat.id))
        .thenAnswer((_) async => [localMessage]);
    when(mockDataSource.findChat(chat.id)).thenAnswer((_) async => null);

    await sut.getMessages(chat.id);
    await sut.receivedMessage(message);

    verify(mockDataSource.addChat(any)).called(1);
    verify(mockDataSource.addMessage(any)).called(1);
    expect(sut.otherMessages, 1);
  });
}
