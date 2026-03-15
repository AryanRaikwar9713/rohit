# Notification Nahi AA Rahi – Checklist (Flutter + Firebase)

Flutter side **notification handling is implemented**: topic subscribe, FCM tap deep links, in-app list, badge. Agar notification **Firebase se bhi bhej rahe ho** par **device par nahi ja rahi**, ye points check karo.

---

## 1) Topic sahi hai?

- App har user ko topic **`user_<user_id>`** par subscribe karta hai (e.g. `user_5`).
- Firebase Console me "Message topic" me **exact same** topic dalo: `user_5` (number apna user ID).
- **Galat:** `aryan`, `user_aryan`, `User_5` (capital U). **Sahi:** `user_5`.

---

## 2) Device par app **subscribe** ho raha hai?

- Subscribe **login success ke baad** hota hai. Agar login nahi kiya ya session expire ho gaya to topic subscribe nahi hoga.
- Release APK me bhi subscribe run hota hai (same code).
- Check: Login karo → thodi der ruko → phir Firebase se usi topic par test notification bhejo.

---

## 3) Release build / ProGuard

- **Release APK** me agar ProGuard/R8 **Firebase / FCM** related classes ko strip/obfuscate kar raha ho to notification receive fail ho sakta hai.
- **Check:** `android/app/build.gradle` me `minifyEnabled true` hai to `proguard-rules.pro` me Firebase/FCM ke liye **keep rules** honi chahiye (Firebase docs ke hisaab se).
- Agar abhi bhi doubt ho to **debug APK** se test karo: agar debug me notification aa jati hai, release me na aaye to issue release build/ProGuard ki taraf hai.

---

## 4) Firebase project / App credentials

- Jo **Firebase project** use kar rahe ho (e.g. "maarket points") usi project me:
  - **Android app** add hai with **same package name** (e.g. `com.xyz.wamims`)?
  - **google-services.json** (Android) project ke andar latest hai aur app me `android/app/` me paste hai?
- Agar package name mismatch ho ya purana `google-services.json` ho to FCM silently fail ho sakta hai.

---

## 5) Device / OS

- **Battery optimization:** Kuch devices background me FCM ko kill kar dete hain. App ko "Unrestricted" / "Don’t optimize" do.
- **Data/Wi‑Fi:** Internet on ho.
- **Do device test:** Ek device par sender (dusra user) aur ek par receiver (jisko notification chahiye) – dono same Firebase project, same app version.

---

## 6) Flutter side – confirm kya working hai

| Cheez | Status |
|-------|--------|
| Login ke baad `user_<id>` topic subscribe | ✅ Implemented |
| FCM tap → Social/Chat/Profile open | ✅ Implemented |
| In-app notification list + badge | ✅ Implemented |
| Mark as read on open | ✅ Implemented |

Matlab **Flutter se notification system working hai**. Agar notification **aati hi nahi** (device par popup hi nahi) to issue usually:
- **Topic name** galat, ya
- **Device subscribe nahi hai** (login/session), ya
- **Release build / ProGuard**, ya
- **Firebase project / package / google-services.json**.

---

## 7) Quick test

1. App me **login** karo (jis user ko notification chahiye).
2. Firebase Console → Messaging → New notification → **Topic** = `user_<that_user_id>`.
3. Send karo. Agar yahan bhi nahi aati to topic ya device subscription check karo.
4. Agar **debug build** me aati hai, **release** me nahi → ProGuard / release config check karo.
