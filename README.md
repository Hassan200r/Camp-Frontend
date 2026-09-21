# CAMP Workspace

A comprehensive full-stack monorepo for the **CAMP** smart mobility, navigation, and vehicle care platform.

---

## 📁 Monorepo Architecture

```
CAMP/
├── mobile/                  # Flutter mobile application
│   ├── android/             # Android native configuration and build scripts
│   ├── ios/                 # iOS native configuration and Xcode workspace
│   ├── assets/              # App assets and static resources
│   │   ├── ai/              # AI models, offline embeddings, and prompts
│   │   ├── icons/           # UI & system icon sets
│   │   ├── images/          # Illustration & raster graphics
│   │   ├── map/             # Map styles, vector tiles & markers
│   │   └── seed_data/       # Mock data and offline catalog seeds
│   ├── lib/
│   │   ├── app/             # Application lifecycle & global setups
│   │   │   ├── config/      # Environment & runtime configurations
│   │   │   ├── router/      # Navigation routing & deep links
│   │   │   └── theme/       # Design tokens, themes & typography
│   │   ├── core/            # Shared cross-cutting modules
│   │   │   ├── constants/   # App-wide constants & assets references
│   │   │   ├── database/    # Local persistence (Drift / Floor / SQLite)
│   │   │   │   ├── daos/    # Data Access Objects
│   │   │   │   └── tables/  # Database schema definitions
│   │   │   ├── network/     # HTTP clients, interceptors & error handlers
│   │   │   ├── services/    # Location, Bluetooth, Sensor & Background services
│   │   │   └── utils/       # Formatters, loggers, validation helpers
│   │   ├── features/        # Feature-first modular domain slices
│   │   │   ├── auth/            # Authentication & Onboarding
│   │   │   ├── dashboard/       # Central status, telemetrics & summary
│   │   │   ├── bike_scan/       # Vision AI vehicle scanner & diagnostics
│   │   │   ├── garage/          # Vehicle inventory & parts registry
│   │   │   ├── navigation/      # Turn-by-turn routing & offline maps
│   │   │   ├── mechanics/       # Nearby workshops & specialist finder
│   │   │   ├── maintenance/     # Wear-and-tear tracking & service schedules
│   │   │   ├── ride_history/    # Trip telemetry, routes & stats
│   │   │   ├── emergency_sos/   # Crash detection & emergency dispatches
│   │   │   ├── voice_copilot/   # Hands-free audio assistant & feedback
│   │   │   └── settings/        # Preferences & profile configuration
│   │   │   # (Each feature includes: controllers/, domain/, presentation/)
│   │   └── main.dart        # Flutter entrypoint
│   ├── test/                # Unit, widget, and integration tests
│   ├── pubspec.yaml         # Flutter dependencies
│   └── analysis_options.yaml# Dart static analysis configuration
│
├── backend/                 # Backend API services & functions
│   ├── config/              # Server configuration & environment validation
│   ├── functions/           # Cloud Functions / Serverless handlers
│   │   └── src/
│   │       ├── maintenance_rules/ # Automated maintenance triggers
│   │       └── sync/        # Cloud-to-local bidirectional sync
│   └── src/
│       ├── middlewares/     # Auth, validation, error-handling middlewares
│       ├── modules/         # Domain modules (elevation, mechanics, routes)
│       └── routes/          # REST & WebSocket endpoint definitions
│
├── firebase/                # Firebase configs, rules, and deployment specs
├── .gitignore               # Root monorepo Git exclusion rules
└── README.md                # Project documentation
```

---

## 🚀 Getting Started

### 1. Mobile Application (Flutter)

Navigate to the `mobile/` directory to run the Flutter application:

```bash
cd mobile

# Fetch Flutter dependencies
flutter pub get

# Run on an attached device or emulator
flutter run
```

### 2. Backend Services

Navigate to the `backend/` directory to set up API services:

```bash
cd backend

# Install dependencies (when package.json is initialized)
npm install

# Run in development mode
npm run dev
```

### 3. Firebase Suite

Ensure you have the [Firebase CLI](https://firebase.google.com/docs/cli) installed:

```bash
cd firebase

# Authenticate & initialize targets
firebase login
firebase use --add
```

---

## 🏛 Feature-First Architecture

Each mobile feature under `mobile/lib/features/` follows a strict three-tier separation of concerns:

- **`domain/`**: Pure Dart models, entities, and business logic / repository interfaces. Independent of Flutter UI.
- **`controllers/`**: State management (BLoC, Riverpod, or Cubits) mediating between domain logic and views.
- **`presentation/`**: Flutter widgets, screens, custom painters, and user interaction layers.
