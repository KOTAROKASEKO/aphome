import 'package:hive/hive.dart';
part 'chatLastMessage.g.dart';

@HiveType(typeId: 5)
class Chatlastmessage extends HiveObject {
  @HiveField(0)
  late String messageText;

  @HiveField(1)
  late DateTime timestamp;

  @HiveField(2)
  late String senderId;

  @HiveField(3)
  late bool isMe;

  @HiveField(4)
  late String otherUser;

  @HiveField(5)
  late bool? newMessageExists;
  

  Chatlastmessage({
    required this.messageText,
    required this.timestamp,
    required this.senderId,
    required this.isMe,
    required this.otherUser,
    required this.newMessageExists,
  });
}
