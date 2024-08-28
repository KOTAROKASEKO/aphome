import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test2/Roommate/DetailedRoommate.dart';
import 'package:test2/chat/ChatMessage.dart';
import 'package:test2/chat/ChatView.dart';
import 'package:test2/chat/chatLastMessage.dart';
import 'package:test2/color.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:test2/main.dart';

class ChatUserGridView extends StatefulWidget {
  const ChatUserGridView({super.key});

  @override
  _ChatUserGridViewState createState() => _ChatUserGridViewState();
}

class _ChatUserGridViewState extends State<ChatUserGridView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _senderId;
  Box<Chatlastmessage>? chatBox;
  Box<ChatMessage>? chatMessageBox;  // Nullable until initialized
  bool newMessageExists = false;
  String? otherUserId;
  late String senderId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    openBox();  // Initialize the Hive boxes
  }

    @override
  void didChangeDependencies() {

    super.didChangeDependencies();
    // Safe to access Provider here
    final sharedMessageState = Provider.of<SharedMessageState>(context);
    senderId = sharedMessageState.fromWho;
    print('notification here $senderId');
  }

  Future<void> openBox() async {
    // Open boxes asynchronously
    chatBox = await Hive.openBox<Chatlastmessage>('Chatlastmessage');
    chatMessageBox = await Hive.openBox<ChatMessage>('chatBox');
    setState(() {});  // Rebuild UI once the boxes are open
  }

  void _getCurrentUser() {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _senderId = user.uid;
        print('current user(_senderId) is $_senderId');
      });
    }
  }

  Future<bool> _deleteChat(String chatId) async {
    try {
      if (chatId.contains('lastMessage_')) {
        // Remove 'lastMessage_' prefix from chatId
        String newChatId = chatId.replaceAll('lastMessage_', '');
        print('lastMessage was contained');

        // Ensure chatMessageBox is open and initialized
        if (chatMessageBox != null && chatMessageBox!.isOpen) {
          // Get all keys to delete from chatMessageBox
          var keysToDelete = chatMessageBox!.keys.where((key) {
            // Assuming your keys are in the format 'senderId + timestamp'
            return key.startsWith(newChatId);
          }).toList();

          // Delete all messages for the given newChatId
          await chatMessageBox!.deleteAll(keysToDelete);

          if (chatMessageBox!.isEmpty) {
            print('Deletion succeeded, no records left.');
            return true; // Return true if the deletion was successful
          } else {
            print('Still records exist.');
            return false; // Return false if records still exist
          }

          // Optionally, delete the corresponding entry in the chatBox (for the last message)
          // await chatBox.delete(chatId);
        }
      }
    } catch (e) {
      print('Error deleting messages: $e');
      return false; // Return false if an error occurred
    }

    setState(() {});
    return false;
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot profileSnapshot =
          await _firestore.collection('profiles').doc(userId).get();
      if (profileSnapshot.exists) {
        return profileSnapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
  
  String getChatId(String senderId, String receiverId) {
    if (senderId.compareTo(receiverId) < 0) {
      return '$senderId\_$receiverId';
    } else {
      return '$receiverId\_$senderId';
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_senderId == null || chatBox == null || chatMessageBox == null) {
      // Show loading indicator until all necessary data is loaded
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 56, 56),
      appBar: AppBar(
        backgroundColor: AppColors.appBarColorDark,
        title: const Text('Chats', style: TextStyle(color: AppColors.appBarFonto)),
        iconTheme: const IconThemeData(color: AppColors.appBarFonto),
      ),
      body: ValueListenableBuilder(
        valueListenable: chatBox!.listenable(),
        builder: (context, Box<Chatlastmessage> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No chats available.'));
          }

          // Extract all last messages and sort by timestamp
          List<Chatlastmessage> lastMessages = box.values.toList().cast<Chatlastmessage>();
          lastMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          

          return ListView.builder(

            itemCount: lastMessages.length,
            itemBuilder: (context, index) {

              Chatlastmessage lastMessage = lastMessages[index];

              // Create chatId for this chat
              String chatId = 'lastMessage_${_senderId}_${lastMessage.otherUser}';
              
              otherUserId = lastMessage.otherUser;
              print('${lastMessage.otherUser}');
              print('here is otheruserId!! $otherUserId');
              print('here is currentUser $_senderId');
              print('null check!!! ${lastMessage.newMessageExists}');
              print('null check!!! ${lastMessage.isMe}');
              bool? showNotifi;
              if (lastMessage.newMessageExists==true){
                showNotifi = true;
              }else if(lastMessage.newMessageExists==false||lastMessage.newMessageExists==null){
                showNotifi = false;
              }

              return FutureBuilder<Map<String, dynamic>?>(
                future: getUserProfile(otherUserId!),
                builder: (context, AsyncSnapshot<Map<String, dynamic>?> profileSnapshot) {
                  if (profileSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center();
                  }
                  if (!profileSnapshot.hasData || profileSnapshot.data == null) {
                    return const Center(child: Text('Profile not found'));
                  }
                  Map<String, dynamic> profileData = profileSnapshot.data!;

                  return GestureDetector(
                    onTap: () {
                      print('${otherUserId}');
                      print('${_senderId}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatView(lastMessage.otherUser),
                        ),
                      );
                    },
                    onLongPress: () {
                      showCupertinoModalBottomSheet(
                        enableDrag: true,
                        expand: false,
                        context: context,
                        builder: (context) => GestureDetector(
                          child: SizedBox(
                            height: 100,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.delete,
                                    color: Colors.red, size: 25),
                                SizedBox(width: 20),
                                Text('DELETE CHAT',
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 0, 0, 0),
                                        fontSize: 20,
                                        fontFamily: 'OpenSuns',
                                        fontWeight:
                                            FontWeight.normal)),
                              ],
                            ),
                          ),
                          onTap: () {
                            _deleteChat(chatId);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildProfilePic(context, profileData),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                  Text(
                                  profileData['nickname'] ?? 'Unknown User',
                                  style: const TextStyle(
                                    color: AppColors.appBarColorLight,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(' (${profileData['userType']})',
                                style: const TextStyle(
                                    color: AppColors.appBarColorLight,
                                    fontSize: 13,
                                  ),),


                                  showNotifi! ?
                                  Container(
                                     height: 5,
                                    width: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ):
                                  Container(
                                   
                                  ),

                                  Container(
                                    child: Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                      children:[
                                        Text(DateFormat('HH:mm').format(lastMessage.timestamp as DateTime),
                                      style: TextStyle(color: AppColors.appBarFonto),),
                                      SizedBox(width: 10,)
                                      ],
                                      )
                                    ),
                                  ),

                                ],),
                                
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    lastMessage.isMe?
                                    Text('You : ', style: TextStyle(color: AppColors.appBarFonto),) : Text('${profileData['nickname']} : ',
                                    style: TextStyle(
                                      color: AppColors.appBarFonto,
                                      ),
                                      // 必要に応じて行数を制限する
                                    ),
                                  Container(
                                    
                                  child: Expanded( 
                                    child: Text(
                                  lastMessage.messageText,
                                  style: const TextStyle(
                                    color: AppColors.appBarColorLight,
                                    fontSize: 14,

                                  ),
                                  overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                ),
                               

                                )
                                )
                                ],)
                              ],
                            ),
                          ),
                          newMessageExists
                              ? Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 10,
                                  height: 10,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget buildProfilePic(BuildContext context, Map<String, dynamic> profileData) {
    return GestureDetector(
      child: profileData['profileImageUrl'] != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(profileData['profileImageUrl']),
              radius: 30,
            )
          : const Icon(Icons.person),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailedProfileScreen(profileData: profileData),
          ),
        );
      },
    );
  }
}
