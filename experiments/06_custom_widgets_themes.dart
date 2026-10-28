import 'package:flutter/material.dart';

import 'experiment_theme.dart';

void main() => runApp(const CustomWidgetsExperiment());

class CustomWidgetsExperiment extends StatelessWidget {
  const CustomWidgetsExperiment({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: experimentTheme().copyWith(
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Nutrients')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              NutrientTile(label: 'Protein', value: 20.5, icon: Icons.egg_outlined),
              NutrientTile(label: 'Carbs', value: 42, icon: Icons.grain),
              NutrientTile(label: 'Fat', value: 12, icon: Icons.water_drop_outlined),
            ],
          ),
        ),
      );
}

class NutrientTile extends StatelessWidget {
  const NutrientTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(label, style: Theme.of(context).textTheme.titleMedium),
          trailing: Text('${value.toStringAsFixed(0)} g'),
        ),
      );
}
