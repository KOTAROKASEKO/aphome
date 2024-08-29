import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:test2/chat/chatLastMessage.dart';

import 'ChatMessage.dart';

//this class will be called when the app stores messages, both when the app received and sent.
class MessageStorageService {
  Box? chatBox;
  Box? lastMessageBox;

  MessageStorageService();//この箱たちいらない

  Future<void> storeMessageInHive({
    required String text,
    required DateTime timestamp,
    required String whoSent,
    required String whoReceived,
    required bool isMe,
    required bool newMessageExists,
  }) async {

    chatBox = await Hive.openBox<ChatMessage>('chatBox');
    lastMessageBox = await Hive.openBox<Chatlastmessage>('chatLastMessage');

    print('send message was called');
    print('receiver $whoReceived');
    print('sender $whoSent');

    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
    String messageId = getChatId(whoSent, whoReceived) + formattedTimestamp; 
    String id = 'lastMessage_${getChatId(whoSent, whoReceived)}'; 
    String chatId = getChatId(whoSent, whoReceived);
    String anotherUser = (whoSent == whoReceived) ? whoSent : whoReceived;

    var chatMessage = ChatMessage(
      messageText: text,
      timestamp: timestamp,
      whoSent: whoSent,
      whoReceived: whoReceived,
      isMe: isMe,
      chatId: chatId,
      wasRead: true,
    );

    var lastMessage = Chatlastmessage(
      messageText: text,
      timestamp: timestamp,
      senderId: whoSent,
      otherUser: anotherUser,
      isMe: isMe,
      newMessageExists: newMessageExists,
    );

    chatBox!.put(messageId, chatMessage);
    lastMessageBox!.put(id, lastMessage);
    
     

    print('another user is $anotherUser');
    var check = lastMessageBox!.get(id); 
    print('other user in the box is $check');

    print('StoremessageinHive(Method)');
    print('chatRoomId of this message: ${chatMessage.chatId}');
  }

  String getChatId(String userA, String userB) {
    if (userA.compareTo(userB) < 0) {
      return '${userA}_$userB';
    } else {
      return '${userB}_$userA';
    }
  }
}
