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
  });

  factory PostRideReport.fromJson(Map<String, dynamic> json) {
    return PostRideReport(
      id: json['id'] as String,
      bikeId: json['bikeId'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
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
  }) {
    return PostRideReport(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      distanceKm: distanceKm ?? this.distanceKm,
      terrainTags: terrainTags ?? this.terrainTags,
      notes: notes ?? this.notes,
      flaggedIssues: flaggedIssues ?? this.flaggedIssues,
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
        'bikeId': bikeId,
        'date': date.toIso8601String(),
        'distanceKm': distanceKm,
        'terrainTags': terrainTags,
        'notes': notes,
        'flaggedIssues': flaggedIssues,
      };
}
