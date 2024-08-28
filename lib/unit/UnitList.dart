import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/color.dart';
import 'package:test2/unit/DetailUnit.dart';

// ignore: must_be_immutable
class UnitGridView extends StatefulWidget {
  UnitGridView({super.key});

  @override
  _RoomGridViewState createState() => _RoomGridViewState();
}

class _RoomGridViewState extends State<UnitGridView> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool userPosted = false;
  bool loggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeState();
    
  }

  Future<void> initializeState() async {
    
   loggedIn = await isLoggedIn();
   userPosted = await userPostedInit();
    setState(() {
      _isLoading = false;
    });
  } 

  Future<bool> isLoggedIn() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<bool> userPostedInit() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('Units')
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(

            stream: FirebaseFirestore.instance.collection('Units').snapshots(),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final roomDocs = snapshot.data!.docs;

              return GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemCount: roomDocs.length,
                itemBuilder: (context, index) {
                  final roomData = roomDocs[index].data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnitDetailScreen(roomData: roomData),
                        ),
                      );
                    },

                    child: Card(
                      color: Color.fromARGB(255, 255, 255, 255),
                      clipBehavior: Clip.antiAlias,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 4,
                      
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: roomData['photoUrls'] != null && roomData['photoUrls'].isNotEmpty
                                ? 
                                  Image.network(
                                    roomData['photoUrls'][0],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  
                                  )
                                : Container(
                                    height: 100,
                                    width: 100,
                                    color: Colors.grey[300],
                                    child: const Center(child: Text('No Image')),
                                  ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Row(
                                  children: [
                                    Icon(Icons.bed, color: Colors.lightGreen),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 2.0, 15, 0),
                                      child: Text(
                                        roomData['condominiumName'] ?? 'No name',
                                        style: const TextStyle(  
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                                      child:
                                        roomData['ForWhatGender'] == 'Male' ||  roomData['ForWhatGender'] == 'male'
                                       ? Icon(Icons.male, color: Colors.blue,) 
                                       : Icon(Icons.female, color: Colors.pink,),
                                      
                                    ),
                                    
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.pin_drop, color: Colors.red),
                                    Text(
                                      '${roomData['address']}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.money_off_sharp, color: Colors.lightBlue),
                                    Text(
                                      'monthly ${roomData['rent']}rm',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('--'),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      '${roomData['introduction']}',
                                      style: TextStyle( fontFamily: 'OpenSuns', fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      
              
    );
  }
}



/// 
/// 
/// 
/// 
/// 
/// 
