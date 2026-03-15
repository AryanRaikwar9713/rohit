# FCM Push Notifications – Admin / Backend Setup

WhatsApp/Facebook jaise message, like, comment ke liye push notifications enable karne ke liye **backend/admin** ko ye steps karne honge.

---

## 1. Firebase Console

- Project **maarket-points** use ho raha hai
- Cloud Messaging already enabled hona chahiye
- Koi extra Firebase config zaroori nahi – app already FCM setup karti hai

---

## 2. Backend par kya karna hai

Jab ye events hon, **FCM send** karo + **notification table mein insert** karo:

| Event          | Kab bhejein | FCM topic        | Notification API mein save |
|----------------|-------------|------------------|----------------------------|
| New message    | Koi user chat message bheje | `user_<receiver_user_id>` | Haan |
| Post like      | Koi post like kare         | `user_<post_owner_id>`    | Haan |
| Post comment   | Koi post pe comment kare   | `user_<post_owner_id>`    | Haan |
| Post share     | Koi post share kare        | `user_<post_owner_id>`    | Haan |

---

## 3. FCM payload format

### 3.1 New message

```json
{
  "notification": {
    "title": "New message",
    "body": "John: Hey, how are you?"
  },
  "data": {
    "type": "message",
    "conversation_id": "123"
  }
}
```

**Target:** `user_<receiver_user_id>` (e.g. `user_237`)

### 3.2 Post like

```json
{
  "notification": {
    "title": "New like",
    "body": "Someone liked your post"
  },
  "data": {
    "type": "like",
    "post_id": "789"
  }
}
```

### 3.3 Post comment

```json
{
  "notification": {
    "title": "New comment",
    "body": "Jane commented on your post"
  },
  "data": {
    "type": "comment",
    "post_id": "789"
  }
}
```

### 3.4 Post share

```json
{
  "notification": {
    "title": "New share",
    "body": "Someone shared your post"
  },
  "data": {
    "type": "share",
    "post_id": "789"
  }
}
```

---

## 4. Backend implementation (Laravel example)

1. **Firebase Admin SDK** install karo:  
   `composer require kreait/firebase-php`

2. **Service account key** download karo:
   - Firebase Console → Project Settings → Service Accounts
   - Generate new private key

3. **FCM send** (topic):

```php
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

$messaging = (new Factory)->withServiceAccount('path/to/serviceAccountKey.json')->createMessaging();

$message = CloudMessage::withTarget('topic', 'user_' . $targetUserId)
    ->withNotification(Notification::create($title, $body))
    ->withData(['type' => $type, 'conversation_id' => $conversationId, 'post_id' => $postId]);

$messaging->send($message);
```

4. **Notification table** mein insert karo (jo `notification-list` API feed karti hai), taaki in-app Notifications section mein bhi dikhe.

---

## 5. App side (already done)

- Login par user automatically `user_<user_id>` topic subscribe hota hai
- Push notification tap par Messages / Social pe navigate hota hai
- In-app Notifications list refresh hoti hai jab naya FCM aata hai

---

## 6. Testing

1. Do users se login karo (alag devices/simulators pe)
2. Ek user se message bhejo
3. Dusre user ko push notification aani chahiye
4. Notifications section mein bhi wahi notification dikhna chahiye
