import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test2/profile/ProfileSave.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  ProfileSaveProvider prf = ProfileSaveProvider();

  String? nickname;
  String? _gender;
  String? rent;
  String? introduction;
  String? age;
  String? profileImageUrl;
  String? _lifeStyle;
  String? _hygieneLevel;
  //added
  bool? isBanned;
  bool? userPosted;//will disable the user to post twice
  
  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot doc = await _firestore.collection('profiles').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {

          nickname = data['nickname'];
          _gender = data['gender'];
          rent = data['rent'];
          introduction = data['introduction'];
          _hygieneLevel = data['hygieneLevel'];
          age = data['age'].toString();
          profileImageUrl = data['profileImageUrl'];
          _lifeStyle = data['selectedOption'];
          _hygieneLevel = data['hygieneLevel']; 
          profileImageUrl = data['profileImageUrl'];
          userPosted = data['userPosted'];
          isBanned = data['isBanned'];
          

          _nicknameController.text = nickname ?? '';
          _genderController.text = _gender ?? '';
          _rentController.text = rent ?? '';
          _ageController.text = age ?? '';
          _noteController.text = introduction ?? '';
          
        });
      }
    }
  }

  Future<void> saveProfile() async {

    String nickname = _nicknameController.text;
    String rent = _rentController.text;
    int age = int.tryParse(_ageController.text) ?? 0;
    String note = _noteController.text;
    User? user = _auth.currentUser;
    String userType = 'student';
    

    if (user != null) {
      String userId = user.uid;

      if (nickname.isNotEmpty && rent.isNotEmpty && age > 0) {
        try {
          await _firestore.collection('profiles').doc(userId).set({
            'nickname': nickname,
            'gender': _gender,
            'rent': rent,
            'age': age,
            'introduction': note,
            'createdAt': FieldValue.serverTimestamp(),
            'selectedOption': _lifeStyle,
            'hygieneLevel': _hygieneLevel,
            'profileImageUrl': profileImageUrl,
            'userType' : userType,
            'userId': userId,
            'isBanned':isBanned,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );

          
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 20),

              const Text(
                'Age',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'age',
                ),
              ),
              

              const SizedBox(height: 20),
              const Text(
                'Gender',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              DropdownButton<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Maximum Rent',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _rentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your budget',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'A Note About Yourself',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a note',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Hygiene level',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              DropdownButton<String>(
                value: _hygieneLevel,
                items: const [
                  
                  DropdownMenuItem(
                    value: "3",
                    child: Text("3(very clean)"),
                  ),
                  DropdownMenuItem(
                    value: '2',
                    child: Text('2(middle)'),
                  ),
                  DropdownMenuItem(
                    value: "1",
                    child: Text("1(not really clean)"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _hygieneLevel = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Your LifeStyle',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _lifeStyle,
                items: const [
                  DropdownMenuItem(
                    value: "noisy",
                    child: Text("I'm noisy"),
                  ),
                  DropdownMenuItem(
                    value: 'quiet',
                    child: Text('Quiet'),
                  ),
                  DropdownMenuItem(
                    value: "noisy only in the morning",
                    child: Text("Noisy only in the morning"),
                  ),
                  DropdownMenuItem(
                    value: "noisy mainly at night",
                    child: Text("Noisy mainly at night"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _lifeStyle = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              
              GestureDetector(
                onTap: () {
                  prf.saveProfile(
                    _nicknameController.text,
                    _lifeStyle!,
                    _hygieneLevel!,
                    _genderController.text,
                    _rentController.text,
                    int.parse(_ageController.text),
                    _noteController.text,
                    'student',
                    profileImageUrl?? ''
                    );
                  
                  setState(() {
                  _nicknameController.clear();
                  _gender = null;
                  _rentController.clear();
                  _ageController.clear();
                  _noteController.clear();
                  _lifeStyle = null;
                });
                },
                  
                child: Container(
                  width: 100,
                  height: 70,
                  decoration: BoxDecoration(
                   color: Color.fromARGB(255, 58, 255, 153),
                   borderRadius: BorderRadius.circular(20.0),
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text('Save', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,fontFamily: 'bold'),),
                      Icon(Icons.edit_document, size: 30,),
                    ],)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
