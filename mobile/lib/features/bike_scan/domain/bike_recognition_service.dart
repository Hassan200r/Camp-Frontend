import 'dart:io';

/// Confidence level for a bike recognition result.
enum RecognitionConfidence { high, medium, low }

/// Result returned by a [BikeRecognitionService] implementation.
class BikeRecognitionResult {
  const BikeRecognitionResult({
    required this.make,
    required this.model,
    required this.confidence,
    this.year,
    this.displacementCc,
    this.bikeType,
    this.fuelTankLiters,
  });

  final String make;
  final String model;
  final RecognitionConfidence confidence;

  /// Optional year — only include when the classifier is highly confident.
  final int? year;

  /// Engine displacement in cc, e.g. 1254.
  final int? displacementCc;

  /// Category, e.g. "Adventure", "Sport", "Commuter".
  final String? bikeType;

  /// Fuel tank size in litres.
  final double? fuelTankLiters;
}

/// Abstract interface for on-device or cloud-based bike image recognition.
///
/// Implementations:
///   - [MockBikeRecognitionService] — demo only, returns hard-coded data.
///   - (Future) TFLite on-device classifier — swap in [BikeRecognitionProvider].
abstract class BikeRecognitionService {
  const BikeRecognitionService();

  /// Attempts to identify the motorcycle in [image].
  ///
  /// Returns [BikeRecognitionResult] on success, or `null` if unrecognized.
  Future<BikeRecognitionResult?> identify(File image);
}
