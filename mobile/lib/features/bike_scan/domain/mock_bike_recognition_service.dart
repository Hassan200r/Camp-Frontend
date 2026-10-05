import 'dart:io';

import 'bike_recognition_service.dart';

/// DEMO-ONLY implementation of [BikeRecognitionService].
///
/// Returns a hard-coded BMW R 1250 GS result for any image supplied.
///
/// ⚠️  Replace this with the on-device TFLite classifier in
///     [BikeRecognitionProvider] when the real model is ready.
class MockBikeRecognitionService extends BikeRecognitionService {
  const MockBikeRecognitionService();

  @override
  Future<BikeRecognitionResult?> identify(File image) async {
    // Simulate a short analysis delay (no real ML inference).
    await Future<void>.delayed(const Duration(seconds: 2));

    return const BikeRecognitionResult(
      make: 'BMW',
      model: 'R 1250 GS',
      confidence: RecognitionConfidence.high,
      // NOTE: year is intentionally omitted — we cannot determine it from a
      // side-view photo alone.  The form will leave year at its default.
      displacementCc: 1254,
      bikeType: 'Adventure',
      fuelTankLiters: 20.0,
    );
  }
}
