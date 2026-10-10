# NutriDay — Nutrient Tracker

NutriDay is a Flutter app written in Dart for tracking daily food, nutrients, water, and personal goals.

## Run the app

1. Install the Flutter SDK.
2. From the repository root, generate platform runner files for the targets you want, for example: `flutter create --platforms=android,ios,web .`.
3. Run `flutter pub get`.
4. Start an available target with `flutter run`.

## Features

- Track calories, protein, carbohydrates, fat, fiber, and water.
- Add and remove food entries by meal.
- Move between daily logs; each date keeps its own food and water entries.
- Set personal daily nutrient goals.
- Review progress in the insights view.
- Save goals and daily logs locally with shared_preferences.

The app is local only. It does not include account sign-in, cloud sync, or an external food database. The first launch starts with a sample log for today.

## Project structure

- `lib/main.dart` contains the Flutter application, data models, screens, and local persistence.
- `pubspec.yaml` defines the Flutter project and Dart dependencies.

The original browser implementation has been replaced. The UI and application logic are Flutter widgets and Dart; Flutter can generate any platform host scaffolding required by your selected targets.
