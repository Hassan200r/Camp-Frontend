# CAMP Mobile

CAMP is a Flutter app for motorcycle management and rider support. The current app includes a home dashboard, motorcycle garage and registration flow, bike scanning, and profile screens.

## Requirements

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml`
- An Android emulator or device, or Xcode and an iOS simulator for iOS development

Check your local Flutter and platform setup with:

```sh
flutter doctor
```

## Run the app

From this directory, fetch dependencies and start the app on a connected device or running emulator:

```sh
flutter pub get
flutter run
```

## Verify changes

Run the test suite and Dart analyzer from this directory:

```sh
flutter test
flutter analyze
```

## Project layout

- `lib/main.dart` initializes the app, theme, and named routes.
- `lib/app/` contains app-wide configuration and theming.
- `lib/core/` contains shared application code.
- `lib/features/` contains feature screens and related code, including bike scanning, dashboard, and garage.
- `assets/` contains app images, icons, maps, AI resources, and seed data.
- `test/` contains widget and feature tests.

The app uses Flutter Material, the `camera` package, and Google Fonts. See `pubspec.yaml` for the complete dependency and asset configuration.
