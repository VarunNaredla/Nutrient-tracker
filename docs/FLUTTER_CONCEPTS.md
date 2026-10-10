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

The README contains the seven Flutter learning slides with explanations and Dart examples:

1. Dart basics
2. Flutter widgets and layouts
3. Responsive UI
4. Navigation and named routes
5. Stateful and stateless widgets with state management
6. Custom widgets and themes
7. Forms, validation, and error handling

Open [the Flutter learning slides](../README.md#flutter-learning-slides) for the lesson notes and examples.
