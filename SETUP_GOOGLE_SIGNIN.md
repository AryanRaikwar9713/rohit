# Firebase Sign-In Fix (Phone OTP + Google Sign-In)

## Error: "This request is missing a valid app identifier – Play Integrity checks, reCAPTCHA checks were unsuccessful"

**Ye error dono pe aa sakta hai:**
- Phone number se OTP login
- Google Sign-In

**Reason:** App ka **SHA-1 fingerprint** Firebase / Google Console mein add nahi hai. Naya machine, reinstall, ya different keystore use karne par SHA-1 change ho jata hai.

---

## Also: "Developer console is not set up correctly" (Error 28444)

Same fix – SHA-1 Firebase aur Google Cloud mein add karo.

## Fix (do these in order)

### 1. Get your SHA-1 fingerprint

**Option A – Terminal:**
```bash
cd android && ./gradlew signingReport
```
Under `Variant: debug`, copy the **SHA-1** value (format: `XX:XX:XX:...`).

**Option B – Android Studio:**
1. Android Studio mein project open karo
2. Right panel → **Gradle** → **android** → **Tasks** → **android** → **signingReport** double-click
3. Run window mein **SHA-1** copy karo

**Release (for Play Store build):**  
Use the SHA-1 of the keystore you use to sign the release APK (same command if release keystore is configured in `build.gradle`).

### 2. Add SHA-1 in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/) → your project.
2. Go to **Project settings** (gear icon) → **Your apps**.
3. Select the **Android** app with package name: `com.anytimeott.live`.
4. Click **Add fingerprint** and paste the **SHA-1** (debug and/or release).
5. Save. Download the new `google-services.json` if prompted and replace `android/app/google-services.json`.

### 3. Google Cloud Console (OAuth client)

1. Open [Google Cloud Console](https://console.cloud.google.com/) → same project as Firebase.
2. **APIs & Services** → **Credentials**.
3. Under **OAuth 2.0 Client IDs** there should be an **Android** client for this app.
4. Open it and ensure:
   - **Package name:** `com.anytimeott.live`
   - **SHA-1 certificate fingerprint:** same SHA-1 you added in Firebase.
5. If there is no Android client, click **Create Credentials** → **OAuth client ID** → Application type **Android** → enter package name and SHA-1.

### 4. Server client ID (optional, for backend)

- In `google-services.json`, find the object with `"client_type": 3` (Web client).
- Copy its `client_id` and set it in `lib/configs.dart` as `FIREBASE_SERVER_CLIENT_ID` (already used for server auth).

### 5. Rebuild the app

After updating SHA-1 and `google-services.json`:

```bash
flutter clean
flutter pub get
flutter run -d <your_device_id>
```

**Note:** Firebase mein SHA-1 add karne ke baad 5–10 minutes wait karo (propagation time). Uske baad app restart karo.

---

**Summary:** "Missing app identifier" / Play Integrity error = **SHA-1** Firebase + Google Cloud mein add karo. Phone OTP aur Google Sign-In dono fix ho jayenge.
