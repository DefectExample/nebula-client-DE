import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/api/nebula_api.dart';

void main() async {
  final config = AppConfig.prod();
  
  // Get platform-appropriate documents directory
  final appDir = await getNebulaDocumentsDirectory();
  
  // Ensure the directory exists
  if (!await appDir.exists()) {
    await appDir.create(recursive: true);
  }
  
  final dbPath = '${appDir.path}/nebula.db';
  
  // Pass dbPath to bootstrap for unified initialization
  bootstrap(config, dbPath: dbPath);
}
