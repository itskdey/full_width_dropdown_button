# Publishing

Use this checklist when preparing a new `full_width_dropdown_button` release.

## 1. Prepare the release

- Update `version` in `pubspec.yaml`.
- Add the release notes to `CHANGELOG.md`.
- Update the README installation example when the public version changes.
- Make sure the example and screenshots still reflect the current API.

## 2. Run local checks

From the package root:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
dart pub publish --dry-run
```

Resolve errors and review any publish warnings before continuing.

## 3. Publish

```bash
dart pub publish
```

## 4. Tag the release

After pub.dev accepts the release:

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

Use the same version number in `pubspec.yaml`, `CHANGELOG.md`, pub.dev, and the Git tag.
