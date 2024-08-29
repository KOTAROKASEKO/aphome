import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:test2/profile/profileModel.dart';

class ProfileSaveProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isProfileSaved = false;
  bool _isLoading = false;

  bool get isProfileSaved => _isProfileSaved;
  bool get isLoading => _isLoading;

  Future<void> saveProfile(

      String nickname,
      String selectedOption,
      String _hygieneLevel,
      String _gender,
      String rent,
      int age,
      String note,
      String userType,
      String photoUrl,
      ) async {

    
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      if (nickname.isNotEmpty && rent.isNotEmpty && age > 0) {
        try {
          _isLoading = true;
          notifyListeners(); // Notify listeners that the process started
          // Save to Firebase Firestore
          await FirebaseFirestore.instance.collection('profiles').doc(userId).set({
            'nickname': nickname,
            'gender': _gender,
            'rent': rent,
            'age': age,
            'introduction': note,
            'createdAt': FieldValue.serverTimestamp(),
            'selectedOption': selectedOption,
            'hygieneLevel': _hygieneLevel,
            'userType': userType,
            'userId': userId,
            'isBanned': false,
            'photoUrls': photoUrl,
          });

          // Save to Hive
          var profilesBox = await Hive.openBox('profilesBox');
          ProfileModel profile = ProfileModel(
            nickname: nickname,
            gender: _gender,
            rent: rent,
            age: age,
            introduction: note,
            selectedOption: selectedOption,
            hygieneLevel: _hygieneLevel,
            userType: userType,
            userId: userId,
            photoUrls: photoUrl,
          );
          profilesBox.put(userId, profile);
          

          _isProfileSaved = true;
          
        } catch (e) {
          _isProfileSaved = false; // Handle failure
        } finally {
          _isLoading = false;
          notifyListeners(); // Notify listeners that the process finished
        }
      }
    }
  }

  Future<ProfileModel?> getProfileFromHive(String userId) async {
    var profilesBox = await Hive.openBox('profilesBox');
    return profilesBox.get(userId) as ProfileModel?;
  }

  Future<DocumentSnapshot> getProfileFromFirestore(String userId) async {
    return await FirebaseFirestore.instance.collection('profiles').doc(userId).get();
  }
}

