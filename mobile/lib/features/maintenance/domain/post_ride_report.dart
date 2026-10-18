import 'package:flutter/foundation.dart';

/// Domain model representing a user-logged post-ride debrief.
/// Used to compute real-world wear multipliers and ride pattern insights.
@immutable
class PostRideReport {
  const PostRideReport({
    required this.id,
    required this.bikeId,
    required this.date,
    required this.distanceKm,
    required this.terrainTags,
    this.notes,
    this.flaggedIssues,
    this.createdAt,
    this.updatedAt,
  });

  factory PostRideReport.fromJson(Map<String, dynamic> json) {
    DateTime? parseUtc(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toUtc();
      return null;
    }

    final rawId = json['id'] as String?;
    final effectiveId = (rawId != null && rawId.trim().isNotEmpty)
        ? rawId.trim()
        : 'report-${DateTime.now().millisecondsSinceEpoch}';

    final reportDate =
        DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now();
    final createdUtc = parseUtc(json['createdAt']) ?? reportDate.toUtc();
    final updatedUtc = parseUtc(json['updatedAt']) ?? createdUtc;

    return PostRideReport(
      id: effectiveId,
      createdAt: createdUtc,
      updatedAt: updatedUtc,
      bikeId: json['bikeId'] as String? ?? 'unknown-bike',
      date: reportDate,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      terrainTags: (json['terrainTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      flaggedIssues: json['flaggedIssues'] as String?,
    );
  }

  /// Unique identifier for this report log.
  final String id;

  String get effectiveId => id;

  /// Timestamp when report was created (UTC).
  final DateTime? createdAt;

  /// Timestamp when report was last updated (UTC).
  final DateTime? updatedAt;

  DateTime get effectiveCreatedAt => createdAt?.toUtc() ?? date.toUtc();
  DateTime get effectiveUpdatedAt => updatedAt?.toUtc() ?? effectiveCreatedAt;

  /// Identifier of the bike used on the expedition.
  final String bikeId;

  /// Date and time when the ride took place.
  final DateTime date;

  /// Distance covered during the ride in kilometers.
  final double distanceKm;

  /// Terrain classifications encountered (e.g., 'City', 'Highway', 'Off-road', 'Mountain').
  final List<String> terrainTags;

  /// General rider notes or trail observations.
  final String? notes;

  /// Optional specific mechanical symptoms or issues flagged during ride.
  final String? flaggedIssues;

  /// Convenience getter for combined notes or flagged issues.
  String? get combinedNotes {
    if (notes != null && notes!.isNotEmpty && flaggedIssues != null && flaggedIssues!.isNotEmpty) {
      return '$notes ($flaggedIssues)';
    }
    return notes ?? flaggedIssues;
  }

  PostRideReport copyWith({
    String? id,
    String? bikeId,
    DateTime? date,
    double? distanceKm,
    List<String>? terrainTags,
    String? notes,
    String? flaggedIssues,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostRideReport(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      distanceKm: distanceKm ?? this.distanceKm,
      terrainTags: terrainTags ?? this.terrainTags,
      notes: notes ?? this.notes,
      flaggedIssues: flaggedIssues ?? this.flaggedIssues,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostRideReport &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bikeId == other.bikeId &&
          date == other.date &&
          distanceKm == other.distanceKm &&
          listEquals(terrainTags, other.terrainTags) &&
          notes == other.notes &&
          flaggedIssues == other.flaggedIssues;

  @override
  int get hashCode => Object.hash(
        id,
        bikeId,
        date,
        distanceKm,
        Object.hashAll(terrainTags),
        notes,
        flaggedIssues,
      );

  @override
  String toString() =>
      'PostRideReport(id: $id, bike: $bikeId, dist: ${distanceKm}km, terrain: $terrainTags)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': effectiveCreatedAt.toIso8601String(),
        'updatedAt': effectiveUpdatedAt.toIso8601String(),
        'bikeId': bikeId,
        'date': date.toIso8601String(),
        'distanceKm': distanceKm,
        'terrainTags': terrainTags,
        'notes': notes,
        'flaggedIssues': flaggedIssues,
      };
}
