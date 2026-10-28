# Flutter and Dart Concepts

This repository is a Flutter app written in Dart. Its application entry point is `lib/main.dart`; that file starts the app with `runApp`, configures `MaterialApp`, and builds the tracker screens as Flutter widgets.

## Implementation overview

- Material widgets provide navigation, forms, cards, and responsive layouts.
- Dart state holds daily meals, water counts, selected dates, and nutrient goals.
- The app serializes that state and stores it locally with `shared_preferences`.
- Food and goal forms validate user input before changing the saved state.
- Storage failures are reported in the interface so changes are not silently treated as saved.
- The original browser implementation has been removed; the app has no JavaScript, CSS, or HTML source files.

## Learning series

The README follows the eight-experiment sequence with output images. Each example has a separate Dart entry point under `experiments/`:

| Experiment | Concept | NutriDay example |
| --- | --- | --- |
| 1 | Dart values, nullable types, arithmetic, and functions | Greek yogurt: 280 kcal + 120 kcal = 400 kcal |
| 2 | Row, Column, and Stack | Daily energy, hydration, and a food card |
| 3 | MediaQuery and width breakpoints | Compact, tablet, and desktop nutrient layouts |
| 4 | Named routes and Navigator | Today and Insights pages |
| 5 | StatefulWidget, StatelessWidget, setState, and Provider | Local water counter and shared calorie goal |
| 6 | Custom widgets and ThemeData | Reusable nutrient tiles with consistent styling |
| 7 | Form, validation, and SnackBar error handling | Add-food form and a simulated save failure |
| 8 | AnimationController, FadeTransition, and SlideTransition | Animated daily summary with replay |

Open [Experiments 1–8](../README.md#experiments-18) for the output previews and [run instructions](../README.md#run-the-app-or-an-experiment).

The README embeds the uploaded JPEG slides in `docs/slides/readme/`. Their editable SVG sources are in `outputs/`. These are illustrative previews of the experiment output, not captured Flutter screenshots. They contain interface content and terminal output rather than code listings or explanatory slide text.

The experiments are isolated from the main app. Named routes, Provider state, and the replayable animation demonstrate the lesson concepts without changing the tracker's navigation, persistence, or state model. Experiment 7 deliberately offers a simulated save failure so validation and recovery can be exercised without a backend.
