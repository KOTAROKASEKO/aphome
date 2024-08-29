import 'package:flutter/material.dart';
import 'package:test2/BottomTab.dart';
import 'package:test2/color.dart';
import 'package:test2/profile/ProfileSave.dart';

class CreateProfile extends StatefulWidget {
  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {

  final TextEditingController _nicknameController = TextEditingController();

  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _step = 0;
  String? _selectedOption;
  String? _hygieneLevel;
  String? _gender;
  ProfileSaveProvider prf = ProfileSaveProvider();



  void _nextStep() {
    setState(() {
      _step++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_step > 0) _step--;
    });
  }

  Widget _buildStep() {
      switch (_step) {
        case 0:
          return Center(
            child: Container(
              width: 400,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Let's create a profile!",
                    style: TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                  const Text(
                    'Your nickname',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your nickname',
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: const Text('Next ->'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '1/6',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        case 1:
          return Center(
            child: Container(
              width: 400,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.male, size: 30, color: Colors.blue,),
                    Icon(Icons.female, size: 30,color: Colors.red,),
                    Text(
                    'Gender',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ],),
                  
                  
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
                        _gender;
                        _gender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousStep,
                        child: const Text('<- Previous'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: const Text('Next ->'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '2/6',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        case 2:
          return Center(
            child: Container(
              width: 400,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money, size: 30, color: Color.fromARGB(255, 136, 123, 1),),
                      Text(
                    'maximum rent',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                    ],
                  ),
                  
                  
                  const SizedBox(height: 30),
                  TextField(
                    controller: _rentController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your budget',
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousStep,
                        child: const Text('<- Previous'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: const Text('Next ->'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '3/6',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        case 3:
          return Center(
            child: Container(
              width: 400,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Your age',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 30),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your age',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousStep,
                        child: const Text('<- Previous'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: const Text('Next ->'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '4/6',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],

              ),
            ),
          );
        case 4:
          return Center(
            child: Container(
              width: 400,
              height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'anything about you??',
                    style: TextStyle(fontSize: 15, color: Colors.green),
                  ),
                  SizedBox(height: 10,),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.person, size: 30,),
                    Text(
                    'note about yourself',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  ],),

                  
                  
                  const SizedBox(height: 30),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a note',
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousStep,
                        child: const Text('<- Previous'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: const Text('Next ->'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '5/6',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        case 5:
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: 400,
          // Remove the fixed height of the container
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(0,50,0,0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                
                
              Icon(Icons.bed),
              SizedBox(
                width: 20,
              ),
              Text(
                'ABOUT LIFE STYLE',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),],
              ),),
            const Text(
                'ABOUT LIFE SOUND',
                style: TextStyle(fontSize: 15),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0,20,0,0),
              child: Text(
                'You are..',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),),
              
              
              const SizedBox(height: 30),
              DropdownButton<String>(
                value: _selectedOption,
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
                    _selectedOption = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'ABOUT KITCHEN USE:',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 30),
              const Text(
                'CLEAN LEVEL',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              /**
              * 
              * DROP DOWN MENU
              * 
              */
              DropdownButton<String>(
                value: _hygieneLevel,
                items: const [
                  DropdownMenuItem(
                    value: "3",
                    child: Text("3 (very clean)"),
                  ),
                  DropdownMenuItem(
                    value: '2',
                    child: Text('2 (middle)'),
                  ),
                  DropdownMenuItem(
                    value: "1",
                    child: Text("1 (don't really clean up)"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _hygieneLevel = value!;
                  });
                },
              ),

              /**
              * 
              * DROP DOWN MENU
              * 
              */
              const SizedBox(height: 30),
              const Text(
                '6 of 6',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _previousStep,
                    child: const Text('<- Previous'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                    
                    prf.saveProfile(
                    _nicknameController.text,
                    _selectedOption!,
                    _hygieneLevel!,
                    _gender!,
                    _rentController.text,
                    int.tryParse(_ageController.text) ?? 0,
                    _noteController.text,
                    'student',
                    '',
                  );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BottomTab()),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  default:
    return Container();

      }
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColorDark,
        title: const Text('Create Profile'),
      ),
      body: _buildStep(),
    );
  }
}
