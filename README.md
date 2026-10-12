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

The seven lessons below follow the Flutter app in `lib/main.dart`. Each slide introduces the concept with a NutriDay example; the notes below the image explain the same idea and show related project code.

### EXP 1 — Dart Basics

![Experiment 1 slide: Dart Basics](docs/slides/exp-01.png)

Dart types make NutriDay's data clear: goals use `Map<String, double>`, meal entries use `Map<String, dynamic>`, and lists hold meals. `const` marks fixed default goals; `final` marks values assigned once at runtime. `_value` handles a missing or non-numeric nutrient safely.

**Project example — typed goals and a null-safe nutrient read:**

```dart
const _defaultGoals = <String, double>{
  'calories': 2000,
  'protein': 100,
};

double _value(Map<String, dynamic> meal, String key) =>
    (meal[key] as num?)?.toDouble() ?? 0;
```

**Key idea:** Types and null safety make assumptions visible.

### EXP 2 — Flutter Widgets and Layouts

![Experiment 2 slide: Flutter Widgets and Layouts](docs/slides/exp-02.png)

NutriDay builds its screen with Flutter widgets. `Scaffold` holds the app bar and body; `SafeArea` protects content from system areas; the dashboard uses a scrolling `ListView` and focused card and row builders for calories, water, nutrients and meals.

**Project example — the app frame and selected screen:**

```dart
Scaffold(
  appBar: AppBar(title: const Text('nutriday')),
  body: SafeArea(
    child: _page == 0
        ? _dashboard()
        : _page == 1 ? _insights() : _goalsPage(),
  ),
)
```

**Key idea:** Compose the screen from widgets with clear roles.

### EXP 3 — Responsive UI

![Experiment 3 slide: Responsive UI](docs/slides/exp-03.png)

`LayoutBuilder` gives the dashboard its available width. NutriDay places the calorie and water cards side by side when the width is above 680 pixels and stacks them below that breakpoint. The nutrient grid also changes between one, two and four columns.

**Project example — switch the calorie and water layout:**

```dart
LayoutBuilder(builder: (context, constraints) {
  final wide = constraints.maxWidth > 680;
  return Flex(
    direction: wide ? Axis.horizontal : Axis.vertical,
    children: [
      if (wide) Expanded(flex: 3, child: _calorieCard())
      else _calorieCard(),
      if (wide) Expanded(flex: 2, child: _waterCard())
      else _waterCard(),
    ],
  );
})
```

**Key idea:** Respond to constraints, not a device name.

### EXP 4 — Navigation

![Experiment 4 slide: Navigation in NutriDay](docs/slides/exp-04.png)

NutriDay uses a bottom `NavigationBar` for Today, Insights and My goals. The selected destination is stored in `_page`; `onDestinationSelected` calls `setState`, and the body builds the matching screen. This is the navigation pattern used in the project.

**Project example — update the selected destination:**

```dart
int _page = 0;

NavigationBar(
  selectedIndex: _page,
  onDestinationSelected: (index) =>
      setState(() => _page = index),
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Today'),
    NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Insights'),
    NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'My goals'),
  ],
)
```

**Key idea:** Keep navigation state tied to the selected destination.

### EXP 5 — Stateful and Stateless Widgets

![Experiment 5 slide: State and State Management](docs/slides/exp-05.png)

`NutriDayApp` is a `StatelessWidget` because it configures the app theme and does not own changing screen data. `TrackerHome` is a `StatefulWidget`; its state holds the selected tab, date, daily meal logs and nutrient goals. `setState` rebuilds the screen after an update, and `_save` writes data to local preferences.

**Project example — the stateful screen and its changing data:**

```dart
class TrackerHome extends StatefulWidget {
  const TrackerHome({super.key});
  @override
  State<TrackerHome> createState() => _TrackerHomeState();
}

int _page = 0;
Map<String, double> _goals = Map<String, double>.from(_defaultGoals);
Map<String, Map<String, dynamic>> _days = {};
```

**Key idea:** Keep state where the screens that need it can share it.

### EXP 6 — Reusable Widgets and Themes

![Experiment 6 slide: Reusable Widgets and Themes](docs/slides/exp-06.png)

The `_nutrientCard` builder uses the same layout for protein, carbohydrates, fat and fiber. Its arguments provide the label, data key, unit, color and icon. `ThemeData` sets NutriDay's shared green color scheme, paper background and card style.

**Project example — reuse one card and share theme colors:**

```dart
_nutrientCard(
  'Protein', 'protein', 'g',
  const Color(0xFF558361), Icons.fitness_center,
)

ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _green),
  scaffoldBackgroundColor: _paper,
  cardTheme: CardThemeData(...),
)
```

**Key idea:** Reuse a widget when it improves clarity and consistency.

### EXP 7 — Forms, Validation and Error Handling

![Experiment 7 slide: Forms, Validation and Errors](docs/slides/exp-07.png)

The Add food form requires a food name and checks numeric fields before adding a meal. `_save` catches local storage errors, displays a message and offers a Retry action, so a failed save is not silently treated as successful.

**Project example — validate the food name and guard local saves:**

```dart
validator: (value) => value == null || value.trim().isEmpty
    ? 'Enter a food name' : null,

if (!(formKey.currentState?.validate() ?? false)) return;

try {
  final prefs = await SharedPreferences.getInstance();
  final saved = await prefs.setString(\n      _storageKey, jsonEncode({'goals': _goals, 'days': _days}),\n  );
  if (!saved) throw StateError('Local storage did not confirm the save.');
} catch (error) {
  // Show the save message and a Retry action.
}
```

**Key idea:** Validation guards input; error handling covers failed saves.

## Project files

- `lib/main.dart` — Flutter app entry point, screens, and local state.
- `pubspec.yaml` — Flutter package metadata and Dart dependencies.
- `docs/FLUTTER_CONCEPTS.md` — implementation notes and links to these lessons.

The repository's application code is Flutter/Dart. Markdown and YAML files provide documentation and Flutter project configuration.
