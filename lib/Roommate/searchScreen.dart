import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test2/sharedState.dart';

//search screen for Roommate
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}



class _SearchScreenState extends State<SearchScreen> {
  TextEditingController rentController = TextEditingController();

  int rent = 0;
  String gender = 'any';
  String hygiene = 'any'; 
  String lifeStyle = 'any'; //ここがdropdownbuttonのオプションの中の値に存在していなかったのでエラーが出た

void _onSearch() {

  Provider.of<SharedState>(context, listen: false).updateState(
    rent: rent,
    gender: gender,
    hygiene: hygiene,
    lifeStyle: lifeStyle,
  );
}
  List<String> genders = [
    'any',
    'Male',
    'Female'
  ];

  List<String> lifestyleItems = [
  'any',
  'quiet',
  'noisy',
  'noisy only in the morning',
  'noisy mainly at night',
  ];

  List<String> hygieneItems = [
    'any',
    '3',
    '2',
    '1',
  ];


  @override
  Widget build(BuildContext context) {
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
                const SizedBox(
                  width: 80,
                  child: Text('Budget'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter minimum budget',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        rent = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.male),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 80,
                  child: Text('Gender'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: gender,
                    items: genders.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  )
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.cleaning_services),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 80,
                  child: Text('Hygiene'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: hygiene,
                    items: hygieneItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        hygiene = value!;
                      });
                    },
                  ),
               ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.nightlife),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 80,
                  child: Text('Lifestyle'),
                ),
                const SizedBox(width: 10),
                
                  //this place
                  Expanded(
                    child: DropdownButton<String>(
                    value: lifeStyle,
                    items: lifestyleItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        lifeStyle = value!;
                      });
                    },
                  ),
                ),
                
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){
                _onSearch();
              Navigator.of(context).pop();
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
