import 'package:camp/features/ride_history/presentation/screens/ride_history_screen.dart';
import 'package:camp/features/ride_history/presentation/widgets/ride_filter_chips_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RideFilterChipsWidget has All Rides 24 selected by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RideFilterChipsWidget())),
    );
    await tester.pumpAndSettle();

    // Verify "All Rides" and count "24" are present
    expect(find.text('All Rides'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Passes'), findsOneWidget);
    expect(find.text('Rally Tracks'), findsOneWidget);
    expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);
  });

  testWidgets(
    'RideHistoryScreen renders completely without overflow at 360px width',
    (WidgetTester tester) async {
      FlutterError.onError = (FlutterErrorDetails details) {
        // ignore: avoid_print
        print('FLUTTER_ERROR: ${details.exceptionAsString()}\n'
            '${details.summary}\n'
            '${details.informationCollector?.call().map((d) => d.toString()).join("\n")}');
      };
      // 360px width test (standard small Android device width)
      tester.view.physicalSize = const Size(360 * 2, 2400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: RideHistoryScreen()));
      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.text('EXPEDITION TELEMETRY ARCHIVE'), findsOneWidget);
      expect(find.text('Ride History'), findsOneWidget);
      expect(find.text('24 Logged'), findsOneWidget);

      // Verify filter chips
      expect(find.text('All Rides'), findsOneWidget);
      expect(find.text('Passes'), findsOneWidget);
      expect(find.text('Rally Tracks'), findsOneWidget);

      // Verify season summary
      expect(find.text('SEASON 2024 SUMMARY'), findsOneWidget);
      expect(find.text('BMW GS #441 • KTM 890'), findsOneWidget);
      expect(find.text('100% Synced'), findsOneWidget);

      // Verify latest expedition card
      expect(find.text('LATEST EXPEDITION'), findsOneWidget);
      expect(find.text('Babusar Pass Summit & Alpine Ridge'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      // Verify cards
      expect(find.text('Karakoram High-Altitude Corridor'), findsOneWidget);
      expect(
        find.text('Makran Coastal Highway & Mud Volcanoes'),
        findsOneWidget,
      );
      expect(find.text('Cholistan Desert Sand Nav Loop'), findsOneWidget);

      // Ensure no overflow errors occurred
      final err = tester.takeException();
      if (err != null) {
        debugPrint('OVERFLOW ERROR: $err');
        if (err is FlutterError) {
          for (final detail in err.diagnostics) {
            debugPrint('DIAGNOSTIC: ${detail.toString()}');
          }
        }
      }
      expect(err, isNull);
    },
  );

  testWidgets(
    'Latest expedition options menu is closed by default and opens compact menu on tap',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: RideHistoryScreen()));
      await tester.pumpAndSettle();

      // Menu options are NOT present when closed
      expect(find.text('Export GPX'), findsNothing);
      expect(find.text('Hide from Archive'), findsNothing);

      // Tap the '...' popup menu button
      final moreButton = find.byIcon(Icons.more_horiz_rounded);
      expect(moreButton, findsOneWidget);
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Menu is now visible as compact dropdown with crossed-out icon
      expect(find.text('Export GPX'), findsOneWidget);
      expect(find.text('Share Ride'), findsOneWidget);
      expect(find.text('Hide from Archive'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap hide option
      await tester.tap(find.text('Hide from Archive'));
      await tester.pumpAndSettle();

      // Popup closed
      expect(find.text('Hide from Archive'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
