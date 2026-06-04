import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_environment.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/order_provider.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_edit_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  String _selectedLanguage = 'English';

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(environment: widget.environment),
      ),
    );
  }

  void _openOrders() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OrdersScreen()));
  }

  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Log Out',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be lost.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Me',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _openCart,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(isDark),
          const SizedBox(height: 24),
          _buildOnlineBanner(context.watch<OrderProvider>().hasOrders),
          const SizedBox(height: 32),
          _buildActionGrid(isDark),
          const SizedBox(height: 32),
          _buildLanguageSection(isDark),
          const SizedBox(height: 32),
          _buildSupportSection(isDark),
          const SizedBox(height: 24),
          _buildSettingsSection(isDark, themeProvider),
          const SizedBox(height: 24),
          _buildAccountDeletionSection(isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    final userProvider = context.watch<UserProvider>();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.fullName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userProvider.email,
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineBanner(bool hasPurchases) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC68E5A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ONLINE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: const [
                  Text(
                    'Explore more',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasPurchases
                ? "You have successfully placed orders!"
                : "You haven't made any success purchase yet.",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 24,
      crossAxisSpacing: 16,
      children: [
        _buildActionItem(
          Icons.description_outlined,
          'MY ORDERS',
          isDark,
          onTap: _openOrders,
        ),
        _buildActionItem(Icons.qr_code_scanner, 'My QR', isDark),
        _buildActionItem(Icons.card_membership_outlined, 'GIFT CARD', isDark),
        _buildActionItem(Icons.storefront_outlined, 'FIND A STORE', isDark),
      ],
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: isDark ? Colors.white : Colors.black),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ភាសា / Languages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        _buildLanguageOption('English', isDark),
        _buildLanguageOption('ខ្មែរ', isDark),
        _buildLanguageOption('中文', isDark),
      ],
    );
  }

  Widget _buildLanguageOption(String language, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: RadioListTile<String>(
        title: Text(
          language,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        value: language,
        groupValue: _selectedLanguage,
        onChanged: (value) => setState(() => _selectedLanguage = value!),
        activeColor: isDark ? Colors.white : Colors.black,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildSupportSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildListTile('Privacy policy', isDark),
        _buildListTile('FAQs & guides', isDark),
        _buildListTile('Rate this app', isDark),
        _buildListTile('Recommend this app', isDark),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Contact us'),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(bool isDark, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
              activeColor: Colors.white,
              activeTrackColor: Colors.black,
            ),
          ),
        ),
        _buildListTile('Clear cache', isDark),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showLogoutDialog(isDark),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('LOG OUT'),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDeletionSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account deletion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildListTile(
          'Delete account',
          isDark,
          onTap: () => _showDeleteAccountDialog(isDark),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, bool isDark, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: isDark ? Colors.white : Colors.black,
        ),
        onTap: onTap,
      ),
    );
  }
}
