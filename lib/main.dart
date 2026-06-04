import 'package:flutter/material.dart';

import 'app.dart';
import 'config/app_environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const envName = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  final environment = AppEnvironment.fromName(envName);
  runApp(IteStoreApp(environment: environment));
}
