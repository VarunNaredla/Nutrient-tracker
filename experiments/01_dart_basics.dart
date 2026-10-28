// Run with: dart run experiments/01_dart_basics.dart
int addCalories(int first, int second) {
  return first + second;
}

void main() {
  final foodName = 'Greek yogurt';
  int calories = 280;
  double proteinGrams = 20.5;
  String? note;
  const dailyGoal = 2000;

  final total = addCalories(calories, 120);
  final remaining = dailyGoal - total;
  final withinGoal = total <= dailyGoal;

  print(foodName);
  print('Calories: $calories kcal');
  print('Protein: $proteinGrams g');
  print('Note: ${note ?? 'No note'}');
  print('Total: $total kcal');
  print('Remaining: $remaining kcal');
  if (withinGoal) {
    print('Within daily goal');
  } else {
    print('Daily goal exceeded');
  }
}
