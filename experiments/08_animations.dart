import 'package:flutter/material.dart';

import 'experiment_theme.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: experimentTheme(),
      home: const AnimatedSummary(),
    ));

class AnimatedSummary extends StatefulWidget {
  const AnimatedSummary({super.key});

  @override
  State<AnimatedSummary> createState() => _AnimatedSummaryState();
}

class _AnimatedSummaryState extends State<AnimatedSummary>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> opacity;
  late final Animation<Offset> position;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    position = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(curve);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Daily summary')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: opacity,
                child: SlideTransition(
                  position: position,
                  child: const NutrientCard(label: 'Daily energy', value: '400 kcal'),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => controller.forward(from: 0),
                icon: const Icon(Icons.replay),
                label: const Text('Replay'),
              ),
            ],
          ),
        ),
      );
}
