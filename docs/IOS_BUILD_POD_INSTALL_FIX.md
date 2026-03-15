# iOS build: pod install fails (StripePayments / git clone timeout)

## Error you saw

```
Error installing StripePayments
/usr/bin/git clone https://github.com/stripe/stripe-ios.git ...
error: RPC failed; curl 56 Recv failure: Operation timed out
fatal: early EOF
Error: Error running pod install
```

CocoaPods downloads the Stripe iOS SDK from GitHub during `pod install`. The clone can **time out** on slow or unstable networks.

---

## Fixes (try in order)

### 1. Increase Git buffer (already in Podfile)

The project Podfile now runs:
`git config --global http.postBuffer 524288000`
so the next `pod install` uses a larger buffer. **Run pod install again:**

```bash
cd "/Users/aryanraikwar/flutter_projects/england kole/wamims/ios"
pod install
```

If it still times out, run the same git config manually once, then retry:

```bash
git config --global http.postBuffer 524288000
pod install
```

### 2. Retry on better network

- Use a **stable Wi‑Fi** or **mobile hotspot** and run `pod install` again.
- Sometimes the **second run** succeeds (partial clone may be cached).

### 3. Clear CocoaPods cache and retry

```bash
cd "/Users/aryanraikwar/flutter_projects/england kole/wamims/ios"
pod cache clean --all
pod install
```

### 4. Run iOS with device ID (not “ios”)

`flutter run -d ios` can report “No supported devices found”. Use the **device ID** instead:

```bash
flutter run -d 00008140-000878192103801C
```

(Replace with your iPhone’s ID from `flutter devices`.)

---

## After pod install succeeds

```bash
cd "/Users/aryanraikwar/flutter_projects/england kole/wamims"
flutter run -d 00008140-000878192103801C
```

---

## Crashlytics warning (optional)

If you see:
`Project at .../england/Runner.xcodeproj does not exist`

That path is wrong (project is under `wamims`). It’s a Crashlytics upload-symbols script path. You can fix it in Xcode → Build Phases → “Upload Crashlytics symbols” script, or ignore it if you don’t use Crashlytics upload.
