import 'package:camp/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProfileScreen renders all sections matching reference screenshots in order',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('CAMP'), findsWidgets);
    expect(find.text('PROFILE'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // 2. Cockpit Hero Card
    expect(find.text('Elena Vance'), findsOneWidget);
    expect(find.text('ADV PRO'), findsOneWidget);
    expect(find.text('Cockpit Link Active • BMW R 1250 GS'), findsOneWidget);
    expect(find.text('ONLINE'), findsOneWidget);
    expect(find.text('08:42 AM'), findsOneWidget);
    expect(find.text('GPS Locked'), findsOneWidget);
    expect(find.text('Sunny 68°F - 4mph NW'), findsOneWidget);
    expect(find.text('Ready for the Ridge Pass?'), findsOneWidget);
    expect(find.text('Ideal riding conditions on Alpine Route 4'), findsOneWidget);
    expect(find.text('PASSPORT: CAMP-9942-GS'), findsOneWidget);
    expect(find.text('GARMIN INREACH SYNC'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);

    // 3. Stats Grid
    expect(find.text('LIFETIME DISTANCE'), findsOneWidget);
    expect(find.text('14,820'), findsWidgets); // Used in stats and touring progress
    expect(find.text('PASSES & REGIONS'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('SADDLE TIME'), findsOneWidget);
    expect(find.text('124'), findsOneWidget);
    expect(find.text('LONGEST SINGLE DAY'), findsOneWidget);
    expect(find.text('780'), findsOneWidget);

    // 4. Touring Tier Progress
    expect(find.text('TOURING TIER PROGRESS'), findsOneWidget);
    expect(find.text('Level 4: Master Explorer'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);

    // 5. Earned Trail Badges
    expect(find.text('EARNED TRAIL BADGES'), findsOneWidget);
    expect(find.text('Alps Explorer'), findsOneWidget);
    expect(find.text('Iron Butt 1000k'), findsOneWidget);
    expect(find.text('Sand Dune Master'), findsOneWidget);
    expect(find.text('Babusar Summit'), findsOneWidget);
    expect(find.text('Off-Grid'), findsOneWidget);

    // 6. My Garage
    expect(find.text('MY GARAGE'), findsOneWidget);
    expect(find.text('Recognize bike with camera'), findsOneWidget);
    expect(find.text('BMW R 1250 GS Adv'), findsWidgets);
    expect(find.text('Honda Rebel 500'), findsOneWidget);

    // Scroll down to reveal lower sections
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();

    // 7. Maintenance Health Card
    expect(find.text('MAINTENANCE HEALTH'), findsOneWidget);
    expect(find.text('Telemetry Monitored'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('Top At-Risk Components'), findsOneWidget);
    expect(find.text('Drive Chain & Sprocket'), findsOneWidget);
    expect(find.text('Front Brake Pads'), findsOneWidget);
    expect(find.text('View Full Report'), findsOneWidget);

    // 8. Recent Trips
    expect(find.text('RECENT TRIPS'), findsOneWidget);
    expect(find.text('Babusar Pass Summit & Alpine Ridge'), findsOneWidget);
    expect(find.text('Karakoram High-Altitude Corridor'), findsOneWidget);
    expect(find.text('Cholistan Desert Sand Nav Loop'), findsOneWidget);

    // Scroll to the very bottom
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();

    // 9. Rider Medical & SOS ID Card
    expect(find.text('RIDER MEDICAL & SOS ID'), findsOneWidget);
    expect(find.text('Telemetry Armed'), findsOneWidget);
    expect(find.text('Emergency ICE:'), findsOneWidget);
    expect(find.text('Blood & Allergies:'), findsOneWidget);
    expect(find.text('Satellite SOS Beacon:'), findsOneWidget);
    expect(find.text('View Emergency Protocols & Health Card'), findsOneWidget);

    // 10. Settings List Card
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Edit Personal Info'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Offline Maps'), findsOneWidget);
    expect(find.text('Privacy & Telemetry Sharing'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('About CAMP'), findsOneWidget);

    // 11. Log Out Button fully visible and rendered
    expect(find.text('Log Out'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });
}
