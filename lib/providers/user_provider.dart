import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  UserProvider() {
    // Listen to auth state changes to automatically fetch profile
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (data.event == AuthChangeEvent.signedIn && session != null) {
        // Instant update from session metadata before DB fetch
        _email = session.user.email ?? _email;
        _firstName =
            session.user.userMetadata?['full_name'] ??
            session.user.userMetadata?['name'] ??
            _firstName;
        _lastName = '';
        _avatarUrl =
            session.user.userMetadata?['avatar_url'] ??
            session.user.userMetadata?['picture'];
        notifyListeners();
        fetchProfile(); // Still fetch from DB for other details
      } else if (data.event == AuthChangeEvent.initialSession &&
          session != null) {
        fetchProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _resetProfile();
      }
    });
  }

  String _firstName = 'Manet';
  String _lastName = 'Hourn';
  String _email = 'hournmaneth88@gmail.com';
  String _gender = 'Male';
  String _phoneNumber = '';
  String _dob = '01/01/2000';
  String _address = '';
  String? _avatarUrl;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get gender => _gender;
  String get phoneNumber => _phoneNumber;
  String get dob => _dob;
  String get address => _address;
  String get fullName => '$_firstName $_lastName';
  String? get avatarUrl => _avatarUrl;

  void _resetProfile() {
    _firstName = 'Guest';
    _lastName = '';
    _email = '';
    _gender = 'Other';
    _phoneNumber = '';
    _dob = '';
    _address = '';
    _avatarUrl = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String phoneNumber,
    required String dob,
    required String address,
  }) async {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _gender = gender;
    _phoneNumber = phoneNumber;
    _dob = dob;
    _address = address;
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
          'address': _address,
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
        _address = data['address'] ?? _address;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }
}
