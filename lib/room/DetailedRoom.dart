import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/chat/ChatView.dart';
import 'package:test2/color.dart';
import 'package:test2/report.dart';

// ignore: must_be_immutable
class RoomDetailScreen extends StatefulWidget {

  final Map<String, dynamic> roomData;

  RoomDetailScreen({required this.roomData});

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    initializeState();
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> initializeState() async {
    bool loggedInStatus = await isLoggedIn();
    setState(() {
      loggedIn = loggedInStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBarColorDark,
        iconTheme: IconThemeData(color: AppColors.appBarFonto),
        title: Text(
          "Room Detail",
          style: TextStyle(color: AppColors.appBarFonto),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('RoomInformation')
            .where('userId', isEqualTo: widget.roomData['userId'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No properties found.'));
          }

          var documents = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index];
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_home_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                          Flexible(
                            child: Text(
                              '  ${data['condominiumName']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                  color: AppColors.appBarColorLight),
                              softWrap: true,
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                      Text(
                        data['ForWhatGender'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.appBarColorLight),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.pin_drop,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text(
                            '  ${data['address']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.appBarColorLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.male,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text(
                            '  For ${data['ForWhatGender']}',
                            style: TextStyle(
                                fontSize: 20,
                                color: AppColors.appBarColorLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text(
                            '  Rent: ${data['rent']}',
                            style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.appBarColorLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.door_front_door_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text(
                            '  Number of Rooms: ${data['numOfRooms']}',
                            style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.appBarColorLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.info, color: AppColors.appBarColorLight),
                          Text(
                            'information',
                            style: TextStyle(color: AppColors.appBarFonto),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              data['introduction'] ?? 'Loading...',
                              softWrap: true,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'OpenSuns',
                                  color: AppColors.appBarColorLight),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '------------------------',
                            style: TextStyle(color: AppColors.appBarFonto),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Uploaded Images:',
                        style: TextStyle(color: AppColors.appBarColorLight),
                      ),
                      const SizedBox(height: 10),
                      data['photoUrls'] != null &&
                              (data['photoUrls'] as List).isNotEmpty
                          ? CarouselSlider(
                              options: CarouselOptions(
                                height: 200.0,
                                enableInfiniteScroll: false,
                                enlargeCenterPage: true,
                                viewportFraction: 0.8,
                              ),
                              items: (data['photoUrls'] as List<dynamic>)
                                  .map((url) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                      ),
                                      child: url != ''
                                          ? Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.image_not_supported),
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          : const Text('No images available'),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.report,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Text(
                                  'Report',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportScreen(data['userId']),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final User? user = _auth.currentUser;
                              if (loggedIn && data['userId']!=user?.uid) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatView(data['userId'])),
                                );
                              } else {
                                if(data['userId']==user?.uid){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Error"),
                                      content: Text("you can't text to yourself"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("ok"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                }
                                else{
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Login Required"),
                                      content: Text("ProfilePage -> Account"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("ok"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                }
                              }
                            },
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Text(
                                  'Chat',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
