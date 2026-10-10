import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NutriDayApp());

const _green = Color(0xFF426B50);
const _ink = Color(0xFF25332A);
const _muted = Color(0xFF7C897F);
const _paper = Color(0xFFF7F8F4);
const _line = Color(0xFFE8ECE5);

const _defaultGoals = <String, double>{
  'calories': 2000,
  'protein': 100,
  'carbs': 250,
  'fat': 70,
  'fiber': 28,
  'water': 8,
};

const _sampleMeals = <Map<String, dynamic>>[
  {'name': 'Greek yogurt with berries', 'meal': 'Breakfast', 'calories': 280, 'protein': 20, 'carbs': 34, 'fat': 6, 'fiber': 5, 'emoji': '🥣'},
  {'name': 'Avocado toast', 'meal': 'Breakfast', 'calories': 320, 'protein': 12, 'carbs': 38, 'fat': 14, 'fiber': 8, 'emoji': '🥑'},
  {'name': 'Grilled chicken salad', 'meal': 'Lunch', 'calories': 480, 'protein': 38, 'carbs': 32, 'fat': 21, 'fiber': 7, 'emoji': '🥗'},
  {'name': 'Apple', 'meal': 'Snack', 'calories': 104, 'protein': 1, 'carbs': 28, 'fat': 0, 'fiber': 5, 'emoji': '🍎'},
];

class NutriDayApp extends StatelessWidget {
  const NutriDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: _green, brightness: Brightness.light);
    return MaterialApp(
      title: 'NutriDay — Nutrient Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _paper,
        appBarTheme: const AppBarTheme(backgroundColor: _paper, foregroundColor: _ink, elevation: 0),
        cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: _line))),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9F6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _line)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _line)),
        ),
      ),
      home: const TrackerHome(),
    );
  }
}

class TrackerHome extends StatefulWidget {
  const TrackerHome({super.key});

  @override
  State<TrackerHome> createState() => _TrackerHomeState();
}

class _TrackerHomeState extends State<TrackerHome> {
  static const _storageKey = 'nutriday-v2';
  int _page = 0;
  DateTime _selectedDate = DateTime.now();
  Map<String, double> _goals = Map<String, double>.from(_defaultGoals);
  Map<String, Map<String, dynamic>> _days = {};
  bool _loading = true;

  String get _dateKey => _keyFor(_selectedDate);
  String _keyFor(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> get _day => _days.putIfAbsent(_dateKey, () => {'water': 0, 'meals': <Map<String, dynamic>>[]});

  List<Map<String, dynamic>> get _meals {
    final raw = _day['meals'] as List<dynamic>? ?? [];
    return raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  double _value(Map<String, dynamic> meal, String key) => (meal[key] as num?)?.toDouble() ?? 0;

  double _total(String key) => _meals.fold<double>(0, (sum, meal) => sum + _value(meal, key));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final data = jsonDecode(saved) as Map<String, dynamic>;
        final savedGoals = Map<String, dynamic>.from(data['goals'] as Map? ?? {});
        final savedDays = Map<String, dynamic>.from(data['days'] as Map? ?? {});
        _goals = {..._defaultGoals, for (final entry in savedGoals.entries) entry.key: (entry.value as num).toDouble()};
        _days = {
          for (final entry in savedDays.entries)
            entry.key: Map<String, dynamic>.from(entry.value as Map)
              ..['meals'] = (entry.value['meals'] as List<dynamic>? ?? []).map((meal) => Map<String, dynamic>.from(meal as Map)).toList()
        };
      } else {
        _days[_keyFor(DateTime.now())] = {'water': 5, 'meals': _sampleMeals.map((meal) => Map<String, dynamic>.from(meal)).toList()};
      }
    } catch (_) {
      _days[_keyFor(DateTime.now())] = {'water': 5, 'meals': _sampleMeals.map((meal) => Map<String, dynamic>.from(meal)).toList()};
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(
        _storageKey,
        jsonEncode({'goals': _goals, 'days': _days}),
      );
      if (!saved) throw StateError('Local storage did not confirm the save.');
      return true;
    } catch (error) {
      debugPrint('NutriDay could not save local data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not save locally. Your change is still visible for now.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Retry', onPressed: () => _save()),
          ),
        );
      }
      return false;
    }
  }

  String get _dateLabel {
    final today = DateTime.now();
    if (_keyFor(today) == _dateKey) return 'Today, ${_month(_selectedDate.month)} ${_selectedDate.day}';
    return '${_month(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  String _month(int month) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];

  void _changeDate(int offset) => setState(() => _selectedDate = _selectedDate.add(Duration(days: offset)));

  void _notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }

  Future<void> _addWater() async {
    if ((_day['water'] as int? ?? 0) >= _goals['water']!) {
      _notify('You’ve reached your water goal for this day.');
      return;
    }
    setState(() => _day['water'] = (_day['water'] as int? ?? 0) + 1);
    if (!await _save()) return;
    _notify('Water logged.');
  }

  Future<void> _addFood() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final calories = TextEditingController();
    final protein = TextEditingController(text: '0');
    final carbs = TextEditingController(text: '0');
    final fat = TextEditingController(text: '0');
    final fiber = TextEditingController(text: '0');
    String mealType = 'Breakfast';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add something good'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(controller: name, maxLength: 48, decoration: const InputDecoration(labelText: 'Food name', hintText: 'e.g. Avocado toast'), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a food name' : null),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: mealType,
                    decoration: const InputDecoration(labelText: 'Meal'),
                    items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                    onChanged: (value) => setDialogState(() => mealType = value ?? 'Breakfast'),
                  ),
                  const SizedBox(height: 10),
                  _numberField(calories, 'Calories', requiredField: true),
                  _numberField(protein, 'Protein (g)'),
                  _numberField(carbs, 'Carbohydrates (g)'),
                  _numberField(fat, 'Fat (g)'),
                  _numberField(fiber, 'Fiber (g)'),
                ]),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.pop(dialogContext, {
                  'name': name.text.trim(),
                  'meal': mealType,
                  'calories': double.tryParse(calories.text) ?? 0,
                  'protein': double.tryParse(protein.text) ?? 0,
                  'carbs': double.tryParse(carbs.text) ?? 0,
                  'fat': double.tryParse(fat.text) ?? 0,
                  'fiber': double.tryParse(fiber.text) ?? 0,
                  'emoji': switch (mealType) {'Breakfast' => '🍳', 'Lunch' => '🥗', 'Dinner' => '🍲', _ => '🍎'},
                });
              },
              child: const Text('Add to my day'),
            ),
          ],
        ),
      ),
    );
    for (final controller in [name, calories, protein, carbs, fat, fiber]) {
      controller.dispose();
    }
    if (result == null || !mounted) return;
    setState(() => (_day['meals'] as List<dynamic>).add(result));
    if (!await _save()) return;
    _notify('Added to your food journal.');
  }

  TextFormField _numberField(TextEditingController controller, String label, {bool requiredField = false}) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
    validator: (value) {
      final input = (value ?? '').trim();
      if (input.isEmpty) return requiredField ? 'Enter a value' : null;
      final number = double.tryParse(input);
      if (number == null) return 'Enter a valid number';
      if (number < 0) return 'Value cannot be negative';
      return null;
    },
  );

  Future<void> _removeFood(int index) async {
    setState(() => (_day['meals'] as List<dynamic>).removeAt(index));
    if (!await _save()) return;
    _notify('Food removed from your journal.');
  }

  Future<void> _editGoals() async {
    final formKey = GlobalKey<FormState>();
    final controllers = <String, TextEditingController>{
      for (final entry in _goals.entries)
        entry.key: TextEditingController(text: entry.value.toStringAsFixed(0)),
    };
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your daily goals'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _goalEditor(controllers['calories']!, 'Calories', 'kcal'),
                _goalEditor(controllers['protein']!, 'Protein', 'g'),
                _goalEditor(controllers['carbs']!, 'Carbohydrates', 'g'),
                _goalEditor(controllers['fat']!, 'Fat', 'g'),
                _goalEditor(controllers['fiber']!, 'Fiber', 'g'),
                _goalEditor(controllers['water']!, 'Water', 'glasses'),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final updated = <String, double>{
                for (final entry in controllers.entries)
                  entry.key: double.parse(entry.value.text.trim()),
              };
              Navigator.pop(dialogContext, updated);
            },
            child: const Text('Save goals'),
          ),
        ],
      ),
    );
    for (final controller in controllers.values) {
      controller.dispose();
    }
    if (result == null || !mounted) return;
    setState(() => _goals = result);
    if (!await _save()) return;
    _notify('Your goals have been updated.');
  }

  Widget _goalEditor(TextEditingController controller, String label, String unit) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: unit),
      validator: (value) {
        final input = (value ?? '').trim();
        if (input.isEmpty) return 'Enter a goal';
        final number = double.tryParse(input);
        if (number == null) return 'Enter a valid number';
        if (number <= 0) return 'Goal must be greater than zero';
        return null;
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 16, backgroundColor: Color(0xFFE6EEE4), child: Text('n', style: TextStyle(color: _green, fontWeight: FontWeight.w800))),
          SizedBox(width: 10),
          Text('nutriday', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ]),
        actions: [
          IconButton(tooltip: 'Previous day', onPressed: () => _changeDate(-1), icon: const Icon(Icons.chevron_left)),
          Text(_dateLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(tooltip: 'Next day', onPressed: () => _changeDate(1), icon: const Icon(Icons.chevron_right)),
          const SizedBox(width: 12),
          IconButton(tooltip: 'Edit goals', onPressed: _editGoals, icon: const Icon(Icons.tune)),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(child: _page == 0 ? _dashboard() : _page == 1 ? _insights() : _goalsPage()),
      floatingActionButton: _page == 0 ? FloatingActionButton.extended(onPressed: _addFood, icon: const Icon(Icons.add), label: const Text('Add food')) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (index) => setState(() => _page = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'My goals'),
        ],
      ),
    );
  }

  Widget _pagePadding(Widget child) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 96), child: child),
    ),
  );

  Widget _dashboard() => _pagePadding(ListView(
    children: [
      const Text('YOUR DAILY NUTRITION', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      const SizedBox(height: 7),
      Text('A little better, every day.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Here’s how your nutrition is shaping up.', style: TextStyle(color: _muted)),
      const SizedBox(height: 22),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth > 680;
        return Flex(
          direction: wide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide) Expanded(flex: 3, child: _calorieCard()) else _calorieCard(),
            if (!wide) const SizedBox(height: 14) else const SizedBox(width: 14),
            if (wide) Expanded(flex: 2, child: _waterCard()) else _waterCard(),
          ],
        );
      }),
      const SizedBox(height: 24),
      _sectionTitle('Macro balance', 'YOUR NUTRIENTS', trailing: TextButton(onPressed: () => setState(() => _page = 1), child: const Text('See insights  →'))),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final count = constraints.maxWidth > 800 ? 4 : constraints.maxWidth > 480 ? 2 : 1;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: count == 1 ? 2.5 : 1.35,
          children: [
            _nutrientCard('Protein', 'protein', 'g', const Color(0xFF558361), Icons.fitness_center),
            _nutrientCard('Carbs', 'carbs', 'g', const Color(0xFFB67D4D), Icons.grain),
            _nutrientCard('Fat', 'fat', 'g', const Color(0xFF628B98), Icons.water_drop_outlined),
            _nutrientCard('Fiber', 'fiber', 'g', const Color(0xFFAD706D), Icons.spa_outlined),
          ],
        );
      }),
      const SizedBox(height: 24),
      _sectionTitle('Today’s meals', 'FOOD JOURNAL', trailing: TextButton.icon(onPressed: _addFood, icon: const Icon(Icons.add, size: 18), label: const Text('Add food'))),
      const SizedBox(height: 8),
      Card(child: _meals.isEmpty
        ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No food logged for this day yet. Add a meal to get started.', style: TextStyle(color: _muted))))
        : Column(children: [
            for (var index = 0; index < _meals.length; index++) _mealRow(_meals[index], index),
          ])),
      const SizedBox(height: 18),
      const Card(child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('✳  TODAY’S NOTE', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          SizedBox(height: 10),
          Text('Build a colorful plate', style: TextStyle(color: _ink, fontWeight: FontWeight.w700, fontSize: 17)),
          SizedBox(height: 5),
          Text('A variety of colorful fruits and vegetables is an easy way to get more vitamins and minerals.', style: TextStyle(color: _muted)),
        ]),
      )),
    ],
  ));

  Widget _calorieCard() {
    final calories = _total('calories');
    final goal = _goals['calories']!;
    final progress = (calories / goal).clamp(0.0, 1.0).toDouble();
    return Card(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CALORIES', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 4),
        const Text('Daily energy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: _ink)),
        const SizedBox(height: 18),
        Row(children: [
          SizedBox(width: 132, height: 132, child: Stack(alignment: Alignment.center, children: [
            SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 10, backgroundColor: const Color(0xFFE9EEE7), color: _green, strokeCap: StrokeCap.round)),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_format(calories), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 23, color: _ink)),
              const Text('kcal eaten', style: TextStyle(fontSize: 11, color: _muted)),
            ]),
          ])),
          const SizedBox(width: 22),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _statLine('Eaten', _format(calories)),
            const SizedBox(height: 12),
            _statLine('Daily goal', _format(goal)),
            const SizedBox(height: 12),
            _statLine('Left for today', '${_format((goal - calories).clamp(0, double.infinity))} kcal'),
          ])),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: const Color(0xFFE9EEE7), color: _green)),
        const SizedBox(height: 7),
        Text('${(progress * 100).round()}% of your daily energy goal', style: const TextStyle(color: _muted, fontSize: 12)),
      ]),
    ));
  }

  Widget _waterCard() {
    final water = _day['water'] as int? ?? 0;
    final goal = _goals['water']!.round();
    return Card(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('HYDRATION', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 4),
        const Text('Water', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: _ink)),
        const SizedBox(height: 12),
        RichText(text: TextSpan(style: const TextStyle(color: _ink), children: [
          TextSpan(text: '$water', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
          TextSpan(text: ' / $goal glasses', style: const TextStyle(color: _muted, fontSize: 13)),
        ])),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: List.generate(goal.clamp(0, 20).toInt(), (index) => Icon(Icons.water_drop, size: 23, color: index < water ? const Color(0xFF79B4AE) : const Color(0xFFDCE6E3)))),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _addWater, icon: const Icon(Icons.add), label: const Text('Add glass'))),
      ]),
    ));
  }

  Widget _nutrientCard(String label, String key, String unit, Color color, IconData icon) {
    final value = _total(key);
    final goal = _goals[key]!;
    final progress = (value / goal).clamp(0.0, 1.0).toDouble();
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 15, backgroundColor: color.withOpacity(0.12), child: Icon(icon, size: 16, color: color)),
          const Spacer(),
          Text('${(progress * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
        const Spacer(),
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
        Text('${_format(value)} $unit', style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 3),
        Text('of ${_format(goal)} $unit goal', style: const TextStyle(color: _muted, fontSize: 11)),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 5, color: color, backgroundColor: color.withOpacity(0.12))),
      ]),
    ));
  }

  Widget _mealRow(Map<String, dynamic> meal, int index) => ListTile(
    leading: CircleAvatar(backgroundColor: const Color(0xFFF1F4EE), child: Text(meal['emoji'] as String? ?? '🍽️')),
    title: Text(meal['name'] as String? ?? 'Food', style: const TextStyle(fontWeight: FontWeight.w600, color: _ink)),
    subtitle: Text('${meal['meal'] ?? 'Meal'} · ${_format(_value(meal, 'protein'))}g protein'),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('${_format(_value(meal, 'calories'))} kcal', style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
      IconButton(tooltip: 'Remove food', onPressed: () => _removeFood(index), icon: const Icon(Icons.close, size: 18, color: _muted)),
    ]),
  );

  Widget _insights() => _pagePadding(ListView(children: [
    const Text('YOUR PROGRESS', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    const SizedBox(height: 7),
    Text('Nutrition insights.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
    const SizedBox(height: 5),
    const Text('A simple look at the habits you’re building.', style: TextStyle(color: _muted)),
    const SizedBox(height: 20),
    LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth > 720 ? 3 : 1;
      return GridView.count(
        crossAxisCount: count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: count == 1 ? 3.2 : 1.8,
        children: [
          _insightCard('ENERGY', '${_format(_total('calories'))} kcal', '${(_total('calories') / _goals['calories']! * 100).round()}% of your daily energy goal'),
          _insightCard('PROTEIN', '${_format(_total('protein'))} g', '${_format((_goals['protein']! - _total('protein')).clamp(0, double.infinity))} g to your daily goal'),
          _insightCard('WATER', '${_day['water']} glasses', '${((_goals['water']! - (_day['water'] as int)).clamp(0, double.infinity)).round()} more to reach your goal'),
        ],
      );
    }),
    const SizedBox(height: 18),
    Card(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('How you’re doing', 'DAILY BREAKDOWN'),
        const SizedBox(height: 14),
        _breakdown('Calories', 'calories', 'kcal'),
        _breakdown('Protein', 'protein', 'g'),
        _breakdown('Carbohydrates', 'carbs', 'g'),
        _breakdown('Fat', 'fat', 'g'),
        _breakdown('Fiber', 'fiber', 'g'),
        const SizedBox(height: 12),
        const Text('Progress is a guide, not a grade. Adjust your targets any time in My goals.', style: TextStyle(color: _muted, fontSize: 12)),
      ]),
    )),
  ]));

  Widget _insightCard(String label, String value, String note) => Card(child: Padding(
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 9),
      Text(value, style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 22)),
      Text(note, style: const TextStyle(color: _muted, fontSize: 12)),
    ]),
  ));

  Widget _breakdown(String label, String key, String unit) {
    final value = _total(key);
    final goal = _goals[key]!;
    final progress = (value / goal).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        SizedBox(width: 115, child: Text(label, style: const TextStyle(color: _ink, fontSize: 12))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: const Color(0xFFE9EEE7), color: _green))),
        const SizedBox(width: 12),
        Text('${_format(value)} / ${_format(goal)} $unit', style: const TextStyle(color: _muted, fontSize: 11)),
      ]),
    );
  }

  Widget _goalsPage() => _pagePadding(ListView(children: [
    const Text('PERSONAL PLAN', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    const SizedBox(height: 7),
    Text('Your daily goals.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _ink, fontWeight: FontWeight.w800)),
    const SizedBox(height: 5),
    const Text('Targets that feel right for you.', style: TextStyle(color: _muted)),
    const SizedBox(height: 20),
    Card(child: Column(children: [
      _goalTile('Calories', 'Energy to fuel your day', 'calories', 'kcal'),
      _goalTile('Protein', 'Supports muscles and recovery', 'protein', 'g'),
      _goalTile('Carbohydrates', 'Your body’s primary energy source', 'carbs', 'g'),
      _goalTile('Fat', 'Essential fuel and nutrient support', 'fat', 'g'),
      _goalTile('Fiber', 'Supports digestion and fullness', 'fiber', 'g'),
      _goalTile('Water', 'Aim for a steady rhythm', 'water', 'glasses'),
      Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _editGoals, icon: const Icon(Icons.edit_outlined), label: const Text('Edit my goals')))),
    ])),
  ]));

  Widget _goalTile(String title, String subtitle, String key, String unit) => ListTile(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
    subtitle: Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
    trailing: Text('${_format(_goals[key]!)} $unit', style: const TextStyle(color: _green, fontWeight: FontWeight.w700)),
  );

  Widget _sectionTitle(String title, String eyebrow, {Widget? trailing}) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(eyebrow, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 3),
      Text(title, style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w700)),
    ])),
    if (trailing != null) trailing,
  ]);

  Widget _statLine(String label, String value) => Row(children: [
    Expanded(child: Text(label, style: const TextStyle(color: _muted, fontSize: 12))),
    Text(value, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700, fontSize: 12)),
  ]);

  String _format(num value) => value.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
}
