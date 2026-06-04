enum AppEnvironment {
  dev,
  uat,
  demo,
  production;

  static AppEnvironment fromName(String name) {
    switch (name.toLowerCase()) {
      case 'dev':
        return AppEnvironment.dev;
      case 'uat':
        return AppEnvironment.uat;
      case 'demo':
        return AppEnvironment.demo;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      default:
        return AppEnvironment.production;
    }
  }

  String get displayName => switch (this) {
        AppEnvironment.dev => 'ITE Store Dev',
        AppEnvironment.uat => 'ITE Store Test',
        AppEnvironment.demo => 'ITE Store Demo',
        AppEnvironment.production => 'ITE Store',
      };

  String get shortLabel => switch (this) {
        AppEnvironment.dev => 'DEV',
        AppEnvironment.uat => 'UAT',
        AppEnvironment.demo => 'DEMO',
        AppEnvironment.production => 'PROD',
      };

  bool get cartEnabled => this != AppEnvironment.demo;
}
