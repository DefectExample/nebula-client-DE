import 'package:flutter_test/flutter_test.dart';
import 'package:nebula_client/app_bootstrap.dart';
import 'package:nebula_client/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Nebula app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev()),
        ],
        child: const NebulaApp(),
      ),
    );
    expect(find.text('Nebula'), findsOneWidget);
  });
}
