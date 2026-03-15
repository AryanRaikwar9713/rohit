# OTP & Google Login – iOS Fixes

## Fixes applied (code)
- **GIDClientID** in Info.plist
- **CFBundleURLSchemes** (REVERSED_CLIENT_ID) for Firebase/Google callback
- **FIREBASE_IOS_CLIENT_ID** passed in Google Sign-In initialize on iOS
- **Firebase exception handling** for suspended/403/API key errors (clearer user message)
- **Phone number format** – no double `+` prefix

---

## 1. Google Sign-In on iOS

**Fix applied:** Added `GIDClientID` to `ios/Runner/Info.plist` with the iOS client ID from `GoogleService-Info.plist`.  
`CFBundleURLTypes` with REVERSED_CLIENT_ID was already set for Firebase/Google callback.

Agar phir bhi "user canceled" ya error aaye, check karo:
- Xcode me Signing & Capabilities theek hon
- Google Cloud Console me iOS OAuth client add ho (Bundle ID: com.anytimeott.live)

---

## 2. OTP (Firebase Phone Auth) on iOS

**Root cause:** Logs me dikh raha hai:
```text
Permission denied: Consumer 'api_key:AIzaSyCWjF4CG7ieCMDMG8rx1yPxSg8ll-GQj5Y' has been suspended.
```

Firebase/Google Cloud ka API key **suspended** hai, isliye OTP, Firebase Installations, etc. kaam nahi karenge. Android pe purana key/cache chal sakta hai; iOS pe naya request fail ho raha hai.

### Fix (Google Cloud Console)

1. [Google Cloud Console](https://console.cloud.google.com/) kholo
2. Project **streamit-laravel-flutter** select karo
3. **APIs & Services** → **Credentials** pe jao
4. API key `AIzaSyCWjF4CG7ieCMDMG8rx1yPxSg8ll-GQj5Y` dhundho
5. Agar **Restricted** ya **Suspended** hai:
   - Edit karo
   - API restrictions hatao / sahi APIs allow karo (Firebase, Firebase Installations, Identity Toolkit, etc.)
   - Billing / quotas check karo
6. Agar key recover nahi ho rahi to **naya API key** banao aur Firebase project me use karo
7. Naya `GoogleService-Info.plist` download karke `ios/Runner/` me replace karo

### iOS config (already done)

- `CFBundleURLSchemes` me REVERSED_CLIENT_ID add hai – reCAPTCHA / OTP callback ke liye
- OTP flow code theek hai; sirf Firebase API key fix karni hai

---

## Summary

| Issue            | Status | Action needed                          |
|------------------|--------|----------------------------------------|
| Google Sign-In   | Fixed  | `GIDClientID` add kar diya              |
| OTP login        | Blocked| Firebase API key unsuspend / replace   |
| vast-ads 401     | Normal | Unauthenticated user ke liye expected   |
