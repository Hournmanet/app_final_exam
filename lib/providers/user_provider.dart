import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
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

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String phoneNumber,
    required String dob,
  }) async {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _gender = gender;
    _phoneNumber = phoneNumber;
    _dob = dob;
    notifyListeners();

    // Try to sync with Supabase if logged in
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'first_name': _firstName,
          'last_name': _lastName,
          'email': _email,
          'gender': _gender,
          'phone_number': _phoneNumber,
          'dob': _dob,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error syncing profile: $e');
    }
  }

  Future<void> fetchProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        _firstName = data['first_name'] ?? _firstName;
        _lastName = data['last_name'] ?? _lastName;
        _email = data['email'] ?? _email;
        _gender = data['gender'] ?? _gender;
        _phoneNumber = data['phone_number'] ?? _phoneNumber;
        _dob = data['dob'] ?? _dob;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }
}
