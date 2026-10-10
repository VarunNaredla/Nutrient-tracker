# NutriDay Flutter implementation

This repository now contains the Flutter implementation of the nutrient tracker.

## Architecture

The Flutter application starts in lib/main.dart. The app uses Material widgets and Dart state to render the dashboard, insights, and goals destinations. Daily food entries, water counts, and nutrient goals are serialized as JSON and stored on-device with shared_preferences.

## Current behavior

- The dashboard shows daily calorie progress, macro and fiber progress, water intake, and food entries.
- The date controls switch between independent daily logs.
- Food can be added to a meal and removed from the journal.
- Goals can be edited for calories, protein, carbohydrates, fat, fiber, and water.
- Insights summarize the selected day's values against its targets.
- The first launch includes a sample log for the current day.

The app does not include an account, cloud synchronization, or a food database. Platform launch folders can be generated for the development machine with Flutter tooling when needed.
