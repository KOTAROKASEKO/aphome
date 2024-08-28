import 'package:flutter/material.dart';
import 'package:test2/Roommate/RoommateList.dart';
import 'package:test2/color.dart';
import 'package:test2/room/roomList.dart';
import 'package:test2/unit/UnitList.dart';

class RoomRoommate extends StatefulWidget {
  @override
  _RoomRoommateState createState() => _RoomRoommateState();
}

class _RoomRoommateState extends State<RoomRoommate> {
  // Step 1: Declare the controllers
  final TextEditingController rentController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Step 2: Initialize the controllers (if needed)d
  @override
  void initState() {
    super.initState();
  }

  // Step 3: Dispose of the controllers
  @override
  void dispose() {
    rentController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // Step 4: Build the widget tree and use the controllers
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // Create a GlobalKey to access the ScaffoldState
        key: _scaffoldKey,

        appBar: AppBar(
          backgroundColor: AppColors.appBarColorDark,
          title: const Text('Room and Roommate', style: TextStyle(color: Colors.white, fontFamily: 'bold')),
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            onTap: (index) {
              setState(() {});
            },
            tabs: const [
              Tab(
                icon: Icon(Icons.bed),
                child: Text('room'),
              ),
              Tab(
                icon: Icon(Icons.person),
                child: Text('roommate'),
              ),
              Tab(
                icon: Icon(Icons.home),
                child: Text('unit'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RoomGridView(),
            RoommateList(),
            UnitGridView(),
          ],
        ),
      ),
    );
  }

  // Create a GlobalKey to access the ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
}
