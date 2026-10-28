import 'package:flutter/material.dart';

import 'experiment_theme.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: experimentTheme(),
      home: const WaterCounter(),
    ));

class WaterCounter extends StatefulWidget {
  const WaterCounter({super.key});

  @override
  State<WaterCounter> createState() => _WaterCounterState();
}

class _WaterCounterState extends State<WaterCounter> {
  int glasses = 2;
  static const goal = 8;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Water')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, color: nutriGreen, size: 64),
              Text('$glasses / $goal glasses',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: glasses < goal ? () => setState(() => glasses++) : null,
                icon: const Icon(Icons.add),
                label: const Text('Add a glass'),
              ),
              TextButton(
                onPressed: () => setState(() => glasses = 2),
                child: const Text('Reset demo'),
              ),
            ],
          ),
        ),
      );
}
