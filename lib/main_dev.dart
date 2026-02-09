import 'package:flutter/foundation.dart';
import 'app_bootstrap.dart';
import 'core/config/app_config.dart';

void main() {
  final config = AppConfig.dev();

  if (config.enableLogging && kDebugMode) {
    debugPrint('🚀 Nebula starting in ${config.flavor.name.toUpperCase()} mode');
    debugPrint('   API: ${config.apiBaseUrl}');
  }

  bootstrap(config);
}
