import 'package:flutter/material.dart';
import 'package:test2/color.dart';

class Tutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutorial', style: TextStyle(color: AppColors.appBarFonto),), backgroundColor: AppColors.appBarColorDark,
      ),
      body: SingleChildScrollView(
        child: Column(children: const [
          SizedBox(height: 40,),

          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to', style: TextStyle(fontFamily: 'bold',fontSize: 30, color: Colors.black),),
            Text(' stuGent', style: TextStyle(fontFamily: 'bold', fontSize: 30, color: Colors.green),),
            ],
          ),

          Padding(padding: 
          EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Text(softWrap: true, 'stuGent is an amazing platform to find a room or roommate, or even unit!',
            style: TextStyle(fontFamily: 'opensuns', fontSize: 20),
            ),
          ),
          
          Image(
            image: AssetImage('assets/greeting.jpg'),
          ),
            Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Text(softWrap: true, 'Once you find your best room/property/roommate, you can chat!',style: TextStyle(fontFamily: 'opensuns', fontSize: 20),),
          ),
        ],),
      ),
    );
  }
}
