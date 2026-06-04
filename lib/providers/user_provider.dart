import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _firstName = 'Manet';
  String _lastName = 'Hourn';
  String _email = 'hournmaneth88@gmail.com';
  String _gender = 'Male';
  String _phoneNumber = '';
  String _dob = '01/01/2000';

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get gender => _gender;
  String get phoneNumber => _phoneNumber;
  String get dob => _dob;
  String get fullName => '$_firstName $_lastName';

  void updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String phoneNumber,
    required String dob,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _gender = gender;
    _phoneNumber = phoneNumber;
    _dob = dob;
    notifyListeners();
  }
}
