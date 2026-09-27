# CAMP Mobile

CAMP Mobile is a Flutter rider cockpit for managing a motorcycle, checking live telemetry-style status, registering a new bike, and viewing the rider profile. The current implementation is centered around a dashboard-first workflow with a bottom navigation dock and a motorcycle onboarding flow.

## Current app workflow

The app currently follows this flow:

1. Launch the app from `lib/main.dart`
   - `initialRoute` is `/`
   - The home screen is rendered by `HomeScreen`

2. Explore dashboard
   - `HomeScreen` is the main landing screen
   - It includes the app header, rider cockpit card, AI/voice assistant bar, maintenance alert, active bike panel, and recent updates
   - The floating tactical dock is used to navigate between major app sections

3. Add a motorcycle
   - The bottom dock item for the bike scan flow navigates to `/add-bike`
   - `AddMotorcycleScreen` is the registration entry point
   - The user can choose between:
     - Scan with Camera
     - Upload Photo
     - Enter Manually

4. Bike scan and telemetry flow
   - `BikeScanScreen` is the camera-driven scanning screen
   - It simulates live scan telemetry, optional flash/audio toggles, and a scan animation sequence
   - The mock scan variants include BMW, Ducati, and KTM examples

5. Garage overview
   - `GarageScreen` shows the active motorcycle and synced telemetry
   - It includes a sync success banner, active bike details, and the option to launch diagnostics

6. Rider profile screen
   - `ProfileScreen` displays the rider account, fleet data, badges, health cards, settings, and logout controls

## Feature structure

The current feature folders in `lib/features` reflect the active app flow:

- `dashboard/`
  - `presentation/screens/home_screen.dart`
  - `presentation/screens/profile_screen.dart`
  - `presentation/screens/edit_profile_screen.dart`
  - Dashboard widgets for the cockpit, alerts, feed, drawer, and bottom navigation

- `bike_scan/`
  - `presentation/screens/add_motorcycle_screen.dart`
  - `presentation/screens/bike_scan_screen.dart`
  - Motorcycle registration and scan flow

- `garage/`
  - `presentation/screens/garage_screen.dart`
  - Active bike inventory and synced vehicle details

- `auth/`
  - Placeholder scaffolding for authentication-related work

- `navigation/`, `maintenance/`, `mechanics/`, `settings/`, `voice_copilot/`, `emergency_sos/`, `ride_history/`, `presentation/`
  - These folders exist as part of the larger app architecture and are not yet fully wired into the primary app flow

## App entry and routing

The main app state and route registrations are in `lib/main.dart`.

Current named routes:

- `/` → `HomeScreen`
- `/add-bike` and `/add-motorcycle` → `AddMotorcycleScreen`
- `/bike-scan` → `BikeScanScreen`
- `/garage` → `GarageScreen`
- `/profile` → `ProfileScreen`
- `/edit-profile` → `EditProfileScreen`

## Run the app

From the `mobile` folder:

```bash
flutter pub get
flutter run
```

## Validate the project

```bash
flutter test
flutter analyze
```

## Project layout

- `lib/main.dart` initializes the app, theme, and named routes
- `lib/app/` contains shared app configuration and theme definitions
- `lib/core/` contains reusable widgets, utilities, and shared logic
- `lib/features/` contains the current feature-based app modules
- `assets/` stores images, icons, AI resources, and map/seed data
- `test/` contains the current Flutter test coverage

## Stack highlights

- Flutter + Material Design
- `camera` package for scanning flow
- `google_fonts` for the app styling system
- Sketch-like skeuomorphic UI styling in the custom theme and widgets

This README reflects the actual, currently implemented user journey and feature structure in the app, rather than a generic template.
