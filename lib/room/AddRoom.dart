import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test2/BottomTab.dart';
import 'package:test2/color.dart';


class AddRoom extends StatefulWidget {
  final String? documentId;

  AddRoom({this.documentId});

  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _condoNameController = TextEditingController();
  final TextEditingController _wantedGenderController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _numOfRoomsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _AddressController = TextEditingController();

  bool _isLoading = true;
  List<File?> _imageFiles = List<File?>.filled(4, null);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      _loadData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    var document = await FirebaseFirestore.instance
        .collection('RoomInformation')
        .doc(widget.documentId)
        .get();

    if (document.exists) {
      var data = document.data()!;
      _condoNameController.text = data['condominiumName'];
      _wantedGenderController.text = data['ForWhatGender'];
      _rentController.text = data['rent'];
      _numOfRoomsController.text = data['numOfRooms'].toString();
      _noteController.text = data['introduction'];
      _AddressController.text = data['address'];
      
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  

  Future<void> _selectImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles[index] = File(pickedFile.path);
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];

    for (int i = 0; i < _imageFiles.length; i++) {
      if (_imageFiles[i] != null) {
        try {
          var snapshot = await FirebaseStorage.instance
              .ref()
              .child('images/${DateTime.now().millisecondsSinceEpoch}_$i.jpg')
              .putFile(_imageFiles[i]!);
          String downloadUrl = await snapshot.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);
        } catch (e) {
          print('Error uploading image $i: $e');
          return [];
        }
      } else {
        downloadUrls.add('');
      }
    }
    return downloadUrls;
  }

  Future<void> _saveProfile() async {
    String condoName = _condoNameController.text;
    String wantedGender = _wantedGenderController.text;
    String rent = _rentController.text;
    int numOfRooms = int.tryParse(_numOfRoomsController.text) ?? 0;
    String note = _noteController.text;
    User? user = _auth.currentUser;
    String address = _AddressController.text;

    if (user != null) {
      String userId = user.uid;
      if (condoName.isNotEmpty &&
          wantedGender.isNotEmpty &&
          rent.isNotEmpty &&
          numOfRooms > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading.....')),
        );
        List<String> imageUrls = await _uploadImages();
        if (widget.documentId == null) {
          await FirebaseFirestore.instance.collection('RoomInformation').add({
            'userId': userId,
            'condominiumName': condoName,
            'address':address,
            'ForWhatGender': wantedGender,
            'rent': rent,
            'numOfRooms': numOfRooms,
            'introduction': note,
            'photoUrls': imageUrls,
            'createdAt': FieldValue.serverTimestamp(),


            'timestamp': FieldValue.serverTimestamp(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room information was uploaded')),
          );
        } else {
          await FirebaseFirestore.instance
              .collection('RoomInformation')
              .doc(widget.documentId)
              .update({

            'condominiumName': condoName,
            'ForWhatGender': wantedGender,
            'rent': rent,
            'numOfRooms': numOfRooms,
            'introduction': note,
            'photoUrls': imageUrls,
            'updatedAt': FieldValue.serverTimestamp(),

          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room information was updated')),
          );
        }

        setState(() {
          _condoNameController.clear();
          _wantedGenderController.clear();
          _rentController.clear();
          _numOfRoomsController.clear();
          _noteController.clear();
          _AddressController.clear();
          _imageFiles = List<File?>.filled(4, null);

        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BottomTab()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields and select a location')),
        );
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Room',
          style: TextStyle(color: AppColors.appBarFonto, fontFamily: 'bold'),
        ),
        backgroundColor: Colors.black,
        iconTheme:IconThemeData(color: AppColors.profileFonto),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _condoNameController,
                      decoration: const InputDecoration(labelText: 'Condominium name'),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _AddressController,
                      decoration: const InputDecoration(labelText: 'property Address'),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _AddressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 3,
                    ),


                    TextField(
                      controller: _wantedGenderController,
                      decoration: const InputDecoration(labelText: 'Wanted gender'),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _rentController,
                      decoration: const InputDecoration(labelText: 'rent'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      
                      controller: _numOfRoomsController,
                      decoration: const InputDecoration(labelText: 'Number of rooms'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: 'Note'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: List.generate(
                        4,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: () => _selectImage(index),
                            child: Container(
                              height: 100,
                              margin: const EdgeInsets.all(8),
                              color: Colors.grey[200],
                              child: _imageFiles[index] != null
                                  ? Image.file(
                                      _imageFiles[index]!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.add_photo_alternate),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
