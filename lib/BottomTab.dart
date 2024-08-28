import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/chat/Tutorial.dart';
import 'package:test2/main.dart';
import 'package:test2/profile/ProfileView.dart';
import 'package:test2/chat/ChatList.dart';
import 'package:test2/color.dart';
import 'package:test2/room_roommate.dart';
import 'auth/authenticationView.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomTab extends StatefulWidget {
  const BottomTab({super.key});

  @override
  _BottomTabState createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab>  with SingleTickerProviderStateMixin{
  static bool isLoggedIn = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    RoomRoommate(),
    Builder(
      builder: (context) {
        return _BottomTabState.isLoggedIn ? ChatUserGridView() : Tutorial();
      },
    ),
    Builder(
      builder: (context) {
        return _BottomTabState.isLoggedIn ? ProfilePage() : const AuthScreen();
      },
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });


  }

  @override
  Widget build(BuildContext context) {
    bool newMessageReceived = Provider.of<SharedMessageState>(context).newMessageReceived;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          color: AppColors.appBarColorDark,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: GNav(
              backgroundColor: AppColors.appBarColorDark,
              color: const Color.fromARGB(255, 242, 242, 242),
              activeColor: const Color.fromARGB(255, 242, 242, 242),
              tabBackgroundColor: Colors.grey.shade800,
              gap: 8,
              padding: const EdgeInsets.all(16),
              tabs: [
                const GButton(
                  icon: Icons.business,
                  text: 'Room/Member',
                ),
                GButton(
                  icon: Icons.message,
                  text: 'Message',
                  leading: newMessageReceived
                      ? Stack(
                          children: [
                            const Icon(Icons.message, color: AppColors.appBarFonto,),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: const Text(
                                  '!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Icon(Icons.message, color: AppColors.appBarFonto,),
                ),
                const GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
