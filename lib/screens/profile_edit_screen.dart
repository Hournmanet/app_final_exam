import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late String _gender;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _gender = userProvider.gender;
    _firstNameController = TextEditingController(text: userProvider.firstName);
    _lastNameController = TextEditingController(text: userProvider.lastName);
    _emailController = TextEditingController(text: userProvider.email);
    _phoneController = TextEditingController(text: userProvider.phoneNumber);
    _dobController = TextEditingController(text: userProvider.dob);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final fieldBorderColor = isDark ? Colors.white24 : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGenderSection(textColor),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTextField('First name', _firstNameController, isDark, fieldBorderColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Last name', _lastNameController, isDark, fieldBorderColor)),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField('Email', _emailController, isDark, fieldBorderColor),
            const SizedBox(height: 24),
            _buildPhoneField(isDark),
            const SizedBox(height: 24),
            _buildTextField('Date of birth (DD/MM/YYYY)', _dobController, isDark, fieldBorderColor),
            const SizedBox(height: 12),
            Text(
              'Add your birthday to unlock additional offering/reward!',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black87, fontSize: 12),
            ),
            const SizedBox(height: 32),
            _buildAddressSection(isDark, textColor),
            const SizedBox(height: 40),
            _buildSaveButton(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSection(Color textColor) {
    return Row(
      children: [
        Text('Gender', style: TextStyle(color: textColor, fontSize: 14)),
        const SizedBox(width: 24),
        _buildGenderOption('Male', textColor),
        const SizedBox(width: 16),
        _buildGenderOption('Female', textColor),
      ],
    );
  }

  Widget _buildGenderOption(String value, Color textColor) {
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: textColor, width: 1),
            ),
            child: _gender == value
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: textColor),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: textColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              suffixIcon: Icon(Icons.check_circle_outline, color: Colors.green.shade200, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mobile number',
            style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _phoneController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            textAlign: _phoneController.text.isEmpty ? TextAlign.end : TextAlign.start,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              hintText: 'Add contact number',
              hintStyle: TextStyle(color: Colors.blue.shade400, fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your address', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isDark ? Colors.white24 : Colors.black)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Address book', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400)),
              Icon(Icons.chevron_right, color: textColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          context.read<UserProvider>().updateProfile(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                email: _emailController.text,
                gender: _gender,
                phoneNumber: _phoneController.text,
                dob: _dobController.text,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: const RoundedRectangleBorder(),
        ),
        child: const Text('Save',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
