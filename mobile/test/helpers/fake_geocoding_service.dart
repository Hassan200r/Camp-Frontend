import 'package:camp/features/navigation/domain/geocoding_service.dart';
import 'package:latlong2/latlong.dart';

/// Fake implementation of [GeocodingService] for testing.
class FakeGeocodingService implements GeocodingService {
  FakeGeocodingService({
    this.searchResults,
    this.reverseResult,
  });

  List<PlaceSearchResult>? searchResults;
  PlaceSearchResult? reverseResult;

  @override
  Future<List<PlaceSearchResult>> search(String query) async {
    if (searchResults != null) return searchResults!;
    return [
      PlaceSearchResult(
        name: query,
        displayName: '$query, Test Region',
        location: const LatLng(35.0, 74.0),
      ),
    ];
  }

  @override
  Future<PlaceSearchResult?> reverseGeocode(LatLng location) async {
    return reverseResult ??
        PlaceSearchResult(
          name: 'Current Locus',
          displayName: 'Current Locus, Mountain Pass',
          location: location,
        );
  }
}
