import 'package:flutter_test/flutter_test.dart';
import 'package:android/main.dart';

void main() {
  testWidgets('HealthBmiTrackerApp builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthBmiTrackerApp());
    expect(find.byType(HealthBmiTrackerApp), findsOneWidget);
  });
}
