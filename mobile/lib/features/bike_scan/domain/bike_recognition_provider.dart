import 'bike_recognition_service.dart';
import 'mock_bike_recognition_service.dart';

/// Single point of truth for which [BikeRecognitionService] is active.
///
/// To swap in the real on-device TFLite classifier, replace the one line
/// below with your implementation class:
///
/// ```dart
/// static BikeRecognitionService get instance => TFLiteBikeRecognitionService();
/// ```
///
/// No other file needs to change.
class BikeRecognitionProvider {
  BikeRecognitionProvider._();

  // ── ⬇ Swap this one line to use the real classifier ──────────────────────
  static BikeRecognitionService get instance =>
      const MockBikeRecognitionService();
  // ─────────────────────────────────────────────────────────────────────────
}
