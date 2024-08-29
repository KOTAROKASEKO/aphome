import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:test2/chat/ChatMessage.dart';
import 'package:test2/chat/chatLastMessage.dart';
import 'package:test2/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:test2/main.dart';
import 'package:test2/sharedData.dart';

class ChatView extends StatefulWidget {
  final String? receiverId;
  const ChatView(this.receiverId, {super.key});

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  String? chatRoomId;
  late String currentUser;
  Box<ChatMessage>? chatBox;
  Box<Chatlastmessage>? lastMessageBox;
  String? otherUser;
  late bool validatedChatRoom;
  String? newSenderId;
  final ScrollController _scrollController = ScrollController();

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to access Provider here
   
    final sharedMessageState = Provider.of<SharedMessageState>(context);
    String? newSenderId = sharedMessageState.fromWho;
    
    print('notification here $newSenderId');
    if(newSenderId==widget.receiverId){
      context.read<SharedMessageState>().setNewMessageReceived(false);
      context.read<SharedMessageState>().setFromWho('');
    }
  }

  @override
  void initState() {
    otherUser = widget.receiverId;
    print('other user1 : $otherUser');
    super.initState();
    currentUser = SharedData.getCurrentUserId();
    _openChatBox();
    chatRoomId = getChatId(currentUser, otherUser!);
    print('chatId of this chatroom is $chatRoomId');
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openChatBox() async {
    chatBox = await Hive.openBox<ChatMessage>('chatBox');
    lastMessageBox = await Hive.openBox<Chatlastmessage>('chatLastMessage');

    setState(() {}); // Trigger rebuild to update UI after boxes are opened
  }
  void _sendMessage(String messageText) {
    String chatId = getChatId(currentUser, otherUser!);
    DateTime now = DateTime.now();

    // Format the timestamp for messageId
    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    String messageId = getChatId(currentUser, otherUser!) + formattedTimestamp;

    // Store the message under the path chats/chatId/messages/messageId
    _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set({
      'whoSent': currentUser,
      'whoReceived': otherUser,
      'message': messageText,
      'timestamp': now,
    }, SetOptions(merge: false)); // No merge, completely replaces the message if it exists

    // Update the lastMessageId at the chat level
    _firestore.collection('chats').doc(chatId).set({
      'lastMessageId': messageId,
      'whoSent': currentUser,
      'whoReceived': otherUser,
      'message': messageText,
      'timestamp': now,
    }, SetOptions(merge: true));

    // Store the message in Hive (local storage)
    _storeMessageInHive(messageText, now, currentUser, otherUser!, true, false);

    // Clear the input field after sending (assuming _messageController is defined elsewhere)
    _messageController.clear();
  } 
  
  void _storeMessageInHive(String text, DateTime timestamp, String whoSent, String whoReceived, bool isMe, bool newMessageExists) {
    print('send message was called');
    print('receiver $whoReceived');
    print('sender $whoSent');

    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
    String messageId = getChatId(currentUser, whoReceived) + formattedTimestamp;//we can identify which message by sender and timestamp cuz one sender cannot send multiple messages at same time
    String id = 'lastMessage_${getChatId(currentUser, widget.receiverId!)}';//this is necessary so that the lastmessageId will be overwritten
    String chatId = getChatId(whoSent, whoReceived);
    String? anotherUser;

    if (whoSent == currentUser && whoReceived != currentUser) {
        anotherUser = whoReceived;
    } else if (whoSent != currentUser && whoReceived == currentUser) {
        anotherUser = whoSent;
    }

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
      otherUser: anotherUser!,
      isMe: isMe,
      newMessageExists: newMessageExists,
    );

    chatBox?.put(messageId, chatMessage);
    lastMessageBox?.put(id, lastMessage); // store with `id`

    print('another user is $anotherUser');
    var check = lastMessageBox?.get(id); // retrieve with `id`
    print('other user in the box is $check');

    print('StoremessageinHive(Method)');
    print('chatRoomId of this message: ${chatMessage.chatId}');
}


  String getChatId(String currentUser, String otherUser) {
    if (currentUser.compareTo(otherUser) < 0) {
      return '${currentUser}_$otherUser';
    } else {
      return '${otherUser}_$currentUser';
    }
  }

  @override
  Widget build(BuildContext context) {
    //context.read<SharedMessageState>().setNewMessageReceived(false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColorDark,
        title: Text('Chat with ${widget.receiverId}', style: TextStyle(color: AppColors.appBarFonto)),
        iconTheme: IconThemeData(color: AppColors.appBarFonto),
      ),
      body: Column(
        children: [
          Expanded(
  child: chatBox == null
      ? Center(child: CircularProgressIndicator()) // Show loading indicator until chatBox is initialized
      : ValueListenableBuilder(
          valueListenable: chatBox!.listenable(),
          builder: (context, Box chatBox, _) {
            // Get all chat messages from the box
            final messages = chatBox.values.toList();
            
            bool chatExists = false;
            String newChatId = '';

            // Loop through all messages to check if chat exists between the users
            for (var chatMessage in messages) {
              final chatData = chatMessage as ChatMessage;
              String chatId = getChatId(chatData.whoSent!, chatData.whoReceived!);

              if (chatData.whoSent == currentUser && chatData.whoReceived == otherUser || 
                  chatData.whoReceived == currentUser && chatData.whoSent == otherUser) {

                chatExists = true;
                newChatId = chatId;
                break;

              }
            }

            // If chat doesn't exist, create a new chatId
            if (!chatExists) {
              newChatId = getChatId(currentUser, otherUser!); // Generate new chatId based on the currentUser and otherUser
              validatedChatRoom = true; // This will return true so a new chat can start
              // Optionally, add the new chat to the box or handle it elsewhere in your app logic
              print('New chat created with chatId: $newChatId');
            } else {
              validatedChatRoom = newChatId == chatRoomId; // Validate chat room if chat exists
            }

            print('validatedChatRoom: $validatedChatRoom');
            print('ChatId: $newChatId');

            // Filter messages based on the chat room
            final filteredMessages = messages.where((chatMessage) {
              final chatData = chatMessage as ChatMessage;
              String chatId = getChatId(chatData.whoSent!, chatData.whoReceived!);
              return chatId == newChatId;
            }).toList();

            // Sort messages by timestamp
            filteredMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            if (filteredMessages.isEmpty) {
              return Center(
                child: Text('No messages yet!'),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });

            List<Widget> messageWidgets = filteredMessages.map((message) {
              return _buildMessage(
                message.messageText,
                message.timestamp,
                message.whoSent,
                message.whoSent == currentUser,
              );
            }).toList();
            
            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              children: messageWidgets, // Display filtered messages
            );
          },
        ),
),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    var message = _messageController.text;
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(message);
                      message = '';
                    } else {
                      print('TextField is empty!');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, DateTime timestamp, String senderId, bool isMe) {
    //build a message means user is seeing it. so deleting the notification as the message is built
      var id = 'lastMessage_${getChatId(currentUser, widget.receiverId!)}';
    //overwrite the content -->
    //building a new message means user is seeing that. so notification will be false.
    var lastMessage = Chatlastmessage(
      messageText: text,
      timestamp: timestamp,  
      senderId: senderId,    
      otherUser: otherUser!,
      isMe: isMe,
      newMessageExists: false,
    );



    lastMessageBox?.put(id, lastMessage);
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              DateFormat('HH:mm').format(timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
