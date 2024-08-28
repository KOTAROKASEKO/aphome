
import 'package:flutter/material.dart';

class SharedState extends ChangeNotifier {
  int _rent = 0;
  String _gender = 'any';
  String _hygiene = 'any';
  String _lifeStyle = 'any';

  int get rent => _rent;
  String get gender => _gender;
  String get hygiene => _hygiene;
  String get lifeStyle => _lifeStyle;

  void updateState({required int rent, required String gender, required String hygiene, required String lifeStyle}) {
    _rent = rent;
    _gender = gender;
    _hygiene = hygiene;
    _lifeStyle = lifeStyle;

    notifyListeners();
  }
}