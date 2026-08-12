# Publishing

The proposed pub.dev package name is `full_width_dropdown_button`.

The package already includes a `homepage` field. If you have a GitHub repository,
replace the homepage or add `repository` and `issue_tracker` URLs before publishing.

Version `0.1.1` is used so it can be published even if `0.1.0` was already uploaded.

Run from the package root:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
dart pub publish --dry-run
```

If the dry run is clean:

```bash
dart pub publish
```
