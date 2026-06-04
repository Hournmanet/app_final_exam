import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  /// Must match Supabase Dashboard → Auth → URL Configuration → Redirect URLs.
  static const String oauthRedirectTo = 'io.supabase.flutter://login-callback/';
  static const String oauthCallbackScheme = 'io.supabase.flutter';

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get the current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get the current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Google sign-in in an in-app sheet (not Safari). Completes the session here
  /// so the WebView does not get stuck on the Supabase "invalid path" page.
  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('AuthService: Initiating Google OAuth (in-app)...');

      final response = await _supabase.auth.getOAuthSignInUrl(
        provider: OAuthProvider.google,
        redirectTo: kIsWeb ? null : oauthRedirectTo,
        queryParams: const {'prompt': 'select_account'},
      );

      if (kIsWeb) {
        final launched = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: null,
          queryParams: const {'prompt': 'select_account'},
        );
        return launched;
      }

      debugPrint('AuthService: Opening in-app auth sheet...');

      final callbackResult = await FlutterWebAuth2.authenticate(
        url: response.url,
        callbackUrlScheme: oauthCallbackScheme,
        options: const FlutterWebAuth2Options(
          intentFlags: 0,
        ),
      );

      debugPrint('AuthService: OAuth callback received');

      if (_supabase.auth.currentSession == null) {
        await _supabase.auth.getSessionFromUrl(Uri.parse(callbackResult));
      }

      debugPrint(
        'AuthService: Google sign-in complete (${_supabase.auth.currentUser?.email})',
      );
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        debugPrint('AuthService: Google OAuth cancelled by user');
        return false;
      }
      debugPrint('AuthService: Google OAuth platform error: $e');
      rethrow;
    } on AuthException catch (e) {
      debugPrint('AuthService: Google OAuth AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService: Google OAuth unexpected error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('AuthService: Logging out user ${currentUser?.id}...');
      await _supabase.auth.signOut();
      debugPrint('AuthService: Logout successful.');
    } catch (e) {
      debugPrint('AuthService: Logout error: $e');
      rethrow;
    }
  }

  /// Recover session from persistence
  Future<void> recoverSession() async {
    try {
      debugPrint('AuthService: Attempting to restore session...');
      final session = _supabase.auth.currentSession;
      if (session != null) {
        debugPrint('AuthService: Session restored for user ${session.user.id}');
      } else {
        debugPrint('AuthService: No active session found.');
      }
    } catch (e) {
      debugPrint('AuthService: Session restoration error: $e');
    }
  }

  /// Create or update user profile in Supabase
  Future<void> syncUserProfile() async {
    final user = currentUser;
    if (user == null) return;

    try {
      debugPrint('AuthService: Syncing profile for user ${user.id}...');

      final profileData = {
        'id': user.id,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final email = user.email;
      if (email != null) profileData['email'] = email;

      final fullName =
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
      if (fullName != null) profileData['full_name'] = fullName;

      final avatarUrl =
          user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
      if (avatarUrl != null) profileData['avatar_url'] = avatarUrl;

      await _supabase
          .from('profiles')
          .upsert(
            profileData,
            onConflict: 'id',
          );
      debugPrint('AuthService: Profile synced successfully.');
    } catch (e) {
      debugPrint(
        'AuthService: Profile sync error (Check if columns email, full_name, avatar_url exist in profiles table): $e',
      );
    }
  }
}
