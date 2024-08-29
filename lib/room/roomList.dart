import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/room/AddRoom.dart';
import 'package:test2/room/DetailedRoom.dart';
import 'package:test2/color.dart';

class RoomGridView extends StatefulWidget {
  RoomGridView({super.key});

  @override
  _RoomGridViewState createState() => _RoomGridViewState();
}

class _RoomGridViewState extends State<RoomGridView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  TextEditingController rentController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController _propertyNameController = TextEditingController();
  
  
  bool userPosted = false;
  bool loggedIn = false;
  bool _isLoading = true;

  int rent = 99999; // Default rent value
  String location = 'any';
  String propertyName = 'any';
  

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
          .collection('RoomInformation')
          .where('userId', isEqualTo: user.uid)
          .get();
      return snapshot.docs.isNotEmpty;
    }
    return false;
  }

  void _onSearch() {
    setState(() {
      rent = rentController.text.isNotEmpty
          ? int.tryParse(rentController.text) ?? 99999
          : 99999;
      location = locationController.text.isNotEmpty
          ? locationController.text
          : 'any';
      propertyName = _propertyNameController.text.isNotEmpty
          ? _propertyNameController.text
          : 'any';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('RoomInformation').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final roomDocs = snapshot.data!.docs.where((doc) {

                final roomData = doc.data() as Map<String, dynamic>;
                final docRent = int.parse(roomData['rent']);
                final docLocation = roomData['address'];
                final condoName = roomData['condominiumName'];
                final rentMatches = docRent <= rent;
                final locationMatches = location == 'any' || docLocation == location;
                final propertyNameMatch = propertyName =='any' || condoName.contains(propertyName);

                return rentMatches && locationMatches && propertyNameMatch;
              }).toList();

              if (roomDocs.isEmpty) {
                return const Center(child: Text('No rooms found.'));
              }

              return GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,

                ),
                itemCount: roomDocs.length,
                itemBuilder: (context, index) {
                  final roomData = roomDocs[index].data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomDetailScreen(roomData: roomData),
                        ),
                      );
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 4,
                      child: Row(
                        children: [
                          Column(
                            children: [
                            Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: roomData['photoUrls'] != null && roomData['photoUrls'].isNotEmpty
                                ? Image.network(
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
                          //add profileicon here
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                          ]),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bed, color: Colors.lightGreen, size: 25,),
                                    
                                      SizedBox(width: 10,),
                                      Flexible(
                                          child: Text(
                                            roomData['condominiumName'] ?? 'No name',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Handle overflow
                                             // Limit text to 2 lines
                                          ),
                                        ),

                                    
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                                      child: roomData['ForWhatGender'] == 'Male' ||
                                              roomData['ForWhatGender'] == 'male'
                                          ? const Icon(Icons.male, color: Colors.blue)
                                          : const Icon(Icons.female, color: Colors.pink),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children:const [Icon(Icons.pin_drop, color: Colors.red),]),
                                      SizedBox(width: 10,),
                                    Flexible(
                                      child: Text(softWrap: true,
                                      '${roomData['address']}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.money_off_sharp, color: Colors.lightBlue),
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
                                    const Text('--'),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        '${roomData['introduction']}',
                                        style: const TextStyle(
                                            fontFamily: 'OpenSuns', fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
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
      floatingActionButton: _isLoading
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (loggedIn && !userPosted)
                  FloatingActionButton(
                    backgroundColor: AppColors.appBarColorDark,
                    foregroundColor: AppColors.appBarFonto,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddRoom()),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  backgroundColor: Color.fromARGB(255, 21, 255, 0),
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      enableDrag: true,
                      expand: true,
                      context: context,
                      builder: (context) => buildSearchScreen(context),
                    );
                  },
                  child: const Icon(Icons.filter_list),
                ),
              ],
            ),
    );
  }

  Widget buildSearchScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Filter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money),
                const SizedBox(width: 10),
                Container(
                  width: 80,
                  child: Text('Rent:'),
                ),
                
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter maximum rent',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 10),
                Container(
                  width: 80,
                  child: Text('location:'),
                ),
                 SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter preferred location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.edit_document),
                const SizedBox(width: 10),
                Container(
                  width: 80,
                  child: Text('property name:'),
                ),
                 SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _propertyNameController,
                    decoration: const InputDecoration(
                      hintText: '(endah regal)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 50,),
            Center(
              child: GestureDetector(
              onTap: () {
                _onSearch();
                Navigator.of(context).pop();
              },
              
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 50, 255, 84),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Check Result',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'bold',
                      ),
                    ),
                    SizedBox(width: 8), // Space between text and icon
                    Icon(Icons.search, size: 30),
                  ],
                ),
              ),
            )
,
            )
                      ],
        ),
      ),
    );
  }
}
