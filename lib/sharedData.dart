import 'package:firebase_auth/firebase_auth.dart';

class SharedData {
  // Make this class a singleton to ensure only one instance is created
  static final SharedData _instance = SharedData._internal();
  factory SharedData() {
    return _instance;
  }
  SharedData._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Static method to get the current user ID
  static String getCurrentUserId() {
    User? currentUser = _instance._auth.currentUser;
    return currentUser?.uid ?? "No user logged in";
  }
}
