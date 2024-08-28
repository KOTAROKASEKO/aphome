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
  ProfileModel prf;

  ProfileSaveProvider(this.prf){
    saveProfile();
  }

   Future<void> saveProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      if (prf.nickname.isNotEmpty && prf.rent.isNotEmpty && prf.age > 0) {
        try {
          _isLoading = true;
          notifyListeners(); // Notify listeners that the process started
          // Save to Firebase Firestore
          await FirebaseFirestore.instance.collection('profiles').doc(userId).set({
            'nickname': prf.nickname,
            'gender': prf.gender,
            'rent': prf.rent,
            'age': prf.age,
            'introduction': prf.introduction,
            'createdAt': FieldValue.serverTimestamp(),
            'selectedOption': prf.selectedOption,
            'hygieneLevel': prf.hygieneLevel,
            'userType': prf.userType,
            'userId': userId,
            'isBanned': false,
            'photoUrls': prf.photoUrls,
          });

          // Save to Hive
          var profilesBox = await Hive.openBox('profilesBox');
          profilesBox.put(userId, prf);
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

