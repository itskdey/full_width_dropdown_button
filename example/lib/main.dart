import 'package:flutter/material.dart';
import 'package:full_width_dropdown_button/full_width_dropdown_button.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
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
      appBar: AppBar(
        title: const Text(
          'Dropdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        children: [
          const Text(
            'Full Width Dropdown Button',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simple dropdowns with nested items and smart positioning.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          _sectionTitle(
            title: 'Rich dropdown',
            subtitle: 'Nested items and custom actions.',
          ),
          const SizedBox(height: 12),
          _buildCard(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Choose a category',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                FullWidthDropdownButton.rich(
                  width: 45,
                  height: 45,
                  openIconColor: Colors.white,
                  dropdownItems: const [
                    DropdownItem(
                      label: 'Food type',
                      leading: Icon(
                        Icons.restaurant_outlined,
                        size: 17,
                      ),
                      subItems: [
                        DropdownSubItem(label: 'Soup'),
                        DropdownSubItem(label: 'Grill'),
                        DropdownSubItem(label: 'Stir-fry'),
                      ],
                    ),
                    DropdownItem(
                      label: 'Meat',
                      leading: Icon(
                        Icons.lunch_dining_outlined,
                        size: 17,
                      ),
                      subItems: [
                        DropdownSubItem(label: 'Beef'),
                        DropdownSubItem(label: 'Chicken'),
                        DropdownSubItem(label: 'Pork'),
                      ],
                    ),
                    DropdownItem(
                      label: 'Popular',
                      leading: Icon(
                        Icons.local_fire_department_outlined,
                        size: 17,
                      ),
                    ),
                    DropdownItem(
                      label: 'Clear all',
                      isDestructible: true,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                      ),
                    ),
                  ],
                  onItemSelected: (parent, sub) {
                    setState(() {
                      _selected = sub == null ? parent : '$parent · $sub';
                    });
                  },
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(_selected),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selected,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle(
            title: 'Smart position',
            subtitle: 'Opens upward when space is limited.',
          ),
          const SizedBox(height: 12),
          _buildCard(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sort by',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Select sorting order',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                FullWidthDropdownButton(
                  width: 44,
                  height: 44,
                  items: const [
                    'Newest',
                    'Oldest',
                    'Popular',
                  ],
                  onSelected: (value) {
                    setState(() => _selected = value);
                  },
                  child: Icon(
                    Icons.swap_vert_rounded,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }
}
