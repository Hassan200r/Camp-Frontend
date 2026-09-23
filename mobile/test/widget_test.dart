import 'package:camp/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CAMP Explore Home smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampApp());

    // Verify key elements from the Explore Home screen exist
    expect(find.text('CAMP'), findsOneWidget);
    expect(find.text('BMW R1250 GS Adventure'), findsOneWidget);
    expect(find.text('Elena Vance'), findsOneWidget);
    expect(find.text('Recent Updates'), findsOneWidget);
  });
}
