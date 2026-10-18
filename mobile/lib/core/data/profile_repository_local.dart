import '../../features/dashboard/domain/user_profile_model.dart';
import '../storage/local_store.dart';
import 'profile_repository.dart';

class ProfileRepositoryLocal implements ProfileRepository {
  ProfileRepositoryLocal([LocalStore? store]) : _explicitStore = store;

  final LocalStore? _explicitStore;
  LocalStore get _store => _explicitStore ?? LocalStore.instance;

  @override
  Future<UserProfile?> loadProfile() async {
    final json = await _store.readJson(LocalStore.keyProfile);
    if (json is! Map) {
      return null;
    }
    final map = json is Map<String, dynamic> ? json : json.cast<String, dynamic>();
    final profile = UserProfile.fromJson(map);
    // If id was generated or dates were missing, re-save to ensure migrated state is persisted.
    final hasGeneratedId = (map['id'] == null || (map['id'] as String).isEmpty);
    final hasMissingDates = map['createdAt'] == null || map['updatedAt'] == null;
    if (hasGeneratedId || hasMissingDates) {
      await saveProfile(profile);
    }
    return profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final updated = profile.copyWith(
      id: profile.effectiveId,
      updatedAt: DateTime.now().toUtc(),
      createdAt: profile.effectiveCreatedAt,
    );
    await _store.writeJson(LocalStore.keyProfile, updated.toJson());
  }

  @override
  Future<void> deleteProfile() async {
    await _store.writeJson(LocalStore.keyProfile, null);
    await _store.writeJson(LocalStore.keyProfilePhotoPath, null);
  }

  @override
  Future<String?> loadProfilePhotoPath() async {
    final data = await _store.readJson(LocalStore.keyProfilePhotoPath);
    if (data is String) return data;
    if (data is Map<String, dynamic> && data['path'] is String) {
      return data['path'] as String;
    }
    return null;
  }

  @override
  Future<void> saveProfilePhotoPath(String? path) async {
    await _store.writeJson(LocalStore.keyProfilePhotoPath, path);
  }

  @override
  Future<void> flush() async {
    await _store.flush();
  }
}

ProfileRepository resolveProfileRepository(dynamic source, [ProfileRepository? fallback]) {
  if (source is ProfileRepository) return source;
  if (source is LocalStore) return ProfileRepositoryLocal(source);
  return fallback ?? ProfileRepositoryLocal();
}
