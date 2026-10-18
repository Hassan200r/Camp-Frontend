import '../../features/dashboard/domain/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> deleteProfile();
  Future<String?> loadProfilePhotoPath();
  Future<void> saveProfilePhotoPath(String? path);
  Future<void> flush();
}
