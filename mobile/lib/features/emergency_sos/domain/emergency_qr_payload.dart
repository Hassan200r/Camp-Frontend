import '../../garage/domain/bike_model.dart';

/// Result object holding the formatted QR text payload,
/// truncation status, and length metrics.
class EmergencyQrPayloadResult {
  const EmergencyQrPayloadResult({
    required this.payload,
    required this.isNotesTruncated,
    required this.totalLength,
    required this.maxLength,
    this.bikeLine,
  });

  /// The formatted plain-text payload encoded into the QR code.
  final String payload;

  /// Whether the medical notes field was shortened to remain within maxLength.
  final bool isNotesTruncated;

  /// The resulting character length of the payload.
  final int totalLength;

  /// The maximum permitted character length.
  final int maxLength;

  /// The exact line representing the active motorcycle, if included.
  final String? bikeLine;

  @override
  String toString() => payload;
}

class EmergencyQrPayloadBuilder {
  EmergencyQrPayloadBuilder._();

  /// Default ceiling on the QR payload character length to maintain high
  /// optical readability across mobile cameras and low-light field conditions.
  static const int defaultMaxLength = 295;

  /// Builds the emergency QR payload according to CAMP specifications.
  ///
  /// Requirements:
  /// - Format:
  ///   `CAMP EMERGENCY MEDICAL ID`
  ///   `Name: <fullName>`
  ///   `Blood Type: <bloodGroup>`
  ///   `Allergies: <allergies>`
  ///   `Medical Notes: <medicalNotes>`
  ///   `ICE Contact: <emergencyContactName> (<emergencyContactRelation>) - <emergencyContactPhone>`
  ///   `Bike: <make model>, <plate>`
  /// - If [includeBike] is true and [bike] != null, the bike line is added.
  ///   If bike has no plate, format is `Bike: <make model>`.
  /// - If [includeBike] is false or [bike] == null, the bike line is omitted.
  /// - If total payload exceeds [maxLength], [medicalNotes] is shortened first,
  ///   and [EmergencyQrPayloadResult.isNotesTruncated] is set to true.
  static EmergencyQrPayloadResult build({
    required String fullName,
    required String bloodGroup,
    required String allergies,
    required String medicalNotes,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String emergencyContactRelation,
    Bike? bike,
    bool includeBike = true,
    int maxLength = defaultMaxLength,
  }) {
    final cleanName =
        fullName.trim().isNotEmpty ? fullName.trim() : 'Motorcycle Rider';
    final cleanBlood =
        bloodGroup.trim().isNotEmpty ? bloodGroup.trim() : 'Not set';
    final cleanAllergies =
        allergies.trim().isNotEmpty ? allergies.trim() : 'None';
    final cleanNotes = medicalNotes.trim();

    String iceContactStr = '';
    final cName = emergencyContactName.trim();
    final cPhone = emergencyContactPhone.trim();
    final cRel = emergencyContactRelation.trim();
    if (cName.isNotEmpty && cPhone.isNotEmpty) {
      iceContactStr =
          cRel.isNotEmpty ? '$cName ($cRel) - $cPhone' : '$cName - $cPhone';
    } else if (cName.isNotEmpty) {
      iceContactStr = cRel.isNotEmpty ? '$cName ($cRel)' : cName;
    } else if (cPhone.isNotEmpty) {
      iceContactStr = cPhone;
    } else {
      iceContactStr = 'Not set';
    }

    String? bikeLine;
    if (includeBike && bike != null) {
      final makeModel = '${bike.make.trim()} ${bike.modelName.trim()}'.trim();
      final plate = bike.plateNumber?.trim();
      if (plate != null && plate.isNotEmpty) {
        bikeLine = 'Bike: $makeModel, $plate';
      } else {
        bikeLine = 'Bike: $makeModel';
      }
    }

    String assemble(String notes) {
      final buffer = StringBuffer();
      buffer.writeln('CAMP EMERGENCY MEDICAL ID');
      buffer.writeln('Name: $cleanName');
      buffer.writeln('Blood Type: $cleanBlood');
      buffer.writeln('Allergies: $cleanAllergies');
      buffer.writeln('Medical Notes: ${notes.isNotEmpty ? notes : 'None'}');
      buffer.write('ICE Contact: $iceContactStr');
      if (bikeLine != null) {
        buffer.write('\n$bikeLine');
      }
      return buffer.toString();
    }

    final initialPayload = assemble(cleanNotes);
    if (initialPayload.length <= maxLength) {
      return EmergencyQrPayloadResult(
        payload: initialPayload,
        isNotesTruncated: false,
        totalLength: initialPayload.length,
        maxLength: maxLength,
        bikeLine: bikeLine,
      );
    }

    // Shorten medical notes first
    bool isTruncated = false;
    String effectiveNotes = cleanNotes;
    final excess = initialPayload.length - maxLength;

    if (cleanNotes.isNotEmpty) {
      isTruncated = true;
      final targetLength = cleanNotes.length - excess;
      if (targetLength > 3) {
        effectiveNotes =
            '${cleanNotes.substring(0, targetLength - 3).trimRight()}...';
      } else {
        effectiveNotes = '';
      }
    }

    var truncatedPayload = assemble(effectiveNotes);

    // If still exceeding after removing notes, truncate payload directly
    if (truncatedPayload.length > maxLength) {
      isTruncated = true;
      truncatedPayload = truncatedPayload.substring(0, maxLength);
    }

    return EmergencyQrPayloadResult(
      payload: truncatedPayload,
      isNotesTruncated: isTruncated,
      totalLength: truncatedPayload.length,
      maxLength: maxLength,
      bikeLine: bikeLine,
    );
  }
}
