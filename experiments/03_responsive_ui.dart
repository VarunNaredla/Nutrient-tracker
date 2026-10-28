import 'package:flutter/material.dart';

import 'experiment_theme.dart';

void main() => runApp(const ResponsiveExperiment());

class ResponsiveExperiment extends StatelessWidget {
  const ResponsiveExperiment({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: experimentTheme(),
        home: const ResponsiveDashboard(),
      );
}

class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 600 ? 1 : (width < 1000 ? 2 : 4);

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: GridView(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 150,
            ),
            children: const [
              NutrientCard(label: 'Calories', value: '400 kcal'),
              NutrientCard(label: 'Protein', value: '20.5 g'),
              NutrientCard(label: 'Carbs', value: '42 g'),
              NutrientCard(label: 'Fat', value: '12 g'),
            ],
          ),
        ),
      ),
    );
  }
}
