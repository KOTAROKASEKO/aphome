import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/BottomTab.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test2/chat/ChatMessage.dart';
import 'package:test2/chat/chatLastMessage.dart';
import 'package:test2/profile/profileModel.dart';
import 'package:test2/sharedState.dart';

late Box<ChatMessage> chatBox;
late Box<Chatlastmessage> lastMessageBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(ProfileModelAdapter());
  Hive.registerAdapter(ChatMessageAdapter());  // Register the type adapter
  Hive.registerAdapter(ChatlastmessageAdapter());
  chatBox = await Hive.openBox<ChatMessage>('chatBox');  // Open the Hive box
  lastMessageBox = await Hive.openBox<Chatlastmessage>('chatLastMessage');

  //await Hive.openBox<ChatMessage>('chatBox');  // Open the Hive box 
  //await Hive.openBox<Chatlastmessage>('chatLastMessage');
  await Hive.openBox('profilesBox');

  
   // Open the box here
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SharedState()), 
        ChangeNotifierProvider(create: (context) => SharedMessageState()), // 既存のプロバイダー
        //ChangeNotifierProvider(create: (context) => ProfileSaveProvider()),  // 新しいプロバイダー
      ],
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'stuGent',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthChecker(),
    );
  }
}


class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool isLoading = true;
  static bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      _startListeningForMessages();  // Start listening for messages
    }

    setState(() {
      _AuthCheckerState.isLoggedIn = isLoggedIn;
      isLoading = false;
    });
  }
  
void _startListeningForMessages() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    String userId = user!.uid;

    FirebaseFirestore.instance
        .collection('chats')
        .where('whoReceived', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
          
        for (var chatDoc in snapshot.docs) {
            var chatData = chatDoc.data();

            if(chatData['whoSent'] == userId) {
              // Ignore chats sent by the current user
              continue;
            }

            // Fetch last message timestamp from Hive
            Chatlastmessage? lastMessageTime = lastMessageBox.get('lastMessage_${getChatId(userId, chatData['whoSent'])}');
            DateTime? lastUpDate = lastMessageTime?.timestamp;

            // Start listening to messages collection in real-time
            chatDoc.reference.collection('messages')
              .orderBy('timestamp', descending: false)  // Order by timestamp
              .snapshots()
              .listen((messagesSnapshot) {
                for (var messageDoc in messagesSnapshot.docs) {
                    var messageData = messageDoc.data();
                    DateTime messageTime = (messageData['timestamp'] as Timestamp).toDate();

                    // Check if message is newer than the last one we processed
                    if (lastUpDate == null || messageTime.isAfter(lastUpDate!)) {
                        // Store the message in Hive
                        String lastMessage = messageData['message'];
                        String senderId = messageData['whoSent'];
                        String currentUser = messageData['whoReceived'];
                        bool isMe = (senderId == userId);

                        _storeMessageInHive(lastMessage, messageTime, senderId, currentUser, isMe);
                        print('New message stored in Hive: ${messageDoc.id}');

                        // Update lastUpDate to the latest message time
                        lastUpDate = messageTime;
                    }
                }
              });

            // Notify the app about the new message
            context.read<SharedMessageState>().setNewMessageReceived(true);
            context.read<SharedMessageState>().setFromWho(chatData['whoSent']);
        }
    });
}

  
  
bool wasReadValidation(String id) {
  List<String> keys = chatBox.keys.cast<String>().toList();
  
  print('Listing all keys in chatBox:');
  for (String key in keys) {
    print('$key');
    if (key.contains(id)) {
      return true;
    }
  }
  print('No matching messageId found');
  return false;
}



  String getChatId(String currentUser, String otherUser) {
    if (currentUser.compareTo(otherUser) < 0) {
      return '$currentUser\_$otherUser';
    } else {
      return '$otherUser\_$currentUser';
    }
  }

  void _storeMessageInHive(String text, DateTime timestamp, String whoSent, String whoReceived, bool isMe) {
    print('send message was called');
    var messageId = getChatId(whoSent, whoReceived) + timestamp.toString(); // ID to identify each message
    var id = 'lastMessage_${getChatId(whoReceived, whoSent)}';
    var chatId = getChatId(whoSent, whoReceived);
    String anotherUser = whoSent == whoReceived ? whoReceived : whoSent;

    var chatMessage = ChatMessage(
      messageText: text,
      timestamp: timestamp,
      whoSent: whoSent,
      whoReceived: whoReceived,
      isMe: isMe,
      chatId: chatId, 
      wasRead: false,
    );

    var lastMessage = Chatlastmessage(
      messageText: text,
      timestamp: timestamp,
      senderId: whoSent,
      otherUser: anotherUser,
      isMe: isMe,
      newMessageExists : true,
    );
    
    chatBox.put(messageId, chatMessage);
    lastMessageBox.put(id, lastMessage);

    print('StoremessageinHive(Method)');
    print('chatRoomId of this message: ${chatMessage.chatId}');
  }  

  @override
  Widget build(BuildContext context) {
      return BottomTab();
  }
}


class SharedMessageState extends ChangeNotifier {

  bool _newMessageReceived = false;
  String _fromWho='';

  bool get newMessageReceived => _newMessageReceived;
  String get fromWho => _fromWho;

  void setNewMessageReceived(bool received) {
    _newMessageReceived = received;
    notifyListeners();
  }
  void setFromWho(String senderId) {
    _fromWho = senderId;
    notifyListeners();
  }
}
