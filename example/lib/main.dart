import 'package:flutter/material.dart';
import 'package:full_width_dropdown_button/full_width_dropdown_button.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String _selected = 'Nothing selected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Width Dropdown')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(_selected, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: FullWidthDropdownButton.rich(
              width: 52,
              height: 52,
              dropdownItems: const [
                DropdownItem(
                  label: 'Food type',
                  leading: Icon(Icons.restaurant_rounded, size: 16),
                  subItems: ['Soup', 'Grill', 'Stir-fry'],
                ),
                DropdownItem(
                  label: 'Meat',
                  leading: Icon(Icons.lunch_dining_rounded, size: 16),
                  subItems: [
                    DropdownSubItem(label: 'Beef'),
                    DropdownSubItem(label: 'Chicken'),
                    DropdownSubItem(label: 'Pork'),
                  ],
                ),
                DropdownItem(
                  label: 'Popular',
                  leading: Icon(Icons.local_fire_department_rounded, size: 16),
                ),
                DropdownItem(
                  label: 'Clear all',
                  isDestructible: true,
                  leading: Icon(Icons.delete_outline_rounded, size: 16),
                ),
              ],
              onItemSelected: (parent, sub) {
                setState(() {
                  _selected = sub == null ? parent : '$parent > $sub';
                });
              },
              child: const Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(height: 700),
          const Text(
            'This second trigger demonstrates automatic upward placement near '
            'the bottom of the screen.',
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FullWidthDropdownButton(
              width: 52,
              height: 52,
              items: const ['Newest', 'Oldest', 'Popular'],
              onSelected: (value) => setState(() => _selected = value),
              child: const Icon(Icons.sort_rounded),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
