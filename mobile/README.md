# CAMP Mobile

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart_%5E3.13.4-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Tests](https://img.shields.io/badge/Tests-114%20passing-22C55E)](mobile/test/)
[![Analyze](https://img.shields.io/badge/flutter%20analyze-0%20issues-22C55E)](mobile/analysis_options.yaml)

CAMP Mobile is a Flutter rider cockpit for managing a motorcycle fleet, logging post-ride reports, tracking predictive maintenance and trip finances, navigating with offline maps, finding mechanics, and managing rider settings. The implementation uses a tactical **skeuomorphic clay** design system, reactive singleton `ChangeNotifier` state management, and fully offline-first `SharedPreferences` persistence.

> **100% Software-Based Architecture** — CAMP operates on rider-logged data (odometer readings, service records, terrain tags) and standard smartphone GPS. There is **no OBD-II, no ECU polling, no hardware sensor pairing, and no live telemetry hardware**. All wear indicators, service warnings, and carburetor guidance are deterministic software calculations derived from user input.

---

## Quick Start

```bash
cd mobile
flutter pub get
flutter run
```

### Static Analysis & Tests
```bash
flutter analyze    # 0 issues expected
flutter test       # 114 / 114 passing
```

---

## Architecture Overview

```
lib/
├── main.dart                     ← App root, WidgetsBindingObserver (save-on-exit),
│                                   eager LocalStore + controller loads, route map
├── app/
│   ├── routes.dart               ← CampRoutes — single source for all route strings
│   └── theme/
│       ├── app_colors.dart       ← Design tokens: colors, shadows, radii, spacing
│       └── app_theme.dart        ← MaterialTheme + AppTextStyles (Manrope, Teko, Share Tech Mono)
├── core/
│   ├── storage/
│   │   └── local_store.dart      ← SharedPreferences wrapper with ordered write queue & flush()
│   └── widgets/                  ← 16 shared UI components (CampCard, CampAppBar, CampBottomNav …)
└── features/
    ├── auth/                     ← SignIn · SignUp · ForgotPassword (mock auth)
    ├── bike_scan/                ← AddMotorcycle · BikeScan · BikeDetails
    ├── dashboard/                ← HomeScreen · ProfileScreen · EditProfileScreen + 8 widgets
    ├── emergency_sos/            ← EmergencySosScreen
    ├── garage/                   ← GarageScreen · BikeProfileScreen
    │   ├── controllers/          ← ActiveBikeController (singleton, persisted)
    │   └── domain/               ← Bike · ServiceRecord · FuelSystem · TrackingMode
    ├── maintenance/              ← MaintenanceScreen · FinanceRigHealthScreen + 5 sub-screens + 12 widgets
    │   ├── controllers/          ← PostRideReportController · TripBudgetController (both persisted)
    │   └── domain/               ← MaintenancePredictionEngine · CarburetorGuidanceTable …
    ├── mechanics/                ← MechanicsHomeScreen · AddMechanicScreen
    ├── navigation/               ← NavigationMapScreen · RoutePacksScreen
    │   ├── controllers/          ← NavigationController (per-screen, not singleton)
    │   └── domain/               ← LocationService · RoutingService · GeocodingService · PlacesPoiService
    ├── ride_history/             ← RideHistoryScreen
    ├── settings/                 ← SettingsScreen
    │   └── controllers/          ← SettingsController (singleton, persisted)
    └── voice_copilot/            ← VoiceAssistantScreen
```

---

## State Management & Data Flow

All persistent user data is managed by six **ChangeNotifier singletons**, loaded eagerly in `main()` before `runApp`:

| Controller | Persists To | Consumed By |
|---|---|---|
| `ActiveBikeController` | `LocalStore` (`camp_bikes`, `camp_active_bike_id`) | Dashboard, Maintenance, Navigation, Garage, Bike Scan |
| `ProfileController` | `LocalStore` (`camp_rider_profile`) | Dashboard, ProfileScreen, EditProfileScreen |
| `SettingsController` | `LocalStore` (`camp_settings`) | Settings screen, NavigationController (units) |
| `PostRideReportController` | `LocalStore` (`camp_post_ride_reports`) | MaintenanceScreen (PostRide tab, Diagnostics engine), RideHistory |
| `TripBudgetController` | `LocalStore` (`camp_trip_budget`, `camp_trip_expenses`) | FinanceRigHealth screen and all its sub-screens |
| `MechanicController` | `LocalStore` (`camp_mechanics_list`) | MechanicsHomeScreen, AddMechanicScreen |

`NavigationController` is **not** a singleton — it is created and disposed per `NavigationMapScreen` lifecycle. It reads `ActiveBikeController` (for fuel estimates) and `SettingsController` (for metric/imperial units).

### Persistence Layer (`LocalStore`)

`LocalStore` wraps `SharedPreferences` with:
- **Ordered write queue** — a chained `Future<void> _writeQueue` guarantees writes complete in submission order, preventing a later write from overtaking an earlier one.
- **`flush()`** — awaits the entire queue; called on app lifecycle `paused / inactive / detached` via `WidgetsBindingObserver` in `CampApp`.
- **Schema versioning** — `camp_schema_version` key guards against loading data from a future schema version.
- **First-run seeding** — `camp_first_run_completed` gates whether defaults are seeded on install.

---

## Registered Routes

All route strings are declared as constants in [`lib/app/routes.dart`](lib/app/routes.dart). **One constant per screen, no duplicates.**

| Route | Screen | Feature |
|---|---|---|
| `/` | `HomeScreen` | Dashboard |
| `/sign-in` | `SignInScreen` | Auth |
| `/sign-up` | `SignUpScreen` | Auth |
| `/forgot-password` | `ForgotPasswordScreen` | Auth |
| `/add-bike` | `AddMotorcycleScreen` | Bike Scan |
| `/bike-scan` | `BikeScanScreen` | Bike Scan |
| `/bike-details` | `BikeDetailsScreen` | Bike Scan |
| `/garage` | `GarageScreen` | Garage |
| `/bike-profile` | `BikeProfileScreen` | Garage |
| `/profile` | `ProfileScreen` | Dashboard |
| `/edit-profile` | `EditProfileScreen` | Dashboard |
| `/mechanics` | `MechanicsHomeScreen` | Mechanics |
| `/add-mechanic` | `AddMechanicScreen` | Mechanics |
| `/navigation/map` | `NavigationMapScreen` | Navigation |
| `/voice-copilot` | `VoiceAssistantScreen` | Voice Copilot |
| `/route-packs` | `RoutePacksScreen` | Navigation |
| `/ride-history` | `RideHistoryScreen` | Ride History |
| `/finance-rig-health` | `FinanceRigHealthScreen` | Maintenance |
| `/maintenance` | `MaintenanceScreen` | Maintenance |
| `/predictive-maintenance` | `MaintenanceScreen(initialTab: diagnostics)` | Maintenance |
| `/carburetor-tuning` | `MaintenanceScreen(initialTab: carburetor)` ¹ | Maintenance |
| `/settings` | `SettingsScreen` | Settings |
| `/emergency-sos` | `EmergencySosScreen` | Emergency SOS |

> ¹ EFI bikes automatically fall back to the Diagnostics tab.
>
> **Legacy aliases** (kept for branch compatibility, scheduled for removal):
> `/mechanics/map` → `NavigationMapScreen` · `/mechanics/voice-assistant` → `VoiceAssistantScreen`

---

## Feature Details

### Dashboard (`features/dashboard/`)
- **HomeScreen** — cockpit landing: active bike card, voice bar, maintenance alert, recent updates feed, floating `CampBottomNav`.
- **ProfileScreen** — rider overview: cockpit hero, touring tier, trail badges, garage summary, ride health, SOS medical ID.
- **EditProfileScreen** — form editor for rider personal details.

### Bike Scan (`features/bike_scan/`)
- **AddMotorcycleScreen** — entry hub: Scan Bike (camera) or View Garage.
- **BikeScanScreen** — camera with 8-second timeout, "Starting camera…" status, manual-entry fallback.
- **BikeDetailsScreen** — multi-step spec form; on save calls `ActiveBikeController.addBike()`.

### Garage (`features/garage/`)
- **GarageScreen** — fleet list, bike switcher, remove bike.
- **BikeProfileScreen** — full spec sheet, service records, active bike toggle.
- **Bike model** — `id`, `make`, `modelName`, `modelYear`, `odometerKm`, `fuelSystem` (`efi` | `carburetor`), `carburetorType`, `fuelTankCapacityLiters`, `fuelAverageKmPerLiter`, `ridingTerrain`, `lastOilChange`, `lastTuneUp`, `vin`, `nickname`, `imagePath`.

### Maintenance (`features/maintenance/`)
- **MaintenanceScreen** — 4-tab shell:
  - *Diagnostics* — `MaintenancePredictionEngine` computes wear % for engine oil, chain, brake pads, tires from odometer + service records + terrain tags. Shows `RidePatternInsight` derived from post-ride logs.
  - *Carburetor* — hidden for EFI bikes. GPS altitude → US Standard Atmosphere 1976 → air-density ratio → 4 severity bands with jetting guidance.
  - *Pre-Ride* — safety checklist.
  - *Post-Ride* — debrief form → `PostRideReportController.addReport()`.
- **FinanceRigHealthScreen** — trip budget (`TripBudgetController`) + maintenance item list. Sub-screens: `AddExpenseScreen`, `EditTripBudgetScreen`, `AddMaintenanceItemScreen`.

### Navigation (`features/navigation/`)
- **NavigationMapScreen** — OSM vector map (`flutter_map`), OSRM routing, Nominatim geocoding, GPS position stream, wakelock during active guidance, topo/standard layer toggle, POI markers (mechanic · fuel · rest stop).
- **NavigationController** states: `idle → previewing → navigating → arrived`. Off-route detection (>50 m from polyline for 3 consecutive fixes) triggers reroute (throttled to 1 per 10 s).
- **RoutePacksScreen** — offline route packs with trail difficulty ratings and storage management.

### Mechanics (`features/mechanics/`)
- **MechanicsHomeScreen** — searchable, filterable directory (verified / emergency / brand-specific). List and map-preview toggles. Add mechanic returns result via `Navigator.pop`.
- **AddMechanicScreen** — multi-field workshop registration form.

### Settings (`features/settings/`)
- **SettingsController** — metric/imperial units, notifications, privacy sharing, cached pack display, language. Persisted to `LocalStore`.
- **SettingsScreen** — toggles, cache clear, language picker.

---

## Shared Widgets (`core/widgets/`)

| Widget | Purpose |
|---|---|
| `CampAppBar` | Skeuomorphic top bar with back/menu leading, logo, action pill |
| `CampBottomNav` | Floating tactical 5-tab dock (Home · Scan · Map · Wrench · Dash) |
| `CampCard` | Raised clay container with dual-shadow skeuomorphic effect |
| `InsetTile` | Recessed inset surface for input areas and info rows |
| `IconTile` | Raised or inset icon button tile |
| `GhostButton` | Secondary borderless action button |
| `PrimaryButton` | Full-width orange CTA button |
| `LabeledTextField` | Text input with label, validation, and error state |
| `LabeledDropdown` | Styled dropdown with label |
| `SegmentedControl` | Pill-style multi-option selector |
| `MultiSelectChipRow` | Horizontally scrollable tag chip selector |
| `SectionHeader` | Row with title + optional action link |
| `StatusChip` | Color-coded status badge (ok / due soon / overdue) |
| `DistanceOrDateInput` | Toggle input: distance (km) or calendar date |
| `CockpitHeroCard` | Dark espresso gradient hero panel |

---

## Design System

- **Background**: `clay` `#EDF1F7` with `clayDark` `#E3E8F0` insets.
- **Primary accent**: Tactical Orange `#FA7014`.
- **Shadow system**: dual-shadow skeuomorphism — `skeuRaised` (convex) · `skeuRecessed` (inset) · `skeuRaisedSmall` · `cockpitBezel` · `dockShadow` · `orangeGlow`.
- **Radii**: `radiusCard` 26 · `radiusTile` 18 · `radiusPill` 999.
- **Typography**: Manrope (body/UI) · Teko (stats/display) · Share Tech Mono (telemetry labels).

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `camera` | `^0.12.1` | BikeScanScreen viewfinder |
| `flutter_map` | `^7.0.2` | OSM tile map |
| `geolocator` | `^13.0.1` | GPS position + altitude |
| `google_fonts` | `^6.2.1` | Manrope, Teko, Share Tech Mono |
| `latlong2` | `^0.9.1` | LatLng types + distance calc |
| `http` | `^1.2.0` | OSRM + Nominatim API calls |
| `image_picker` | `^1.1.2` | Photo upload in bike scan |
| `url_launcher` | `^6.3.3` | Google Maps deep-link, phone dialer |
| `share_plus` | `^13.3.1` | Report export |
| `wakelock_plus` | `^1.8.1` | Screen-on during active navigation |
| `shared_preferences` | `^2.5.6` | LocalStore offline persistence |

---

## Test Suite

14 test files · **114 tests · 0 failures · 0 lints**

| File | What It Covers |
|---|---|
| `persistence_test.dart` | LocalStore write queue, flush, schema fallback, model round-trips |
| `widget_test.dart` | Route uniqueness, lifecycle flush (paused/inactive), tab selection |
| `navigation_unit_test.dart` | NavigationController dispose guard, distance-to-polyline math |
| `navigation_map_screen_test.dart` | Map screen renders with FakeTileProvider network isolation |
| `maintenance_prediction_test.dart` | PredictionEngine wear %, pattern insights, terrain multipliers |
| `maintenance_test.dart` | MaintenanceScreen tab switching, EFI carburetor fallback |
| `bike_scan_test.dart` | BikeScanScreen camera timeout, manual-entry fallback |
| `bike_profile_test.dart` | BikeProfileScreen renders, active bike toggle |
| `bike_details_test.dart` | BikeDetailsScreen form validation and save |
| `add_motorcycle_test.dart` | AddMotorcycleScreen entry point routing |
| `settings_screen_test.dart` | SettingsScreen toggles, SettingsController persistence |
| `profile_screen_test.dart` | ProfileScreen renders with active bike data |
| `ride_history_test.dart` | RideHistoryScreen renders expedition list |
| `route_packs_test.dart` | RoutePacksScreen renders route cards |

---

## Known Issues (from Code Review)

| # | Issue | Priority |
|---|---|---|
| C-1 | `ActiveBikeCardWidget` shows hardcoded bike name/fuel — not reading from `ActiveBikeController` | 🔴 Critical |
| C-2 | `FinanceRigHealthScreen` hero card always shows "KTM 890" regardless of active bike | 🔴 Critical |
| C-3 | `MaintenanceItem` list in `FinanceRigHealthScreen` is widget-local state (not persisted) | 🔴 Critical |
| C-4 | `RideHistoryScreen` renders static `ExpeditionLog.samples`, ignores `PostRideReportController` | 🔴 Critical |
| C-5 | Added mechanics survive only in-memory (`_mechanicsList`), lost on screen dispose | 🔴 Critical |
| C-6 | `NavigationController` is not a singleton — GPS restarts on every map visit | 🔴 Critical |
| C-7 | `"SYNCD 2m ago"` label in `FinanceRigHealthScreen` is hardcoded (no real backend sync) | 🔴 Critical |
| M-2 | `SettingsController.setLanguage()` does not call `save()` | 🟡 Medium |
| M-3 | `SettingsController.clearLocalCache()` does not call `save()` | 🟡 Medium |
| M-5 | `NavigationController` saved/recent places not persisted to `LocalStore` | 🟡 Medium |
| L-9 | Default map center hardcoded to North Cascades, WA, USA | 🟢 Low |

See [`CODE_REVIEW_REPORT.md`](CODE_REVIEW_REPORT.md) for the full issue list.
