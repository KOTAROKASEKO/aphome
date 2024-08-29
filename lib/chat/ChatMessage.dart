import 'package:hive/hive.dart';

part 'ChatMessage.g.dart';

@HiveType(typeId: 4)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String? messageText;

  @HiveField(1)
  DateTime? timestamp;

  @HiveField(2)
  String? whoSent;

  @HiveField(3)
  bool? isMe;

  @HiveField(4)
  String? whoReceived;

  @HiveField(5)
  String? chatId;

  @HiveField(6)
  bool? wasRead;

  ChatMessage({
    required this.messageText,
    required this.timestamp,
    required this.whoSent,
    required this.isMe,
    required this.whoReceived,
    required this.chatId,
    required this.wasRead,
  });
}
