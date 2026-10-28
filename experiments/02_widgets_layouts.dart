import 'package:flutter/material.dart';

import 'experiment_theme.dart';

void main() => runApp(const WidgetsExperiment());

class WidgetsExperiment extends StatelessWidget {
  const WidgetsExperiment({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: experimentTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('Today')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Daily energy', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NutrientCard(label: 'Calories', value: '400 kcal'),
                  ),
                  Expanded(
                    child: NutrientCard(label: 'Water', value: '2 / 8 glasses'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Breakfast', style: TextStyle(fontSize: 22)),
              Card(
                child: ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(child: Icon(Icons.restaurant)),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: nutriGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  title: const Text('Greek yogurt'),
                  subtitle: const Text('Protein 20.5 g'),
                  trailing: const Text('280 kcal'),
                ),
              ),
            ],
          ),
        ),
      );
}
