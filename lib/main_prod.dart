import 'package:flutter/material.dart';
import 'app_bootstrap.dart';
import 'core/api/nebula_api.dart';
import 'core/config/app_config.dart';

void main() {
  final config = AppConfig.prod();

  // Initialize Nebula Core FFI
  final api = NebulaApi();
  int initResult = -1;

  try {
    api.version(); // Ensure library loads
    initResult = api.init();
  } catch (e) {
    debugPrint('❌ Critical Error: Failed to load Nebula Core: $e');
  }

  if (initResult != 0) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'System Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Initialization failed.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  bootstrap(config);
}
