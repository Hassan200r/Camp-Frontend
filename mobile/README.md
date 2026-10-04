# CAMP Mobile

CAMP Mobile is a Flutter rider cockpit for managing a motorcycle, checking live telemetry-style status, registering a new bike, managing garage fleets, navigating off-grid route packs, tracking predictive maintenance & trip finances, finding mechanics, hands-free voice assistance, emergency SOS dispatches, and managing rider settings. The current implementation features a tactical skeuomorphic theme with clay-style card containers, dynamic active bike synchronization, and reactive settings architecture.

## App Workflow & Feature Matrix

1. **Authentication & Access (`lib/features/auth/`)**
   - `SignInScreen` (`/sign-in`, `/login`, `/auth`): Secure rider authentication landing with field validation.
   - `SignUpScreen` (`/sign-up`, `/register`): New rider account creation.
   - `ForgotPasswordScreen` (`/forgot-password`): Password reset recovery flow.

2. **Launch & Navigation Dock (`lib/main.dart`)**
   - Main entry point initializing global singletons (`ActiveBikeController`, `SettingsController`) and registered application routes.
   - Central routing system with full support for legacy aliases.

3. **Explore Dashboard & Profile (`lib/features/dashboard/`)**
   - `HomeScreen` (`/`): Tactical cockpit landing page with live telemetry stats, AI voice copilot bar, active bike status, quick alerts, and bottom navigation dock (`CampBottomNav`).
   - `ProfileScreen` (`/profile`): Rider account overview with cockpit hero card, touring tier progress, earned trail badges, garage quick view, maintenance health summaries, recent trips, rider medical SOS ID, and a reactive **Settings card**.
   - `EditProfileScreen` (`/edit-profile`): Form for editing rider personal information and preferences.

4. **Add Motorcycle & Vision AI Scanner (`lib/features/bike_scan/`)**
   - `AddMotorcycleScreen` (`/add-bike`, `/add-motorcycle`): Registration hub with camera scanning, photo upload, and manual entry.
   - `BikeScanScreen` (`/bike-scan`): Camera VIN scanning sequence with HUD graphics, audio/flash controls, and simulated bike detection (BMW, Ducati, KTM).
   - `BikeDetailsScreen` (`/bike-details`): Multi-step bike spec editor with validation gating.

5. **Garage Fleet & Bike Profile (`lib/features/garage/`)**
   - `GarageScreen` (`/garage`): Active fleet manager with telemetry status, sync controls, and bike card list.
   - `BikeProfileScreen` (`/bike-profile`): Detailed motorcycle spec sheet, service history, and active bike selection controller (`ActiveBikeController`).

6. **Expedition Maintenance, Diagnostics & Finances (`lib/features/maintenance/`)**
   - `FinanceRigHealthScreen` (`/finance-rig-health`): Combined trip budget calculator (`TripBudgetCardWidget`) and component health telemetry tracker (`MaintenanceListWidget`).
   - `PredictiveMaintenanceScreen` (`/predictive-maintenance`): AI wear-and-tear tracking, service interval forecasting, and part replacement alerts.
   - `CarburetorTuningScreen` (`/carburetor-tuning`): Interactive diagnostic guide for jetting, mixture adjustment, and carb synchronization.

7. **Mechanics & Workshop Directory (`lib/features/mechanics/`)**
   - `MechanicsHomeScreen` (`/mechanics`): Directory and locator for nearby verified motorcycle workshops and mechanics.
   - `AddMechanicScreen` (`/mechanics/add`, `/add-mechanic`): Registration portal for workshop owners and specialist mechanics.

8. **Off-Grid Navigation & Route Packs (`lib/features/navigation/`)**
   - `NavigationMapScreen` (`/navigation/map`): Interactive turn-by-turn navigation map interface.
   - `RoutePacksScreen` (`/route-packs`): Offline route pack discovery, trail telemetry, and map pack manager.

9. **Trip History & Telemetry Logs (`lib/features/ride_history/`)**
   - `RideHistoryScreen` (`/ride-history`): Comprehensive log of past rides, trip telemetry, elevation metrics, and speed profiles.

10. **Voice Copilot AI Assistant (`lib/features/voice_copilot/`)**
    - `VoiceAssistantScreen` (`/voice-copilot`, `/voice-assistant`): Hands-free audio assistant for real-time rider voice queries, route inquiries, and system checks.

11. **Emergency SOS & Safety (`lib/features/emergency_sos/`)**
    - `EmergencySosScreen` (`/emergency-sos`): Rapid-response emergency dispatch UI with live location payload, emergency contact notifications, and medical profile details.

12. **Dedicated Settings Management (`lib/features/settings/`)**
    - `SettingsScreen` (`/settings`): Centralized hub for unit preference (Metric vs Imperial), notification alerts, cache clearing, and telemetry sharing.
    - `SettingsController`: Reactive singleton state manager for app preferences.

---

## 🗺️ Registered Routes Matrix (`lib/main.dart`)

| Route Path | Screen Component | Feature Area |
| :--- | :--- | :--- |
| `/` | `HomeScreen` | Dashboard / Cockpit |
| `/sign-in`, `/login`, `/auth` | `SignInScreen` | Authentication |
| `/sign-up`, `/register` | `SignUpScreen` | Authentication |
| `/forgot-password` | `ForgotPasswordScreen` | Authentication |
| `/profile` | `ProfileScreen` | User Profile |
| `/edit-profile` | `EditProfileScreen` | User Profile |
| `/add-bike`, `/add-motorcycle` | `AddMotorcycleScreen` | Bike Scanner |
| `/bike-scan` | `BikeScanScreen` | Bike Scanner |
| `/bike-details` | `BikeDetailsScreen` | Bike Scanner |
| `/garage` | `GarageScreen` | Garage Fleet |
| `/bike-profile` | `BikeProfileScreen` | Garage Fleet |
| `/mechanics` | `MechanicsHomeScreen` | Workshop Directory |
| `/mechanics/add`, `/add-mechanic` | `AddMechanicScreen` | Workshop Directory |
| `/navigation/map` | `NavigationMapScreen` | Navigation |
| `/route-packs` | `RoutePacksScreen` | Navigation |
| `/finance-rig-health` | `FinanceRigHealthScreen` | Maintenance & Budget |
| `/predictive-maintenance` | `PredictiveMaintenanceScreen` | Maintenance |
| `/carburetor-tuning` | `CarburetorTuningScreen` | Diagnostics |
| `/ride-history` | `RideHistoryScreen` | Trip Logs |
| `/voice-copilot`, `/voice-assistant` | `VoiceAssistantScreen` | Voice Assistant |
| `/emergency-sos` | `EmergencySosScreen` | Emergency SOS |
| `/settings` | `SettingsScreen` | Settings |

---

## Feature Architecture

The app is organized into feature-driven modules under `lib/features/`:

```
lib/features/
├── auth/           # Login, registration, and credential recovery scaffolds
├── bike_scan/      # Motorcycle onboarding, camera VIN scanner, and spec details
├── dashboard/      # Cockpit landing screen, profile overview, navigation dock
├── emergency_sos/  # Rapid-response emergency dispatch & medical SOS ID
├── garage/         # Fleet management, active bike state controller, bike profile
├── maintenance/    # Service history, predictive maintenance, carburetor tuning, expense budget
├── mechanics/      # Nearby motorcycle service center finder & workshop registry
├── navigation/     # Offline maps, route packs, GPX trail tracking
├── ride_history/   # Log of past rides, telemetry logs, performance metrics
├── settings/       # Shared SettingsController & dedicated SettingsScreen
└── voice_copilot/  # Hands-free tactical AI voice query assistant
```

## Core & Theme System (`lib/app/` & `lib/core/`)

- **Theme (`lib/app/theme/`)**: Defined in `AppColors` and `AppTextStyles`. Includes skeuomorphic shadows (`skeuRaised`, `skeuInset`, `skeuPressed`), tactical colors (Tactical Orange, Army Green, Clay surface), and custom radii (`radiusCard`, `radiusTile`, `radiusButton`).
- **Shared Widgets (`lib/core/widgets/`)**: Reusable components standardizing app look & feel:
  - `CampAppBar`: Skeuomorphic top app bar.
  - `CampBottomNav`: Tactical floating navigation bar.
  - `CampCard`: Soft tactile container card.
  - `LabeledTextField` & `SegmentedControl`: Form inputs and segmented toggles.

## Run & Verification Commands

### Development Setup
```bash
flutter pub get
flutter run
```

### Static Analysis & Testing
```bash
flutter analyze
flutter test
```

## Stack Highlights

- **Framework**: Flutter (Dart `^3.13.4`)
- **State Management**: Reactive Singleton `ChangeNotifier` controllers (`ActiveBikeController`, `SettingsController`)
- **UI Design System**: Tactical skeuomorphic clay-style design system with Google Fonts (`Manrope`, `Teko`, `Share Tech Mono`)
- **Plugins**: `camera`, `flutter_map`, `google_fonts`, `latlong2`, `proj4dart`
