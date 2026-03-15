# How to Test Notifications With Only One Phone

Agar aapke paas sirf ek mobile hai, notification test karne ke 2 practical tareeke:

---

## 1) Firebase Console se direct test (sabse aasaan)

Backend / doosra user ki zaroorat nahi. Aap khud apne device par notification bhej sakte ho.

### Step 1: Apna User ID aur topic note karo
- App me **login** karo (jis account par notification aani hai).
- Topic hamesha: **`user_<user_id>`**
- Example: agar aapka user ID **42** hai to topic = **`user_42`**
- User ID: Profile / Account settings me dikh sakta hai, ya backend/database se check karo.

### Step 2: Firebase Console open karo
1. [Firebase Console](https://console.firebase.google.com) → apna project select karo.
2. Left side: **Engage** → **Messaging** (Cloud Messaging).
3. **Create your first campaign** ya **New campaign** → **Firebase Notification messages**.

### Step 3: Notification banao
- **Notification title:** e.g. "Test like"
- **Notification text:** e.g. "Someone liked your post"

### Step 4: Target = Topic
- **Send to:** "Topic"
- Topic name: **`user_42`** (apna user_id use karo)

### Step 5: Custom data (tap par sahi screen open ho)
- **Additional options** / **Custom data** me ye key-value add karo (exact names use karo):

| Key           | Value (example) | Kab use karein      |
|---------------|-----------------|----------------------|
| `type`        | `like`          | Like tap → Social    |
| `type`        | `comment`       | Comment tap → Social |
| `type`        | `message`       | Message tap → Chat   |
| `type`        | `follow`        | Follow tap → Profile |
| `post_id`     | `123`           | Like/Comment ke saath |
| `conversation_id` | `5`         | Message ke saath     |
| `sender_user_id`  | `10`         | Message ke saath     |
| `sender_name`     | `Rahul`      | Message ke saath     |
| `user_id`     | `10`             | Follow ke saath (jo follow kiya) |

**Examples:**
- **Like test:** `type` = `like`, `post_id` = `123`
- **Message test:** `type` = `message`, `conversation_id` = `5`, `sender_user_id` = `10`, `sender_name` = `Rahul`
- **Follow test:** `type` = `follow`, `user_id` = `10`

### Step 6: Send
- **Review** → **Publish**.
- Phone par notification aayegi; tap karke check karo ki sahi screen (Social / Chat / Profile) open ho raha hai.

---

## 2) Doosra user se test (real flow – like/comment/message)

Isse real behaviour test hota hai: doosra user action karega, aapke phone par notification aayegi.

### Option A: Web / browser se doosra account
- Agar **wamims.international** (ya koi web app) par login ho sakta hai, to:
  1. Phone par **User A** se login karo (jisko notification chahiye).
  2. Browser / laptop par **User B** se login karo.
  3. User B, User A ki koi post/reel pe **like** ya **comment** kare.
  4. User A ke phone par notification aani chahiye (backend FCM bhej raha ho to).

### Option B: Doosra device (dost ka phone / emulator)
- User A = aapka phone (jis par notification test karna hai).
- User B = kisi aur ka phone ya emulator par login.
- User B, User A ki post pe like/comment kare → User A ko notification.

### Option C: Backend / Postman se trigger (dev only)
- Agar backend team ne FCM trigger APIs diye hon to:
  - Postman se like/comment API call karo (User B ke token ke saath), jis post ki owner User A hai.
  - Backend automatically User A ke topic par FCM bhej dega.

---

## Quick checklist (1 phone)

1. **Firebase Console** → Messaging → New notification.
2. Target = **Topic** → `user_<your_user_id>`.
3. Custom data me **`type`** + zaroori IDs (**post_id** / **conversation_id** / **user_id** etc.) add karo.
4. Send karke phone par tap test karo.

Agar notification aati hai par **tap par koi screen open nahi hoti**, to check karo ki custom data me **key names exact** hon: `type`, `post_id`, `conversation_id`, `sender_user_id`, `sender_name`, `user_id` (backend doc ke hisaab se).
