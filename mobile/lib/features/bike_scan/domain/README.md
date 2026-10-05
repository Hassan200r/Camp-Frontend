# Bike Recognition Service

## Architecture

The recognition pipeline is built around `BikeRecognitionService`, an abstract interface in
`lib/features/bike_scan/domain/bike_recognition_service.dart`.

### How to swap in the real classifier

Open **`lib/features/bike_scan/domain/bike_recognition_provider.dart`** and change **one line**:

```dart
// Current (demo):
static BikeRecognitionService get instance => const MockBikeRecognitionService();

// Replace with (real TFLite model example):
static BikeRecognitionService get instance => const TFLiteBikeRecognitionService();
```

No other file needs to change.

---

## Current implementation: `MockBikeRecognitionService` (demo only)

**File:** `lib/features/bike_scan/domain/mock_bike_recognition_service.dart`

⚠️ **This is a demo implementation.** It always returns a fixed BMW R 1250 GS result after a
2-second delay. It does **not** perform any real image analysis.

Replace it with a real on-device TFLite classifier or a cloud API when available.

---

## `BikeRecognitionResult` fields

| Field | Type | Notes |
|---|---|---|
| `make` | `String` | e.g. `"BMW"` |
| `model` | `String` | e.g. `"R 1250 GS"` |
| `confidence` | `RecognitionConfidence` | `high`, `medium`, `low` |
| `year` | `int?` | Only set if classifier is highly confident |
| `displacementCc` | `int?` | Engine size in cc |
| `bikeType` | `String?` | e.g. `"Adventure"` |
| `fuelTankLiters` | `double?` | Tank size in litres |

If `confidence == low` or the result is `null`, the user sees the "not identified" banner and
the Bike Details form opens blank.

---

## Gallery picking

Reusable gallery-picker logic lives in:
`lib/features/bike_scan/utils/gallery_picker_helper.dart`

It is used by both `BikeScanScreen` and can be used by any future screen that needs gallery access.
