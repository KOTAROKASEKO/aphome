import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/chat/ChatView.dart';
import 'package:test2/color.dart';
import 'package:test2/report.dart';

class DetailedProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  DetailedProfileScreen({required this.profileData});

  @override
  _DetailedProfileScreenState createState() => _DetailedProfileScreenState();
}

class _DetailedProfileScreenState extends State<DetailedProfileScreen> {
  bool loggedIn = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    initializeState();
    _getCurrentUser();
  }

  Future<void> initializeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loginStatus = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      loggedIn = loginStatus;
    });
  }

  void _getCurrentUser(){
    FirebaseAuth _auth = FirebaseAuth.instance;
    currentUser = _auth.currentUser;
  }


  
  String? get userId => widget.profileData['userId'];
  String? get profileImageUrl => widget.profileData['profileImageUrl'];
  String? get nickname => widget.profileData['nickname'];
  String? get age => widget.profileData['age']?.toString();
  String? get rent => widget.profileData['rent']?.toString();
  String? get gender => widget.profileData['gender'];
  String? get lifeStyle => widget.profileData['selectedOption'];
  String? get introduction => widget.profileData['introduction'];
  String? get hygieneLevel => widget.profileData['hygieneLevel'];
  String? get userType => widget.profileData['userType'];

  bool get isAgentOrAdmin => userType == 'agent' || userType == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBarColorDark,
        title: Text(
          "Detailed Profile",
          style: TextStyle(color: AppColors.appBarFonto),
        ),
        iconTheme: IconThemeData(color: AppColors.appBarFonto),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildProfileHeader(),
            if (!isAgentOrAdmin) buildProfileDetails(),
            buildIntroduction(),
            buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? buildProfileImage(profileImageUrl!)
                : buildDefaultProfileImage(),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nickname ?? 'Loading...',
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 30,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 10),
            if (!isAgentOrAdmin)
              Text(
                age ?? 'Loading...',
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 20,
                  color: AppColors.appBarFonto,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildProfileImage(String url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: Image.network(
          url,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildDefaultProfileImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 164, 164, 164),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: const Center(
        child: Icon(Icons.person),
      ),
    );
  }

  Widget buildProfileDetails() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Budget: ~',
              style: TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),
            ),
            Text(
              rent ?? '',
              style: const TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),
            ),
            const Text(
              "rm",
              style: TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gender: ',
              style: TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),
            ),
            Text(
              gender ?? '',
              style: const TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),
            ),
          ],
        ),
      
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'hygieneLevel: ',
              style: TextStyle(fontFamily: 'bold', fontSize: 20, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            Text(
              hygieneLevel ?? 'Loading...',
              style: const TextStyle(fontFamily: 'bold', fontSize: 20, color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lifeStyle ?? '',
              style: const TextStyle(fontFamily: 'bold', fontSize: 20, color: AppColors.appBarFonto),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildIntroduction() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                introduction ?? 'Loading...',
                softWrap: true,
                style: const TextStyle(fontSize: 15, fontFamily: 'OpenSuns', color: AppColors.appBarFonto),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          child: Column(
            children: const [
              Icon(Icons.report, color: Colors.white, size: 40),
              Text('Report', style: TextStyle(color: Colors.white)),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportScreen(userId),
            ),
          ),
        ),
        GestureDetector(
          child: Column(
            children: const [
              Icon(Icons.message, color: Colors.white, size: 40),
              Text('Chat', style: TextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            if (loggedIn&&userId!=currentUser) {
              
              print('(detailedRoommate)current user: $currentUser');
              print('(detailedRoommate)current user: $userId');

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatView(userId)),
                
              );
            } else if(userId==currentUser){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("error"),
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
            else {
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
          },
        ),
      ],
    );
  }
}
