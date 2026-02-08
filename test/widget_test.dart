import 'package:flutter_test/flutter_test.dart';
import 'package:nebula_client/main.dart';

void main() {
  testWidgets('Nebula app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NebulaApp());
    expect(find.text('Nebula'), findsOneWidget);
  });
}
