# CAMP Mobile

CAMP Mobile is a Flutter rider cockpit for managing a motorcycle, checking live telemetry-style status, registering a new bike, managing garage fleets, navigating off-grid route packs, tracking maintenance & trip finances, and managing rider settings. The current implementation features a tactical skeuomorphic theme with clay-style card containers, dynamic active bike synchronization, and reactive settings architecture.

## App Workflow & Feature Matrix

1. **Launch & Navigation (`lib/main.dart`)**
   - Main entry point initializing global singletons (`ActiveBikeController`, `SettingsController`) and registered routes.
   - Dynamic named routing including `/`, `/add-bike`, `/bike-scan`, `/garage`, `/bike-profile`, `/bike-details`, `/profile`, `/edit-profile`, `/settings`, and `/route-packs`.

2. **Explore Dashboard (`lib/features/dashboard/`)**
   - `HomeScreen`: Tactical cockpit landing page with live telemetry stats, AI voice copilot bar, active bike status, quick alerts, and bottom navigation dock (`CampBottomNav`).
   - `ProfileScreen`: Rider account overview with cockpit hero card, touring tier progress, earned trail badges, garage quick view, maintenance health summaries, recent trips, rider medical SOS ID, and a reactive **Settings card** linked directly to `SettingsController.instance`.

3. **Dedicated Settings Management (`lib/features/settings/`)**
   - **`SettingsScreen`**: Single source of truth for all rider preferences and storage management:
     - **Hero Rider Bar**: Dynamic rider avatar with active bike name read directly from `ActiveBikeController`.
     - **Account Card**: Personal Info shortcut, Change Password, and Linked Accounts (`Connected as alex@bmwmoto.com`).
     - **Preferences Card**: Segmented Control unit switcher (`Metric (km, °C)` vs `Imperial (mi, °F)`), Notifications toggle (`Maintenance alerts, trip reminders`), and Language selector.
     - **Storage & Data Card**: Offline Maps status navigation shortcut (`Cascades & Alps Route Packs`), Privacy & Telemetry sharing toggle, and Clear Local Cache action with confirmation dialog.
     - **Support & Danger Zone**: Help & Support, About CAMP (`v1.0.0`), and Log Out danger button.
   - **`SettingsController`**: Singleton `ChangeNotifier` managing units, notifications state, privacy telemetry toggles, and cache size state.

4. **Add Motorcycle & Scanner Flow (`lib/features/bike_scan/`)**
   - `AddMotorcycleScreen`: Registration hub with camera scanning, photo upload, and manual entry.
   - `BikeScanScreen`: Camera VIN scanning sequence with HUD graphics, audio/flash controls, and simulated bike detection (BMW, Ducati, KTM).
   - `BikeDetailsScreen`: Full multi-step bike spec editor with validation gating.

5. **Garage Fleet & Bike Profile (`lib/features/garage/`)**
   - `GarageScreen`: Active fleet manager with telemetry status, sync controls, and bike card list.
   - `BikeProfileScreen`: Detailed motorcycle spec sheet, service history, and active bike selection controller (`ActiveBikeController`).

6. **Expedition Maintenance & Finances (`lib/features/maintenance/`)**
   - `FinanceRigHealthScreen`: Combined trip budget calculator (`TripBudgetCardWidget`) and component health telemetry tracker (`MaintenanceListWidget`).
   - Dialogs and secondary screens for adding expenses, editing trip budgets, managing maintenance items, and confirming trip deletions.

7. **Off-Grid Maps & Route Packs (`lib/features/navigation/`)**
   - Offline route packs management (`RoutePacksScreen`), trail telemetry, and map rendering components.

## Feature Architecture

The app is organized into feature-driven modules under `lib/features/`:

```
lib/features/
├── auth/           # Login, registration, and credential recovery scaffolds
├── bike_scan/      # Motorcycle onboarding, camera VIN scanner, and spec details
├── dashboard/      # Cockpit landing screen, profile overview, navigation dock
├── emergency_sos/  # One-tap emergency contact location dispatch
├── garage/         # Fleet management, active bike state controller, bike profile
├── maintenance/    # Service history, rig health monitoring, trip expense budget
├── mechanics/      # Nearby motorcycle service center finder
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
*Both commands must run with 0 errors/warnings.*

## Stack Highlights

- **Framework**: Flutter (Dart `^3.13.4`)
- **State Management**: Reactive Singleton `ChangeNotifier` controllers (`ActiveBikeController`, `SettingsController`)
- **UI Design System**: Skeuomorphic clay-style design system with Google Fonts (`Manrope`, `Teko`, `Share Tech Mono`)
- **Plugins**: `camera`, `flutter_map`, `google_fonts`, `latlong2`, `proj4dart`
