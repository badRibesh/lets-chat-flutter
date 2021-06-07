import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letschat/data/datasources/data_source_contract.dart';
import 'package:letschat/models/Chat.dart';
import 'package:letschat/viewmodels/chats_view_model.dart';
import 'package:mockito/mockito.dart';

class MockDataSource extends Mock implements IDatasource {}

void main() {
  ChatsViewModel sut;
  MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    sut = ChatsViewModel(mockDataSource);
  });

  final message = Message.fromJson({
    'from': '111',
    'to': '222',
    'contents': 'hey',
    'timestamp': DateTime.parse('2021-04-01'),
    'id': '4444'
  });

  test('initial chats return empty list', () async {
    when(mockDataSource.findAllChats()).thenAnswer((_) async => []);
    expect(await sut.getChats(), isEmpty);
  });

  test('return  list of chats', () async {
    final chat = Chat('123');
    when(mockDataSource.findAllChats()).thenAnswer((_) async => [chat]);
    final chats = await sut.getChats();
    expect(chats, isNotEmpty);
  });

  test('creates a new chat when receiving message for the first time',
      () async {
    when(mockDataSource.findChat(any)).thenAnswer((_) async => null);
    await sut.receivedMessage(message);
    verify(mockDataSource.addChat(any)).called(1);
  });

  test('add new messages to existing chat', () async {
    final chat = Chat('123');
    when(mockDataSource.findChat(any)).thenAnswer((_) async => chat);
    await sut.receivedMessage(message);
    verifyNever(mockDataSource.addChat(any));
    verify(mockDataSource.addMessage(any)).called(1);
  });
}
