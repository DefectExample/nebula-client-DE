/// Application environment configuration
enum AppFlavor {
  dev,
  prod,
}

/// Configuration for the Nebula application
/// 
/// This class holds environment-specific settings that vary between
/// development and production builds.
class AppConfig {
  final String appName;
  final String apiBaseUrl;
  final AppFlavor flavor;
  final bool enableLogging;

  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.flavor,
    required this.enableLogging,
  });

  /// Development configuration
  factory AppConfig.dev() => const AppConfig(
        appName: 'Nebula (Dev)',
        apiBaseUrl: 'https://dev-api.nebula.example.com',
        flavor: AppFlavor.dev,
        enableLogging: true,
      );

  /// Production configuration
  factory AppConfig.prod() => const AppConfig(
        appName: 'Nebula',
        apiBaseUrl: 'https://api.nebula.example.com',
        flavor: AppFlavor.prod,
        enableLogging: false,
      );

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
