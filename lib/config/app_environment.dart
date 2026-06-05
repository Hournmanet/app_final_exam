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
    AppEnvironment.dev => 'MDN App Dev',
    AppEnvironment.uat => 'MDN App Test',
    AppEnvironment.demo => 'MDN App Demo',
    AppEnvironment.production => 'MDN App',
  };

  String get shortLabel => switch (this) {
    AppEnvironment.dev => 'DEV',
    AppEnvironment.uat => 'UAT',
    AppEnvironment.demo => 'DEMO',
    AppEnvironment.production => 'PROD',
  };

  bool get cartEnabled => this != AppEnvironment.demo;
}
