# WAMIMS – Performance tips

## Run faster (less lag)

1. **Release build** (recommended for testing “real” speed):
   ```bash
   flutter run --release
   ```
   Or build APK and install:
   ```bash
   flutter build apk --release
   ```

2. **Profile build** (good balance of speed + debugging):
   ```bash
   flutter run --profile
   ```

Debug build is slower; use `--release` or `--profile` when you want to feel app speed.

## Already done in code

- **Social feed:** `RepaintBoundary` on each feed item to reduce repaints.
- **Logs:** Debug `print`/`log` guarded with `kDebugMode` so release builds don’t do extra I/O.
- **Startup:** Removed redundant `testApiWithDifferentUser()` call on Social screen load.

## Android release

- `minifyEnabled true` and `shrinkResources true` are set for release in `android/app/build.gradle`.
- Use **Release** or **Profile** when measuring or demoing performance.
