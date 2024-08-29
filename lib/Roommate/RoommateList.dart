import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:test2/Roommate/DetailedRoommate.dart';
import 'package:test2/Roommate/searchScreen.dart';
import 'package:test2/color.dart';
import 'package:test2/sharedState.dart';

class RoommateList extends StatefulWidget{
  RoommateList();

  @override
  RoommatelistState createState() => RoommatelistState();
}

class RoommatelistState extends State<RoommateList> {

  TextEditingController rentController = TextEditingController();
  TextEditingController hygieneController = TextEditingController();
  TextEditingController lifestyleController = TextEditingController();
  
  

  bool isShow = true;


  @override
  Widget build(BuildContext context) {
  final sharedState = Provider.of<SharedState>(context);
  int rent = sharedState.rent;
  String gender = sharedState.gender;
  String hygiene = sharedState.hygiene;
  String lifeStyle = sharedState.lifeStyle;

  return Scaffold(
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('profiles')
          .where('userType', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profDocs = snapshot.data!.docs;

        // Filter the profiles based on the conditions
        final filteredDocs = profDocs.where((doc) {
          final profData = doc.data() as Map<String, dynamic>;
          bool isShow = (rent == 0 || int.parse(profData['rent']) >= rent) &&
                        (profData['gender'] == gender || gender == 'any') &&
                        (profData['hygieneLevel'] == hygiene || hygiene == 'any') &&
                        (profData['selectedOption'] == lifeStyle || lifeStyle == 'any');
          bool isBanned = profData['isBanned'];
          String? userType = profData['userType'];
          return isShow && (!isBanned || userType == 'admin');
        }).toList();

        return Container(
          color: AppColors.backgroundColor,
          child: GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3,
            ),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final profData = filteredDocs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedProfileScreen(profileData: profData),
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  child: Row(
                    children:[
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: profData['profileImageUrl'] != null &&
                                profData['profileImageUrl'].isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  profData['profileImageUrl'],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : SizedBox(
                                width: 100,
                                height: 100,
                                child: Icon(
                                  Icons.person,
                                  size: 100,
                                ),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.green,
                                    size: 25,
                                  ),
                                  Text(
                                    profData['nickname'] ?? 'No name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Text(
                                    profData['age'] != null
                                        ? profData['age'].toString()
                                        : 'Unknown age',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  profData['gender'] == 'Male' ||
                                          profData['gender'] == 'male'
                                      ? Icon(
                                          Icons.male,
                                          color: Colors.blue,
                                        )
                                      : Icon(
                                          Icons.female,
                                          color: Colors.pink,
                                        ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.blue,
                                    size: 25,
                                  ),
                                  Text(
                                    ' Budget : ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(profData['rent'] + 'rm'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.cleaning_services),
                                  Text(' Hygiene : '),
                                  Text(profData['hygieneLevel']),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 21, 255, 0),
      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      onPressed: () {
        showCupertinoModalBottomSheet(
          enableDrag: true,
          expand: true,
          context: context,
          builder: (context) => SearchScreen(),
        );
      },
      child: const Icon(Icons.filter_list),
    ),
  );
}

  }
