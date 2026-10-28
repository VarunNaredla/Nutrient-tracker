import 'package:flutter/material.dart';

import 'experiment_theme.dart';

void main() => runApp(const NavigationExperiment());

class TrackerRoutes {
  static const today = '/';
  static const insights = '/insights';
}

class NavigationExperiment extends StatelessWidget {
  const NavigationExperiment({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: experimentTheme(),
        initialRoute: TrackerRoutes.today,
        routes: {
          TrackerRoutes.today: (_) => const TodayPage(),
          TrackerRoutes.insights: (_) => const InsightsPage(),
        },
      );
}

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Today')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const NutrientCard(label: 'Daily energy', value: '400 kcal'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, TrackerRoutes.insights),
              child: const Text('View insights'),
            ),
          ],
        ),
      );
}

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Insights')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const NutrientCard(label: 'Calories', value: '400 / 2,000 kcal'),
            const SizedBox(height: 16),
            const LinearProgressIndicator(value: 0.2),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to today'),
            ),
          ],
        ),
      );
}
