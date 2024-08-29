import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/profile/profileModel.dart';
import 'package:test2/room/AddRoom.dart';
import 'package:test2/color.dart';
import 'package:test2/profile/editProfile.dart';
import 'package:test2/main.dart';
import 'package:carousel_slider/carousel_slider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _lifeStyleController = TextEditingController();
  final TextEditingController _hygieneController = TextEditingController();
  
  final picker = ImagePicker();

  bool isProfileEmpty = true;
  String? nickname;
  String? gender;
  String? rent;
  String? introduction;
  String? age;
  String? profileImageUrl;
  String? lifeStyle;
  String? hygieneLevel;
  bool isBanned=false;

@override
  void initState() {
  super.initState();
  _checkProfileStatus();

}

  Future<void> _checkProfileStatus() async {
  var box = await Hive.openBox('profilesBox');
  String userId = FirebaseAuth.instance.currentUser!.uid;

  // Get the ProfileModel object from the box
  ProfileModel? profile = box.get(userId) as ProfileModel?;

  if (profile != null) {
    // If profile is not null, set the state with the values from the ProfileModel object
    setState(() {
      nickname = profile.nickname;
      gender = profile.gender;
      rent = profile.rent;
      age = profile.age.toString();
      profileImageUrl = profile.photoUrls; // Assuming photoUrls is used as profileImageUrl
      lifeStyle = profile.selectedOption;
      introduction = profile.introduction;
      hygieneLevel = profile.hygieneLevel;
      isBanned = false; // Assuming isBanned is not saved in the profile object

      isProfileEmpty = false;

      // Fill in the controllers with the retrieved data
      _nicknameController.text = nickname!;
      _genderController.text = gender!;
      _rentController.text = rent!;
      _ageController.text = age!;
      _introductionController.text = introduction!;
      _lifeStyleController.text = lifeStyle!;
      _hygieneController.text = hygieneLevel!;
    });
  } else {
    // If profile is null, set the profile status to empty
    setState(() {
      isProfileEmpty = true;
    });
  }
}

  Future<void> _uploadImage(File image) async {
    
  try {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageRef = storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(image);

    String downloadURL = await storageRef.getDownloadURL();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      await FirebaseFirestore.instance.collection('profiles').doc(userId).update({
        'profileImageUrl': downloadURL,
      });

      setState(() {
        profileImageUrl = downloadURL;
      });

      print('Image uploaded successfully!');
    }
  } catch (e) {
    print('Error uploading image: $e');
  }
}

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('stuGent', style: TextStyle(color: Colors.white ,fontFamily: 'bold'),),
      backgroundColor: AppColors.appBarColorDark,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    backgroundColor: Colors.white,
    body: _buildCompleteProfilePage(),
    drawer: _buildDrawer(context),
  );
}

  Widget _buildCompleteProfilePage() {
    
  User? user = _auth.currentUser;
  
  return Container(
    color : AppColors.backgroundColor,
   child: SingleChildScrollView(//wrap it with a container and add color
    child: Column(
      children: [
        /**
         * 
         * contents
         * 
         * 
         */
        Padding(padding: EdgeInsets.fromLTRB(10, 30, 10, 0),// here changed

        child: Container(

          
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(20), 
            ),

          child: Column(
            children: [
              
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          
        // Display profile image
          GestureDetector(
            onTap: () {
                _pickImage();
            },

          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.network(
                        profileImageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 164, 164, 164),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                      ),
                    ),
                  ),
                ),
              ),
            Text(
              nickname ?? 'Loading...',
              style: const TextStyle(fontFamily:'bold', fontSize: 30, color: AppColors.profileFonto), softWrap: true,
            ),
            const SizedBox(width: 10),
            Text(
              age ?? 'Loading...',
              style: const TextStyle(fontFamily:'bold', fontSize: 20,color: AppColors.profileFonto),
              softWrap: true
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            isBanned? Text('Your account is currently disabled', style: TextStyle(fontFamily:'bold', fontSize: 20,color: Colors.red)):
            SizedBox(height: 0,),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Budget: ~', style: TextStyle(fontFamily:'bold', fontSize: 20,color: AppColors.profileFonto)),
            Text(rent ?? '', style: const TextStyle(fontFamily:'bold', fontSize: 20,color: AppColors.profileFonto)),
            const Text("rm", style: TextStyle(fontFamily:'bold', fontSize: 20,color: AppColors.profileFonto)),
          ],
        ),
        
        // Gender
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Gender: ', style: TextStyle(fontFamily:'bold' , fontSize: 20,color: AppColors.profileFonto)),
            Text(gender ?? '', style: const TextStyle(fontFamily:'bold', fontSize: 20,color: AppColors.profileFonto)),
            

          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('hygiene level: ',style: TextStyle(fontFamily:'bold' , fontSize: 20,color: AppColors.profileFonto)),
            Text(hygieneLevel ?? '', style: const TextStyle(fontFamily:'bold', fontSize: 20,color: AppColors.profileFonto)),
            

          ],
        ),

        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text(
              lifeStyle ?? '',
              style: TextStyle(fontFamily: 'bold', fontSize: 20,color: AppColors.profileFonto),
              softWrap: true,
            ),
          ],
        ),
        Text('----------'),

        // Introduction
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Flexible(
                child: Text(
                  introduction ?? 'Loading...',
                  softWrap: true,
                  style: const TextStyle(fontSize: 15, fontFamily:'OpenSuns'
                  ,color: AppColors.profileFonto),
                ),
              ),
                  ],
                ),

        Padding(padding: EdgeInsets.all(20.0),
              child: GestureDetector(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_square, color: AppColors.profileFonto, size: 40,),
                    Text('Edit', style: TextStyle(fontFamily: 'bold', color: AppColors.profileFonto),)
                    ],) ,
                  onTap: () => showCupertinoModalBottomSheet(
                  enableDrag: true,
                  expand: true,
                  context: context,
                  builder: (context) => EditProfile(),
                ),
              ),),
            ],
          ),
        ),


        ),
        

        const Row(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Padding(padding: 
            EdgeInsets.fromLTRB(0, 50, 0, 30),
            child: Text('Your Post', style: TextStyle(fontSize: 40, fontFamily: 'bold',color: AppColors.appBarFonto),),
            
            ),
        ],),

       Container(
  color: AppColors.backgroundColor,
  child: StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('RoomInformation')
        .where('userId', isEqualTo: user?.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
        return Center(child: Column(children: [
          const Text('no property found', style: TextStyle(fontFamily: 'bold', fontSize: 30, color: AppColors.appBarFonto),),
          const SizedBox(height: 20,),
          const Text("YOU WANT A ROOMMATE?", style: TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),),
          const SizedBox(height: 20,),
          Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
            child: Container(
            height: 40,
            width: 70,
            
             decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
             child: GestureDetector(
               onTap: () {
                Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => AddRoom()),
                 );
               },
               child: isBanned?
               Icon(Icons.no_adult_content,
               color: AppColors.appBarFonto,
                 size: 30,)
                 : Icon(
                 Icons.add,
                 color: AppColors.appBarFonto,
                 size: 30,
               ),
             ),
          ),
          ),
          const Text("note: You can have only 1 property", style: TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),),
          SizedBox(height: 30,),
        ],));
      }

      var documents = snapshot.data!.docs;
      return ListView.builder(
        shrinkWrap: true,
        itemCount: documents.length,
        itemBuilder: (context, index) {
          var data = documents[index];
           var documentId = data.id;
          return Card(
            color: AppColors.CardgroundColor,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['condominiumName']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.appBarFonto)),
                      const SizedBox(height: 10),
                      /**
                       * 
                       * 
                       * added new
                       */
                      Text('${data['address']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.appBarFonto)),
                      const SizedBox(height: 10),
                      /**
                       * 
                       * 
                       */
                      Text('For ${data['ForWhatGender']}', style: TextStyle(fontSize: 20, color: AppColors.appBarFonto),),
                      const SizedBox(height: 10),
                      Text('Rent:  ${data['rent']}',style: TextStyle(fontSize: 20, color: AppColors.appBarFonto),),
                      const SizedBox(height: 10),
                      Text('Number of Rooms: ${data['numOfRooms']}',style: TextStyle(fontSize: 20, color: AppColors.appBarFonto),),
                      const SizedBox(height: 10),
                      Text('note: ${data['introduction']}',style: TextStyle(fontSize: 20, color: AppColors.appBarFonto),),
                      const SizedBox(height: 10),
                      Text('Uploaded Images:', style: TextStyle(color: AppColors.appBarFonto), ),
                      const SizedBox(height: 10),
                      data['photoUrls'] != null && (data['photoUrls'] as List).isNotEmpty
                          ? CarouselSlider(
                              options: CarouselOptions(
                                height: 200.0,
                                enableInfiniteScroll: false,
                                enlargeCenterPage: true,
                                viewportFraction: 0.8,
                              ),
                              items: (data['photoUrls'] as List<dynamic>).map((url) {
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
                          : const Text('No images available',style: TextStyle(color: AppColors.appBarFonto),),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: PopupMenuButton<String>(
                      onSelected: (String result) {
                        print(result);
                            if (result == 'delete') {
                               _firestore.collection('RoomInformation')
                                .where('userId', isEqualTo: user?.uid)
                                .get()
                                .then((querySnapshot) {
                                 for (var doc in querySnapshot.docs) {
                                   doc.reference.delete();
                                 }
                               });
                            }else if(result == 'edit'){
                              Navigator.push(
                                context,
                                
                                MaterialPageRoute(builder: (context) => AddRoom(documentId: documentId)), // Pass the documentId here
                              );
                            }

                          },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              Text(' Delete property '),
                            ],
                          )
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_document),
                              Text(' Edit property'),
                            ],
                          )
                        ),
                      ],
                      child: Icon(Icons.more_vert), 
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
),
     /**
         * 
         * 
         * 
         */
      ],
    ),
  ),
  );
}

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          ListTile(

            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () async {
              await _auth.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}


