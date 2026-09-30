import 'package:camp/features/navigation/presentation/screens/route_packs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'RoutePacksScreen renders all components cleanly without overflow at 360px width',
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

      await tester.pumpWidget(const MaterialApp(home: RoutePacksScreen()));
      await tester.pumpAndSettle();

      // 1. Header elements
      expect(find.text('CAMP'), findsOneWidget);
      expect(find.text('GPS LIVE'), findsOneWidget);

      // 2. Title row elements
      expect(find.text('TELEMETRY HUB'), findsOneWidget);
      expect(find.text('Route Packs'), findsOneWidget);
      expect(find.text('Topo V4.8'), findsOneWidget);

      // 3. Storage Allocation card elements
      expect(find.text('3.4 GB'), findsOneWidget);
      expect(find.text('used of 32 GB Free'), findsOneWidget);
      expect(find.text('Routes (2.2 GB)'), findsOneWidget);
      expect(find.text('Topo Base (1.2 GB)'), findsOneWidget);
      expect(find.text('Free (28.6 GB)'), findsOneWidget);
      expect(find.text('Auto-update topo via Wi-Fi'), findsOneWidget);

      // 4. Section header elements
      expect(find.text('OFFLINE TELEMETRY & TOPO PACKS'), findsOneWidget);
      expect(find.text('5 Regions Available'), findsOneWidget);

      // 5. Pack cards
      expect(find.text('Karakoram Highway (KKH)'), findsOneWidget);
      expect(find.text('840 MB • Full Topo & Satellite'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Pack update available (42 MB)'), findsOneWidget);
      expect(find.text('Sync Update'), findsOneWidget);

      expect(find.text('Babusar Pass & Kaghan'), findsOneWidget);
      expect(find.text('460 MB • Alpine Passes'), findsOneWidget);
      expect(find.text('68% DOWNLOADING'), findsOneWidget);
      expect(find.text('312 MB of 460 MB'), findsOneWidget);
      expect(find.text('4.2 MB/s'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);

      expect(find.text('Makran Coastal Highway'), findsOneWidget);
      expect(find.text('380 MB • Desert & Coastal Trail'), findsOneWidget);
      expect(find.text('Zero-cell desert sector'), findsOneWidget);
      expect(find.text('Download Pack (380 MB)'), findsOneWidget);

      expect(find.text('Cholistan Desert Rally Route'), findsOneWidget);
      expect(find.text('520 MB • Deep Sand & Navigational Grid'), findsOneWidget);
      expect(find.text('GPS Mesh verified'), findsOneWidget);
      expect(find.text('Download Pack (520 MB)'), findsOneWidget);

      expect(find.text('Deosai Plains Plateau'), findsOneWidget);
      expect(find.text('290 MB • High Altitude Wilderness'), findsOneWidget);
      expect(find.text('Contour 10m res'), findsOneWidget);
      expect(find.text('Download Pack (290 MB)'), findsOneWidget);

      // Ensure no overflow errors occurred
      final err = tester.takeException();
      expect(err, isNull);
    },
  );
}
