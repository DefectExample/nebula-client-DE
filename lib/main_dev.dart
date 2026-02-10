import 'package:flutter/foundation.dart';
import 'app_bootstrap.dart';
import 'core/api/nebula_api.dart';
import 'core/config/app_config.dart';

void main() {
  final config = AppConfig.dev();

  // Initialize Nebula Core FFI
  final api = NebulaApi();
  final version = api.version();
  final initResult = api.init();

  if (config.enableLogging && kDebugMode) {
    debugPrint('🚀 Nebula starting in ${config.flavor.name.toUpperCase()} mode');
    debugPrint('   API: ${config.apiBaseUrl}');
    debugPrint('🌌 Nebula Core Version: $version');
    if (initResult == 0) {
      debugPrint('✅ Nebula Core initialized successfully');
    } else {
      debugPrint('❌ Nebula Core initialization failed with code: $initResult');
    }
  }

  bootstrap(config);
}
