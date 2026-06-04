import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/app_environment.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    // Sign in anonymously if no user is logged in
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      debugPrint('No active Supabase session. Attempting anonymous sign-in...');
      try {
        final response = await supabase.auth.signInAnonymously();
        debugPrint('Anonymous sign-in successful: ${response.user?.id}');
      } catch (authError) {
        debugPrint('CRITICAL: Anonymous sign-in failed. Ensure "Anonymous sign-in" is ENABLED in your Supabase Dashboard (Auth > Providers). Error: $authError');
      }
    } else {
      debugPrint('Active Supabase session found: ${currentUser.id} (${currentUser.email ?? "Guest"})');
    }
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
    // We continue so the app doesn't crash, but features requiring Supabase will show errors
  }

  const envName = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  final environment = AppEnvironment.fromName(envName);
  runApp(IteStoreApp(environment: environment));
}
