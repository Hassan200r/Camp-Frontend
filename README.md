# CAMP — Context-Aware Motorcycle Platform

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart_%5E3.13.4-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Node.js](https://img.shields.io/badge/Node.js-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Tests](https://img.shields.io/badge/mobile%20tests-114%20passing-22C55E)](mobile/test/)
[![Analyze](https://img.shields.io/badge/flutter%20analyze-0%20issues-22C55E)](mobile/analysis_options.yaml)

A full-stack monorepo for **CAMP** — a smart motorcycle companion app. CAMP provides vision-based bike scanning, offline GPS navigation, software-driven predictive maintenance, trip budget tracking, a mechanics finder, emergency SOS dispatch, and a hands-free voice copilot.

> **100% Software-Based** — No OBD-II, no ECU polling, no hardware sensor pairing. All wear indicators and maintenance guidance are deterministic software calculations derived from rider-logged data and standard smartphone GPS.

---

## Monorepo Structure

```
Camp-Frontend/
├── mobile/              ← Flutter mobile application (primary deliverable)
│   ├── lib/
│   │   ├── main.dart    ← App root, lifecycle observer, route map, eager loads
│   │   ├── app/         ← Routes (CampRoutes), theme tokens, typography
│   │   ├── core/        ← LocalStore (SharedPreferences), shared widgets
│   │   └── features/    ← 11 feature modules (auth, garage, maintenance …)
│   ├── test/            ← 14 test files · 114 tests · 0 failures
│   ├── android/
│   ├── ios/
│   ├── assets/          ← images/, icons/
│   ├── pubspec.yaml
│   └── README.md        ← Mobile-specific documentation
│
├── backend/             ← Node.js / Cloud Functions API (in development)
│   ├── config/          ← Server configuration & environment
│   ├── functions/src/   ← Cloud Function handlers (maintenance, sync)
│   └── src/             ← Express middlewares, domain modules, REST routes
│
├── firebase/            ← Firebase config, security rules, deploy specs
│
├── PROGRESS.md          ← Engineering task log (stability & persistence phases)
└── README.md            ← This file
```

---

## Mobile App — Feature Matrix

| Feature | Screens | State Owner |
|---|---|---|
| **Authentication** | SignIn · SignUp · ForgotPassword | Mock (backend pending) |
| **Dashboard** | HomeScreen · ProfileScreen · EditProfileScreen | `ActiveBikeController` · `ProfileController` (persisted) |
| **Bike Scanner** | AddMotorcycle · BikeScan · BikeDetails | `ActiveBikeController` |
| **Garage & Fleet** | GarageScreen · BikeProfileScreen | `ActiveBikeController` (persisted) |
| **Maintenance Hub** | MaintenanceScreen (4 tabs) | `PostRideReportController` (persisted) |
| **Finances & Rig Health** | FinanceRigHealth + 3 sub-screens | `TripBudgetController` (persisted) |
| **Mechanics Finder** | MechanicsHome · AddMechanic | `MechanicController` (persisted) |
| **Navigation & Maps** | NavigationMap · RoutePacks | `NavigationController` (per-screen) |
| **Ride History** | RideHistoryScreen | `PostRideReportController` (persisted) |
| **Voice Copilot** | VoiceAssistantScreen | — |
| **Emergency SOS** | EmergencySosScreen | — |
| **Settings** | SettingsScreen | `SettingsController` (persisted) |

---

## Getting Started

### 1. Flutter Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

**Verify:**
```bash
flutter analyze    # 0 issues expected
flutter test       # 114 / 114 passing
```

### 2. Backend Services *(in development)*

```bash
cd backend
npm install
npm run dev
```

### 3. Firebase *(in development)*

```bash
# Install Firebase CLI first: https://firebase.google.com/docs/cli
cd firebase
firebase login
firebase use --add
```

---

## Architecture

### Mobile State Management

The Flutter app uses **ChangeNotifier singletons** as the single source of truth for all persistent user data. They are loaded before `runApp` and flushed to `SharedPreferences` on every app lifecycle `paused / inactive / detached` event via `WidgetsBindingObserver`.

```
main() → LocalStore.init()
       → ActiveBikeController.load()       bikes[], activeBike
       → SettingsController.load()         units, notifications, privacy
       → PostRideReportController.load()   ride debrief logs per bike
       → TripBudgetController.load()       trip budget + expense ledger
       → runApp(CampApp)
```

### Feature Module Pattern

Each feature under `mobile/lib/features/<name>/` follows a strict three-layer split:

```
features/<name>/
├── domain/        ← Pure Dart models & business logic (no Flutter imports)
├── controllers/   ← ChangeNotifier state managers mediating domain ↔ UI
└── presentation/
    ├── screens/   ← Full-page widget trees
    └── widgets/   ← Decomposed sub-components
```

### Persistence (`LocalStore`)

`core/storage/local_store.dart` wraps `SharedPreferences` with:
- **Ordered write queue** — chained futures prevent out-of-order writes
- **`flush()`** — awaits all pending writes; called on app background
- **Schema versioning** — guards against loading data from a future schema

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile framework | Flutter · Dart `^3.13.4` |
| State management | `ChangeNotifier` singleton controllers |
| Offline persistence | `SharedPreferences` via `LocalStore` |
| Maps & navigation | `flutter_map` (OSM) · OSRM routing · Nominatim geocoding |
| Location | `geolocator` |
| Camera | `camera` · `image_picker` |
| Typography | Google Fonts — Manrope · Teko · Share Tech Mono |
| UI design | Skeuomorphic clay design system (AppColors, AppTextStyles) |
| Backend | Node.js · Firebase Cloud Functions *(in development)* |
| Auth | Firebase Authentication *(planned)* |
| Database | Cloud Firestore *(planned)* · SQLite/Drift *(planned local cache)* |

---

## Current Status

| Area | Status |
|---|---|
| Mobile UI (all screens) | ✅ Complete |
| Offline persistence (SharedPreferences) | ✅ Complete |
| Route constants & navigation | ✅ Complete |
| Lifecycle save-on-exit | ✅ Complete |
| Flutter analyze | ✅ 0 issues |
| Unit + widget tests | ✅ 114 / 114 passing |
| Backend API (Node.js) | 🔧 In development |
| Firebase Auth integration | 🔧 In development |
| Cloud Firestore sync | 🔧 In development |
| HTTP client layer (`core/network/`) | 🔧 In development |
| Service abstractions (`core/services/`) | 🔧 In development |

See [`PROGRESS.md`](PROGRESS.md) for the detailed engineering task log and [`mobile/CODE_REVIEW_REPORT.md`](mobile/CODE_REVIEW_REPORT.md) for the full list of known issues and planned fixes.

---

## License

![License](https://img.shields.io/github/license/Hassan200r/Camp-Frontend)
