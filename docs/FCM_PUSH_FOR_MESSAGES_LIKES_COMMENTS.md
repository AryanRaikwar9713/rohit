# WAMIMS – Firebase push notifications for messages, likes, comments & share

So users get **real-time notifications** inside the app and **push when the app is closed** (band/background), do the following on the **backend**.

---

## 1. When to send a push

Send an FCM (Firebase Cloud Messaging) message to the **target user** when:

- **New message** – someone sends a 1:1 chat message to the user.
- **Post like** – someone likes a post created by the user.
- **Post comment** – someone comments on a post created by the user.
- **Post share** – someone shares the user’s post.

The mobile app subscribes each logged-in user to the topic **`user_<user_id>`** (e.g. `user_237`) **on login and on app start**. You can either:

- Send to that **topic**: `user_<target_user_id>`, or  
- Send to the **FCM token** you have stored for that user.

---

## 2. FCM payload shape

Use **data + notification** so the notification shows even when the app is in background or killed.

### 2.1 New message

```json
{
  "notification": {
    "title": "New message",
    "body": "John: Hey, how are you?"
  },
  "data": {
    "type": "message",
    "conversation_id": "123",
    "id": "456"
  }
}
```

- **type**: must be `"message"`.
- **conversation_id**: conversation id (string) so the app can open that chat.

### 2.2 Post like

```json
{
  "notification": {
    "title": "New like",
    "body": "Someone liked your post"
  },
  "data": {
    "type": "like",
    "post_id": "789",
    "id": "789"
  }
}
```

- **type**: `"like"`.
- **post_id**: post id (string) for future deep link to that post.

### 2.3 Post comment

```json
{
  "notification": {
    "title": "New comment",
    "body": "Jane commented on your post"
  },
  "data": {
    "type": "comment",
    "post_id": "789",
    "id": "789"
  }
}
```

- **type**: `"comment"`.
- **post_id**: post id (string).

### 2.4 Post share

```json
{
  "notification": {
    "title": "New share",
    "body": "Someone shared your post"
  },
  "data": {
    "type": "share",
    "post_id": "789",
    "id": "789"
  }
}
```

- **type**: `"share"`.
- **post_id**: post id (string).

---

## 3. Store notifications for the in-app list

So the **Notifications** screen in the app can show the same items (messages, likes, comments):

- When you send an FCM for message / like / comment / share, also **insert a row** into your **notifications** table (or the API that backs `notification-list`).
- The app already calls **`notification-list`** and shows the list on the Notifications page. Ensure that API returns these types (message, like, comment, share) with at least:
  - `type` (e.g. message / like / comment / share)
  - `subject` or title
  - `data.id`, `data.post_id` or `data.conversation_id` as needed
  - created/updated time

Then:

- **In app**: User sees the item in Notifications and can tap to open messages or social.
- **Outside app (band/background)**: User gets the system push; on tap the app opens and navigates using `data.type`, `data.conversation_id`, `data.post_id`.

---

## 4. Summary

| Event        | FCM `data.type` | FCM `data` fields       | Also save to notification-list |
|-------------|------------------|--------------------------|--------------------------------|
| New message | `message`        | `conversation_id`        | Yes                            |
| Post like   | `like`          | `post_id`                | Yes                            |
| Post comment| `comment`       | `post_id`                | Yes                            |
| Post share  | `share`         | `post_id`                | Yes                            |

Use **topic** `user_<target_user_id>` (e.g. `user_237`) or the user’s **FCM token**. The app subscribes to this topic on **login** and on **app start** when the user is already logged in.
