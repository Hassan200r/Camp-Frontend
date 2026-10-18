import '../../features/navigation/domain/geocoding_service.dart';
import '../storage/local_store.dart';
import 'place_repository.dart';

class PlaceRepositoryLocal implements PlaceRepository {
  PlaceRepositoryLocal([LocalStore? store]) : _explicitStore = store;

  final LocalStore? _explicitStore;
  LocalStore get _store => _explicitStore ?? LocalStore.instance;

  @override
  Future<List<PlaceSearchResult>> loadSavedPlaces() async {
    final json = await _store.readJson(LocalStore.keySavedPlaces);
    if (json is! List) {
      return [];
    }

    bool needsMigration = false;
    final places = <PlaceSearchResult>[];

    for (int i = 0; i < json.length; i++) {
      final raw = json[i];
      if (raw is Map) {
        final map = raw is Map<String, dynamic> ? raw : raw.cast<String, dynamic>();
        final place = PlaceSearchResult.fromJson(map);
        if (place.id.isEmpty || map['id'] == null || (map['id'] as String).isEmpty) {
          needsMigration = true;
          places.add(place.copyWith(id: 'place_${DateTime.now().millisecondsSinceEpoch}_$i'));
        } else {
          if (map['createdAt'] == null || map['updatedAt'] == null) {
            needsMigration = true;
          }
          places.add(place);
        }
      }
    }

    if (needsMigration) {
      await saveSavedPlaces(places);
    }

    return places;
  }

  @override
  Future<void> saveSavedPlaces(List<PlaceSearchResult> places) async {
    final now = DateTime.now().toUtc();
    final updated = places.map((p) {
      return p.copyWith(
        id: p.effectiveId,
        createdAt: p.effectiveCreatedAt,
        updatedAt: now,
      );
    }).toList();

    await _store.writeJson(
      LocalStore.keySavedPlaces,
      updated.map((p) => p.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteSavedPlace(String id) async {
    final current = await loadSavedPlaces();
    final filtered = current.where((p) => p.effectiveId != id).toList();
    await saveSavedPlaces(filtered);
  }

  @override
  Future<List<PlaceSearchResult>> loadRecentPlaces() async {
    final json = await _store.readJson(LocalStore.keyRecentPlaces);
    if (json is! List) {
      return [];
    }

    bool needsMigration = false;
    final places = <PlaceSearchResult>[];

    for (int i = 0; i < json.length; i++) {
      final raw = json[i];
      if (raw is Map) {
        final map = raw is Map<String, dynamic> ? raw : raw.cast<String, dynamic>();
        final place = PlaceSearchResult.fromJson(map);
        if (place.id.isEmpty || map['id'] == null || (map['id'] as String).isEmpty) {
          needsMigration = true;
          places.add(place.copyWith(id: 'recent_${DateTime.now().millisecondsSinceEpoch}_$i'));
        } else {
          if (map['createdAt'] == null || map['updatedAt'] == null) {
            needsMigration = true;
          }
          places.add(place);
        }
      }
    }

    if (needsMigration) {
      await saveRecentPlaces(places);
    }

    return places;
  }

  @override
  Future<void> saveRecentPlaces(List<PlaceSearchResult> places) async {
    final now = DateTime.now().toUtc();
    final updated = places.map((p) {
      return p.copyWith(
        id: p.effectiveId,
        createdAt: p.effectiveCreatedAt,
        updatedAt: now,
      );
    }).toList();

    await _store.writeJson(
      LocalStore.keyRecentPlaces,
      updated.map((p) => p.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteRecentPlace(String id) async {
    final current = await loadRecentPlaces();
    final filtered = current.where((p) => p.effectiveId != id).toList();
    await saveRecentPlaces(filtered);
  }

  @override
  Future<void> clear() async {
    await _store.writeJson(LocalStore.keySavedPlaces, null);
    await _store.writeJson(LocalStore.keyRecentPlaces, null);
  }

  @override
  Future<void> flush() async {
    await _store.flush();
  }
}

PlaceRepository resolvePlaceRepository(dynamic source, [PlaceRepository? fallback]) {
  if (source is PlaceRepository) return source;
  if (source is LocalStore) return PlaceRepositoryLocal(source);
  return fallback ?? PlaceRepositoryLocal();
}
