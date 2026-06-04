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
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        // OAuth callback is completed in AuthService via flutter_web_auth_2.
        detectSessionInUri: false,
      ),
    );
    
    debugPrint('Supabase initialized successfully.');
    
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      debugPrint('Session restored for user: ${currentUser.email}');
    } else {
      debugPrint('No active session found.');
    }
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
  }

  const envName = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  final environment = AppEnvironment.fromName(envName);
  runApp(IteStoreApp(environment: environment));
}
