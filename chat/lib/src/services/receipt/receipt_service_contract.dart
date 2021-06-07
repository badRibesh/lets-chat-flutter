import 'package:chat/src/models/Receipt.dart';
import 'package:chat/src/models/User.dart';

abstract class IReceiptService {
  Future<bool> send(Receipt receipt);
  Stream<Receipt> receipts(User user);
  void dispose();
}
