import 'package:flutter/foundation.dart';

class NutrientGoals extends ChangeNotifier {
  int _calories = 2000;

  int get calories => _calories;

  void updateCalories(int value) {
    if (value <= 0 || value == _calories) return;
    _calories = value;
    notifyListeners();
  }
}
