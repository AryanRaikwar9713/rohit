# iOS run karne ka simple fix (step-by-step)

App iPhone par tabhi chalegi jab **Apple ID Xcode me sahi se sign-in ho**. Yeh steps follow karo:

---

## Step 1: Xcode kholo

Terminal me yeh type karo (ya is file ke saath diya script run karo):

```bash
open "/Users/aryanraikwar/flutter_projects/england kole/wamims/ios/Runner.xcworkspace"
```

Xcode khul jayega with your app project.

---

## Step 2: Apple ID theek karo

1. Xcode me **top menu** se jao: **Xcode** → **Settings…** (ya **Preferences…**).
2. **Accounts** tab pe click karo.
3. Left side me **Apple IDs** list dikhegi.
   - Agar **babubhiya94@gmail.com** dikhe aur red / error ho:
     - Us account pe click karo.
     - Neeche **"−" (minus)** button se use **remove** karo.
     - Phir **"+"** button dabao aur **Apple ID add** karo:
       - Email: **babubhiya94@gmail.com** (ya jo bhi use karte ho)
       - Password daalo
       - Agar 2FA (two-factor) aaye to phone pe code daalo
     - Sign-in complete hone do.
   - Agar koi **dusra Apple ID** use karna ho (jiska password sahi hai), woh add karo.

---

## Step 3: App ke liye Team select karo

1. Xcode me **left side** se **Runner** (blue app icon) pe **ek click** karo.
2. **Upar** **Signing & Capabilities** tab kholo.
3. **Team** wale dropdown me jao:
   - Agar **"None"** ya **"Add an account…"** dikhe to dropdown kholo.
   - Apna **Team** choose karo (naam ya **S5P9PXJ4TV** jaisa).
   - **"Automatically manage signing"** **tick** rehna chahiye.

---

## Step 4: iPhone par app run karo

Terminal me wapas jao aur yeh chalao:

```bash
cd "/Users/aryanraikwar/flutter_projects/england kole/wamims"
flutter run -d iphone --no-pub
```

iPhone **cable se connect** rehna chahiye (ya same Wi‑Fi pe).

---

## Agar phir bhi error aaye

- **"Rejected" / "Could not sign in"**  
  → Password galat ho sakta hai. Apple ID password reset karo: [appleid.apple.com](https://appleid.apple.com)  
- **"No profiles for com.anytimeott.live"**  
  → Step 3 me **Team** zaroor select karo; **Automatically manage signing** ON rehne do.
