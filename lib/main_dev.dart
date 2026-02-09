import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'core/api/nebula_api.dart';

void main() {
  // Initialize Nebula API and print version
  final api = NebulaApi();
  final version = api.version();
  print('🌌 Nebula Core Version: $version');
  
  // Initialize the core
  final initResult = api.init();
  if (initResult == 0) {
    print('✅ Nebula Core initialized successfully');
  } else {
    print('❌ Nebula Core initialization failed with code: $initResult');
  }

  runApp(
    const ProviderScope(
      child: NebulaApp(),
    ),
  );
}

class NebulaApp extends StatelessWidget {
  const NebulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nebula Dev',
      debugShowCheckedModeBanner: true, // Show debug banner in dev
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
