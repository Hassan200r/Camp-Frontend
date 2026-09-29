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
  - Core landing and rider profile screens.
  - Widgets for cockpit, alerts, activity feed, drawer, and bottom navigation.

- `bike_scan/`
  - Screens for adding a motorcycle, camera‑based VIN scan, photo upload, and manual entry.
  - Handles the full registration flow.

- `garage/`
  - Overview of the rider’s active bike, synced telemetry, and diagnostic launch.

- `auth/`
  - Scaffold for future authentication (login, signup, password reset).

- `navigation/`
  - Map and route planning utilities for ride navigation.

- `maintenance/`
  - Schedule, track, and record bike maintenance tasks and service history.

- `mechanics/`
  - Discover nearby mechanics, view service centre details, and request assistance.

- `settings/`
  - User preferences, theme selection, notification toggles, and app configuration.

- `voice_copilot/`
  - AI‑driven voice assistant for hands‑free commands and queries.

- `emergency_sos/`
  - One‑tap SOS button that shares location with emergency contacts.

- `ride_history/`
  - Log of past rides with telemetry, distance, and performance metrics.

- `presentation/`
  - Shared UI components and base screen scaffolding used across features.

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
