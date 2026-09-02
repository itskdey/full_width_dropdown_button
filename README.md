# Full Width Dropdown Button

[![pub package](https://img.shields.io/pub/v/full_width_dropdown_button.svg)](https://pub.dev/packages/full_width_dropdown_button)
[![CI](https://github.com/itskdey/full_width_dropdown_button/actions/workflows/ci.yml/badge.svg)](https://github.com/itskdey/full_width_dropdown_button/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A polished, animated full-width dropdown for Flutter with nested submenus, smart overlay positioning, rich leading widgets, hover feedback, and smooth motion.

<p align="center">
  <img src="https://raw.githubusercontent.com/itskdey/full_width_dropdown_button/main/screenshots/screenshot-preview.webp" alt="Full Width Dropdown Button preview" width="320">
</p>

## Features

- Full-width overlay menu with configurable trigger size
- Opens below first and flips above only when space is limited
- Tracks the trigger while the page scrolls
- Simple string API and rich nested-item API
- Animated nested submenus
- Widget-based leading content for icons, SVGs, avatars, and more
- Destructive parent and sub-items
- Mouse hover feedback for desktop and web
- Haptic feedback on supported platforms
- Custom trigger widget or SVG asset trigger
- Scale, fade, slide, and expansion animations

## Installation

```yaml
dependencies:
  full_width_dropdown_button: ^0.2.4
```

Then import the package:

```dart
import 'package:full_width_dropdown_button/full_width_dropdown_button.dart';
```

## Quick start

```dart
FullWidthDropdownButton(
  child: const Icon(Icons.tune_rounded),
  items: const ['Newest', 'Oldest', 'Popular'],
  onSelected: (value) {
    debugPrint(value);
  },
)
```

## Rich nested menu

Use `FullWidthDropdownButton.rich` when you need leading widgets, submenus, or destructive actions.

```dart
FullWidthDropdownButton.rich(
  child: const Icon(Icons.filter_alt_rounded),
  dropdownItems: [
    const DropdownItem(
      label: 'Food type',
      leading: Icon(Icons.restaurant_rounded, size: 16),
      subItems: ['Soup', 'Grill', 'Stir-fry'],
    ),
    const DropdownItem(
      label: 'Meat',
      leading: Icon(Icons.lunch_dining_rounded, size: 16),
      subItems: [
        DropdownSubItem(label: 'Beef'),
        DropdownSubItem(label: 'Chicken'),
        DropdownSubItem(label: 'Remove filter', isDestructible: true),
      ],
    ),
    const DropdownItem(label: 'Popular'),
    const DropdownItem(
      label: 'Clear all',
      isDestructible: true,
      leading: Icon(Icons.delete_outline_rounded, size: 16),
    ),
  ],
  onItemSelected: (parent, sub) {
    debugPrint(sub == null ? parent : '$parent > $sub');
  },
)
```

## SVG trigger

```dart
FullWidthDropdownButton(
  iconAsset: 'assets/filter.svg',
  items: const ['A', 'B', 'C'],
  onSelected: debugPrint,
)
```

Register the SVG in your application's `pubspec.yaml` before using it as an asset trigger.

## Customize the trigger

```dart
FullWidthDropdownButton.rich(
  width: 52,
  height: 52,
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(100),
  ),
  openDecoration: BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(100),
  ),
  iconColor: Colors.grey,
  openIconColor: Colors.white,
  child: const Icon(Icons.menu_rounded),
  dropdownItems: const [DropdownItem(label: 'Option')],
  onItemSelected: (parent, sub) {},
)
```

### Main options

| Option | Purpose |
| --- | --- |
| `child` | Custom trigger widget |
| `iconAsset` | SVG asset used as the trigger when `child` is not supplied |
| `width` / `height` | Trigger dimensions |
| `padding` | Trigger content padding |
| `decoration` | Trigger decoration while closed |
| `openDecoration` | Trigger decoration while the menu is open |
| `iconColor` / `openIconColor` | Trigger icon colors for closed/open states |
| `selectedItem` | Current selected label passed to the menu |
| `onClose` | Callback fired when an open dropdown closes |

The default constructor accepts `List<String>`. The `.rich` constructor accepts `List<DropdownItem>` and reports both the parent and optional child value.

## Overlay behavior

The menu uses the current screen width with a 16 px horizontal margin. It initially measures only the collapsed parent rows, which keeps the dropdown down-first instead of flipping upward just because a submenu could expand later.

Because the menu is rendered in an `Overlay` and attached with a `LayerLink`, it continues following its trigger while the surrounding page scrolls.

## Platform notes

The widget uses standard Flutter overlay and pointer APIs, so it is suitable for mobile, web, and desktop Flutter applications. Hover feedback is naturally most useful on mouse-based platforms, while haptics depend on platform support.

## Contributing

Bug reports and feature ideas are welcome in [GitHub Issues](https://github.com/itskdey/full_width_dropdown_button/issues). For code contributions, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
