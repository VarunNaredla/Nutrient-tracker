import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'experiment_theme.dart';
import 'nutrient_goals.dart';

void main() => runApp(ChangeNotifierProvider(
      create: (_) => NutrientGoals(),
      child: const GoalsExperiment(),
    ));

class GoalsExperiment extends StatelessWidget {
  const GoalsExperiment({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: experimentTheme(),
        home: const GoalsPage(),
      );
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Daily goals')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const GoalSummary(label: 'Today'),
            const GoalSummary(label: 'Insights'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.read<NutrientGoals>().updateCalories(2200),
              child: const Text('Set goal to 2,200 kcal'),
            ),
            TextButton(
              onPressed: () => context.read<NutrientGoals>().updateCalories(2000),
              child: const Text('Reset demo'),
            ),
          ],
        ),
      );
}

class GoalSummary extends StatelessWidget {
  const GoalSummary({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final calories = context.watch<NutrientGoals>().calories;
    return NutrientCard(label: '$label · calorie goal', value: '$calories kcal');
  }
}
