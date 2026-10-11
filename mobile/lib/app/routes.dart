/// Central route-name constants for the CAMP application.
abstract final class CampRoutes {
  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String login = '/login';
  static const String auth = '/auth';
  static const String signUp = '/sign-up';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String addBike = '/add-bike';
  static const String addMotorcycle = '/add-motorcycle';
  static const String addBikeUnderscore = '/add_bike';
  static const String addMotorcycleUnderscore = '/add_motorcycle';

  static const String bikeDetails = '/bike-details';
  static const String bikeScan = '/bike-scan';
  static const String bikeProfile = '/bike-profile';
  static const String garage = '/garage';

  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static const String mechanics = '/mechanics';
  static const String mechanicsAdd = '/mechanics/add';
  static const String addMechanic = '/add-mechanic';

  static const String navigationMap = '/navigation/map';
  static const String voiceCopilot = '/voice-copilot';
  static const String voiceAssistant = '/voice-assistant';

  static const String routePacks = '/route-packs';
  static const String rideHistory = '/ride-history';
  static const String financeRigHealth = '/finance-rig-health';
  static const String financesRigHealth = '/finances-rig-health';
  static const String maintenance = '/maintenance';
  static const String predictiveMaintenance = '/predictive-maintenance';
  static const String carburetorTuning = '/carburetor-tuning';
  static const String settings = '/settings';
  static const String emergencySos = '/emergency-sos';

  // Legacy route aliases
  // TODO: Legacy route aliases — kept for temporary backward compatibility during team branch merges. Remove once confirmed unused across all teammate branches.
  static const String legacyMechanicsMap = '/mechanics/map';
  static const String legacyMechanicsVoiceAssistant = '/mechanics/voice-assistant';
}
