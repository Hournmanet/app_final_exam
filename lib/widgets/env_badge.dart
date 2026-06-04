import 'package:flutter/material.dart';

import '../config/app_environment.dart';
import '../config/app_theme.dart';

class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    if (environment == AppEnvironment.production) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.envBadgeColor(environment).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.envBadgeColor(environment).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        environment.shortLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.envBadgeColor(environment),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
