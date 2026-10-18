import '../storage/local_store.dart';
import 'bike_repository.dart';
import 'bike_repository_local.dart';
import 'finance_repository.dart';
import 'finance_repository_local.dart';
import 'maintenance_repository.dart';
import 'maintenance_repository_local.dart';
import 'mechanic_repository.dart';
import 'mechanic_repository_local.dart';
import 'place_repository.dart';
import 'place_repository_local.dart';
import 'profile_repository.dart';
import 'profile_repository_local.dart';
import 'ride_report_repository.dart';
import 'ride_report_repository_local.dart';
import 'settings_repository.dart';
import 'settings_repository_local.dart';

/// Central container for all app repositories.
/// Built in [main.dart] using local repositories, and swappable for tests.
class AppRepositories {
  AppRepositories({
    ProfileRepository? profileRepository,
    BikeRepository? bikeRepository,
    MechanicRepository? mechanicRepository,
    RideReportRepository? rideReportRepository,
    SettingsRepository? settingsRepository,
    MaintenanceRepository? maintenanceRepository,
    FinanceRepository? financeRepository,
    PlaceRepository? placeRepository,
  })  : profileRepository = profileRepository ?? ProfileRepositoryLocal(),
        bikeRepository = bikeRepository ?? BikeRepositoryLocal(),
        mechanicRepository = mechanicRepository ?? MechanicRepositoryLocal(),
        rideReportRepository = rideReportRepository ?? RideReportRepositoryLocal(),
        settingsRepository = settingsRepository ?? SettingsRepositoryLocal(),
        maintenanceRepository = maintenanceRepository ?? MaintenanceRepositoryLocal(),
        financeRepository = financeRepository ?? FinanceRepositoryLocal(),
        placeRepository = placeRepository ?? PlaceRepositoryLocal();

  static AppRepositories instance = AppRepositories();

  final ProfileRepository profileRepository;
  final BikeRepository bikeRepository;
  final MechanicRepository mechanicRepository;
  final RideReportRepository rideReportRepository;
  final SettingsRepository settingsRepository;
  final MaintenanceRepository maintenanceRepository;
  final FinanceRepository financeRepository;
  final PlaceRepository placeRepository;

  /// Initialize persistent storage backing the repositories.
  Future<void> init() async {
    await LocalStore.instance.init();
  }

  /// Flush pending writes to disk across all repositories.
  Future<void> flush() async {
    await LocalStore.instance.flush();
  }

  static void resetWith({
    ProfileRepository? profileRepository,
    BikeRepository? bikeRepository,
    MechanicRepository? mechanicRepository,
    RideReportRepository? rideReportRepository,
    SettingsRepository? settingsRepository,
    MaintenanceRepository? maintenanceRepository,
    FinanceRepository? financeRepository,
    PlaceRepository? placeRepository,
  }) {
    instance = AppRepositories(
      profileRepository: profileRepository,
      bikeRepository: bikeRepository,
      mechanicRepository: mechanicRepository,
      rideReportRepository: rideReportRepository,
      settingsRepository: settingsRepository,
      maintenanceRepository: maintenanceRepository,
      financeRepository: financeRepository,
      placeRepository: placeRepository,
    );
  }

  static void resetToDefault() {
    instance = AppRepositories();
  }
}
