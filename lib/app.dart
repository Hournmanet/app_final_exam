import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_environment.dart';
import 'config/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/product_catalog_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/order_provider.dart';
import 'providers/language_provider.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

class IteStoreApp extends StatelessWidget {
  const IteStoreApp({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductCatalogProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: environment.displayName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(environment),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                elevation: 0,
                scrolledUnderElevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1E1E1E),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey,
              ),
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
                surface: Color(0xFF1E1E1E),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: AuthWrapper(environment: environment),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final AppEnvironment environment;
  const AuthWrapper({super.key, required this.environment});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authSubscription;
  bool _isInitialSessionChecked = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint('AuthWrapper: Auth State Change Event: $event');

      if (event == AuthChangeEvent.signedIn && session != null) {
        debugPrint('AuthWrapper: User signed in. Syncing profile...');
        _authService.syncUserProfile();
        if (mounted) {
          context.read<UserProvider>().fetchProfile();
          context.read<OrderProvider>().loadOrders();
        }
      }

      if (event == AuthChangeEvent.initialSession && session != null && mounted) {
        context.read<OrderProvider>().loadOrders();
      }

      if (event == AuthChangeEvent.signedOut && mounted) {
        context.read<OrderProvider>().clearOrders();
      }

      if (mounted) {
        setState(() {
          _isInitialSessionChecked = true;
        });
      }
    });

    // Handle initial session check
    _authService.recoverSession().then((_) async {
      if (!mounted) return;
      if (_authService.currentUser != null) {
        await context.read<OrderProvider>().loadOrders();
      }
      if (mounted) {
        setState(() {
          _isInitialSessionChecked = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialSessionChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HomeScreen(environment: widget.environment);
  }
}
