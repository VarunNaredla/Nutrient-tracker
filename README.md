# NutriDay

**Built with Flutter. App source is written in Dart.**

NutriDay is a cross-platform nutrient tracker. The Flutter app records meals, calories, nutrients, hydration, and daily goals, then saves each day's data locally on the device.

> The old browser app has been removed. The Flutter entry point is `lib/main.dart`; there are no JavaScript, CSS, or HTML app source files. GitHub identifies programming languages, so its language label will say **Dart**. Flutter is the framework shown above.

## Run the app

1. Install the Flutter SDK.
2. From the repository root, generate runner files for the platform you want to use. For Android and iOS, run `flutter create --platforms=android,ios .`.
3. Fetch packages with `flutter pub get`.
4. Start the app with `flutter run`.

Flutter generates platform runner files for the selected target. The app interface and behavior remain in Dart under `lib/`.

## App features

- Log food under breakfast, lunch, dinner, or snacks.
- Track calories, protein, carbohydrates, fat, fiber, and water.
- Navigate between dates; meals and water are stored per day.
- Set personal nutrient goals and view progress in Insights.
- Save the tracker locally with `shared_preferences`.
- Start with a sample meal log on first launch.

## Flutter learning slides

These seven lessons explain the core Flutter and Dart ideas used to build the app. All code examples are Dart.

### EXP 1 — Dart Basics

Dart is the programming language used to write Flutter apps. Types such as `int`, `double`, and `String` describe values. Use `final` for a value assigned once and `const` for a compile-time constant. Null safety makes optional values explicit with a question mark.

```dart
final foodName = 'Greek yogurt';
int calories = 280;
double proteinGrams = 20.5;
String? note;
```

### EXP 2 — Flutter Widgets and Layouts

Flutter builds screens from widgets. A widget tree describes how pieces fit together: `MaterialApp` configures the app, `Scaffold` provides a page structure, and widgets such as `Text`, `Row`, `Column`, and `ListView` compose the content. `Padding` adds space; `Expanded` shares the remaining room.

```dart
Scaffold(
  appBar: AppBar(title: const Text('Today')),
  body: ListView(
    children: const [
      Text('Daily energy'),
      NutrientSummary(),
      MealList(),
    ],
  ),
)
```

### EXP 3 — Responsive UI

Responsive Flutter layouts adapt to available space. `LayoutBuilder` exposes the width available to a section, so the app can stack cards on narrow screens and place them in columns on wider screens. Use `Flexible`, `Wrap`, and scrollable widgets to prevent overflow.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final columns = constraints.maxWidth >= 720 ? 2 : 1;
    return GridView.count(
      crossAxisCount: columns,
      children: nutrientCards,
    );
  },
)
```

### EXP 4 — Navigation and Named Routes

Named routes give destinations stable names. Register route names in `MaterialApp`, then use `Navigator.pushNamed` to open a destination and `Navigator.pop` to return. Keep any route arguments explicit and validate them at the destination.

```dart
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (_) => const TodayPage(),
    '/insights': (_) => const InsightsPage(),
  },
)
```

### EXP 5 — Stateful and Stateless Widgets + State Management

A `StatelessWidget` renders the data it receives. A `StatefulWidget` owns local values that change over time; calling `setState` schedules a rebuild. Values shared by multiple screens belong in a shared state model, such as a `ChangeNotifier`. Persist data separately so it survives app restarts.

```dart
setState(() {
  selectedMeal = 'Lunch';
});

class Goals extends ChangeNotifier {
  int calories = 2000;

  void updateCalories(int value) {
    calories = value;
    notifyListeners();
  }
}
```

### EXP 6 — Custom Widgets and Themes

Extract a custom widget when it makes a repeated piece of interface easier to understand or reuse. Named parameters make its inputs clear. Configure shared colors and typography in `ThemeData` and `ColorScheme` so the app stays visually consistent.

```dart
class NutrientTile extends StatelessWidget {
  const NutrientTile({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    trailing: Text('${value.toStringAsFixed(0)} g'),
  );
}
```

### EXP 7 — Forms, Validation, and Error Handling

Use a `Form` and `GlobalKey<FormState>` to validate input before saving. Field validators should explain how to correct invalid values. Saving data is asynchronous work: handle failures with `try`/`catch`, keep the user's input visible, and provide a clear retry or next step.

```dart
if (formKey.currentState!.validate()) {
  try {
    await repository.save(entry);
  } catch (_) {
    showError('Could not save. Try again.');
  }
}
```

## Project files

- `lib/main.dart` — Flutter app entry point, screens, and local state.
- `pubspec.yaml` — Flutter package metadata and Dart dependencies.
- `docs/FLUTTER_CONCEPTS.md` — implementation notes and links to these lessons.

The repository's application code is Flutter/Dart. Markdown and YAML files provide documentation and Flutter project configuration.
