import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_environment.dart';
import 'config/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/product_catalog_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/order_provider.dart';
import 'providers/language_provider.dart';
import 'screens/home_screen.dart';

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
            home: HomeScreen(environment: environment),
          );
        },
      ),
    );
  }
}
