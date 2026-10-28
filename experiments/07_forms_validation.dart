import 'package:flutter/material.dart';

import 'experiment_theme.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: experimentTheme(),
      home: const FoodForm(),
    ));

class FoodForm extends StatefulWidget {
  const FoodForm({super.key});

  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final calories = TextEditingController();
  bool failNextSave = false;
  bool saving = false;
  String? savedFood;

  // An in-memory lesson repository: no real meal log is written by this demo.
  Future<void> saveEntry() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (failNextSave) throw StateError('Demonstration storage failure');
  }

  Future<void> submit() async {
    if (saving || !formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await saveEntry();
      if (!mounted) return;
      setState(() => savedFood = '${name.text.trim()} · ${calories.text.trim()} kcal');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food saved in demo')),
      );
    } catch (_) {
      if (!mounted) return;
      // Keep the entered food visible; Retry succeeds after this one failure.
      setState(() => failNextSave = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Could not save. Try again.'),
        action: SnackBarAction(label: 'Retry', onPressed: submit),
      ));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    calories.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add food')),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: name,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Food name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a food name'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: calories,
                enabled: !saving,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Calories'),
                validator: (value) {
                  final number = double.tryParse((value ?? '').trim());
                  return number == null || !number.isFinite || number <= 0
                      ? 'Enter calories greater than 0'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Simulate one save failure'),
                value: failNextSave,
                onChanged: saving ? null : (value) => setState(() => failNextSave = value),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: saving ? null : submit,
                child: Text(saving ? 'Saving…' : 'Save food'),
              ),
              if (savedFood != null) ...[
                const SizedBox(height: 20),
                Card(child: ListTile(leading: const Icon(Icons.check), title: Text(savedFood!))),
              ],
            ],
          ),
        ),
      );
}
