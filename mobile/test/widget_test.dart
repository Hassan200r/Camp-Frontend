import 'package:camp/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CAMP Explore Home smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampApp());

    // Verify key elements from the initial screen exist
    expect(find.text('CAMP'), findsWidgets);
  });
}
