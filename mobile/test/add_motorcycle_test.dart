import 'package:camp/features/bike_scan/presentation/screens/add_motorcycle_screen.dart';
import 'package:camp/features/bike_scan/presentation/screens/bike_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AddMotorcycleScreen renders all step 1 components and cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/add-bike',
        routes: {
          '/add-bike': (context) => const AddMotorcycleScreen(),
          '/bike-scan': (context) => const BikeScanScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('CAMP'), findsOneWidget);
    expect(find.text('ADD BIKE'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // Verify Progress Row
    expect(find.text('STEP 1 OF 4'), findsOneWidget);

    // Verify Title & Subtitle
    expect(find.text('Add a Motorcycle'), findsOneWidget);
    expect(
      find.text(
        'Choose how you would like to register your bike into the telemetry system.',
      ),
      findsOneWidget,
    );

    // Verify Option 1: Scan with Camera + RECOMMENDED Badge
    expect(find.text('Scan with Camera'), findsOneWidget);
    expect(find.text('RECOMMENDED'), findsOneWidget);
    expect(
      find.text('Instant VIN, ODO & telemetry recognition via CAMP AI Vision.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

    // Verify Option 2: Upload Photo
    expect(find.text('Upload Photo'), findsOneWidget);
    expect(
      find.text(
        'Analyze an existing photo or registration document from your mobile device gallery.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);

    // Verify Option 3: Enter Manually
    expect(find.text('Enter Manually'), findsOneWidget);
    expect(
      find.text(
        'Fill in make, model, displacement, specs, and maintenance logs step-by-step.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);

    // Verify Info Banner
    expect(
      find.text(
        'Have your steering stem VIN plate or registration card accessible for 1-tap recognition.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });

  testWidgets('Tapping Scan with Camera navigates to BikeScanScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/add-bike',
        routes: {
          '/add-bike': (context) => const AddMotorcycleScreen(),
          '/bike-scan': (context) => const BikeScanScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap Scan with Camera card
    final scanCard = find.text('Scan with Camera');
    expect(scanCard, findsOneWidget);
    await tester.tap(scanCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify BikeScanScreen reached
    expect(find.text('TELEMETRY VISION 4.2'), findsOneWidget);
  });

  testWidgets('Tapping Upload Photo handles picker gracefully and Enter Manually shows toast',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/add-bike',
        routes: {
          '/add-bike': (context) => const AddMotorcycleScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap Upload Photo (in test env without mock picker, completes gracefully without crash)
    await tester.tap(find.text('Upload Photo'));
    await tester.pump();
    expect(find.text('Add a Motorcycle'), findsOneWidget);

    // Tap Enter Manually
    await tester.tap(find.text('Enter Manually'));
    await tester.pump();
    expect(
      find.text('Manual vehicle entry wizard coming soon'),
      findsOneWidget,
    );
  });
}
