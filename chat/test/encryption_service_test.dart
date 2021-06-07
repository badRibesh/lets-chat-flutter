import 'package:chat/src/services/encyption/encryption_contract.dart';
import 'package:chat/src/services/encyption/encryption_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IEncrption sut;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    sut = EncryptionService(encrypter);
  });

  test('it encrypts the plain text', () {
    final text = 'this is a message';
    final base64 = RegExp(
        r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9\/]{3}=[A-Za-z0-9+\/]{4}$)');
    final encrypted = sut.encrypt(text);
    //print(encrypted);
    expect(base64.hasMatch(encrypted), true);
  });
  test('it decrypt the encrypted text', () {
    final text = 'this is a message';
    final encrypted = sut.encrypt(text);
    final decrypted = sut.decrypt(encrypted);

    expect(decrypted, text);
  });
}
