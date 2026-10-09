# Flutter Concepts for NutriDay

This guide explains how the current browser-based NutriDay tracker could be built with Flutter. The repository currently runs as a web app from `index.html`; these are Flutter learning notes and an implementation map, not a claim that the app has already been migrated.

## 1. Flutter and Dart

Flutter is a UI toolkit for building apps from a shared Dart codebase. Dart supplies the language features used in Flutter, including classes, null safety, collections, and asynchronous functions.

A Flutter app starts in `lib/main.dart`. Its `main()` function calls `runApp()` with the root widget:

```dart
void main() {
  runApp(const NutriDayApp());
}
```

## 2. Widgets and the widget tree

Flutter interfaces are trees of widgets. A widget describes part of the UI; Flutter lays out and paints the tree.

- `StatelessWidget`: UI that depends only on its inputs.
- `StatefulWidget`: UI with state that can change over time.
- `MaterialApp`: app-level configuration such as theme and navigation.
- `Scaffold`: common page structure with app bar, body, and navigation areas.

For NutriDay, the root could be `NutriDayApp`, with a daily dashboard page containing nutrient summary cards, meal sections, and water tracking.

## 3. Layout and responsive UI

Flutter layout is composed from widgets such as `Row`, `Column`, `Wrap`, `Expanded`, `Padding`, and `Container`. Use `ListView` for scrollable meal and food entries. Use `LayoutBuilder` or `MediaQuery` to adapt navigation and grids to available width.

For example, a wide screen can show multiple nutrient cards in a row, while a narrow phone screen can wrap or stack them.

## 4. State and rebuilding

State is the data that can change while the app runs. When state changes, Flutter rebuilds the affected UI.

A small prototype can keep page-local state in a `StatefulWidget` and call `setState()`. As the app grows, move nutrient goals, selected date, food entries, and water amounts into a dedicated state layer (for example, a `ChangeNotifier` or another chosen state-management solution).

Keep calculations such as daily totals in model or service code rather than embedding them in presentation widgets.

## 5. Data models

Represent app data with Dart classes so fields and relationships are explicit. A starter model might look like:

```dart
class FoodEntry {
  const FoodEntry({
    required this.name,
    required this.meal,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.date,
  });

  final String name;
  final String meal;
  final double calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final DateTime date;
}
```

A separate daily-goals model can hold targets for calories, protein, carbohydrates, fat, fiber, and water.

## 6. Navigation

Flutter navigation moves between pages or destinations. A simple tracker could use a bottom navigation bar for **Today**, **Insights**, and **Settings**. Keep the selected date and daily log available when moving between these destinations.

## 7. Forms and input

Use a `Form` with `TextFormField` widgets to add food or edit goals. Add validation for required names and numeric nutrient values. A save action should validate the form before adding an entry to the selected day's log.

## 8. Persistence

The current web app stores data in browser storage on one device. A Flutter version needs its own persistence layer. For a local-only prototype, choose an appropriate on-device storage package and serialize the daily logs and goals. Put storage behind a repository interface so UI code does not depend directly on storage details.

If account sign-in or cloud sync is added later, define how local changes and remote data are reconciled before implementing sync.

## 9. Async work and error states

Dart uses `Future` and `async/await` for work that completes later, such as reading saved data. Show loading and error states when that work is in progress or fails; do not assume stored data is always available.

## 10. Suggested Flutter structure

```text
lib/
  main.dart
  models/
    food_entry.dart
    daily_goals.dart
  screens/
    today_screen.dart
    insights_screen.dart
    settings_screen.dart
  widgets/
    nutrient_summary_card.dart
    meal_section.dart
    water_tracker.dart
  repositories/
    nutrition_repository.dart
```

This is a starting point, not a required architecture. Keep the first version small and separate UI, data models, and persistence as responsibilities become clearer.

## 11. Testing and accessibility

Widget tests can check that nutrient totals and meal entries render correctly. Unit tests can cover calculations such as totals and progress toward a goal. Provide meaningful labels for buttons and form fields, maintain readable contrast, and make touch targets comfortable on mobile screens.

## Suggested build order

1. Create the Flutter app shell and theme.
2. Build a static daily dashboard with sample data.
3. Add food-entry and goal forms with validation.
4. Implement date selection, totals, and water tracking.
5. Add local persistence and the insights screen.
6. Test calculations, key widgets, and small-screen layouts.
