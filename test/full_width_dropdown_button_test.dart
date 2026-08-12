import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:full_width_dropdown_button/full_width_dropdown_button.dart';

void main() {
  testWidgets('opens and selects a simple item', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FullWidthDropdownButton(
            items: const ['One', 'Two'],
            onSelected: (value) => selected = value,
            child: const Icon(Icons.menu),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);

    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    expect(selected, 'Two');
    expect(find.text('One'), findsNothing);
  });

  testWidgets('expands a rich submenu and returns parent plus child',
      (tester) async {
    String? parent;
    String? child;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FullWidthDropdownButton.rich(
            dropdownItems: const [
              DropdownItem(label: 'Food', subItems: ['Soup', 'Grill']),
            ],
            onItemSelected: (p, s) {
              parent = p;
              child = s;
            },
            child: const Icon(Icons.filter_alt),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.filter_alt));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(find.text('Soup'), findsOneWidget);

    await tester.tap(find.text('Soup'));
    await tester.pumpAndSettle();

    expect(parent, 'Food');
    expect(child, 'Soup');
  });

  testWidgets('requires child or iconAsset', (tester) async {
    expect(
      () => FullWidthDropdownButton(
        items: const ['One'],
        onSelected: (_) {},
      ),
      throwsAssertionError,
    );
  });
}
