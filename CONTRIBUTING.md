# Contributing

Thanks for helping improve `full_width_dropdown_button`.

## Before you start

For bugs and feature requests, open an issue first when the change is non-trivial. A small reproduction or example makes behavior issues much easier to review.

## Development setup

The package currently supports Dart `>=3.3.0 <4.0.0` and Flutter `>=3.19.0`.

```bash
git clone https://github.com/itskdey/full_width_dropdown_button.git
cd full_width_dropdown_button
flutter pub get
flutter test
flutter analyze
```

Format changed Dart files before opening a pull request:

```bash
dart format lib test example/lib
```

## Pull requests

Keep pull requests focused and easy to review.

- Explain the problem and the approach taken.
- Add or update tests for behavior changes.
- Update documentation when the public API or behavior changes.
- Add an entry to `CHANGELOG.md` for user-visible release changes.
- Avoid unrelated refactors in the same pull request.
- Do not bump the package version unless the change is specifically preparing a release.

CI should pass before a pull request is merged.

## Reporting bugs

Include, when relevant:

- Flutter and Dart versions
- Target platform
- Minimal reproduction code
- Expected behavior
- Actual behavior
- Screenshots, video, logs, or stack traces

## Feature requests

Describe the use case before the proposed API. This helps keep the package small and makes it easier to evaluate whether a feature belongs in the core widget.
