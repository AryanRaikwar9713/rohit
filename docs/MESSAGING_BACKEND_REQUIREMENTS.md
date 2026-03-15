# WAMIMS Messaging System – Backend API Requirements

The app uses a 1:1 messaging system (chat list like Instagram/WhatsApp). Base URL is set in the app as: **https://wamims.international/social/message** (or your domain + `/social/message`).

All requests must send the user's **Authorization** header (e.g. `Bearer <api_token>`) from the app's login. The app gets headers via `DB().getHeaderForRow()` (same as other API calls).

---

## 1. GET – Chat list (recent conversations)

**URL:** `GET {MESSAGE_BASE_URL}/get_conversations.php`  
**Headers:** Authorization (Bearer token), same as rest of app.

**Response (200, JSON):**
```json
{
  "success": true,
  "conversations": [
    {
      "conversation_id": 1,
      "other_user": {
        "id": 2,
        "username": "johndoe",
        "first_name": "John",
        "last_name": "Doe",
        "file_url": "avatars/xyz.jpg"
      },
      "last_message": {
        "id": 100,
        "sender_id": 2,
        "type": "text",
        "body": "Hello!",
        "attachment_url": null,
        "created_at": "2026-02-27 10:00:00"
      },
      "unread_count": 0,
      "updated_at": "2026-02-27 10:00:00"
    }
  ]
}
```
- **conversations**: array of conversation objects (app sorts by `updated_at` desc so recent chats on top).
- **other_user**: the other participant in the 1:1 chat.
- **last_message**: optional; omit or null if no messages yet.
- **unread_count**: number of unread messages in that conversation for current user.

**Errors:**
- **401:** `{ "success": false, "error": "Authentication required" }`
- **4xx/5xx:** `{ "success": false, "error": "message" }`

---

## 2. GET – Get or create conversation with a user

**URL:** `GET {MESSAGE_BASE_URL}/get_or_create_conversation.php?other_user_id={id}`  
**Headers:** Authorization.

**Response (200):**
```json
{
  "success": true,
  "conversation_id": 1,
  "other_user": {
    "id": 2,
    "username": "johndoe",
    "first_name": "John",
    "last_name": "Doe",
    "file_url": "avatars/xyz.jpg"
  }
}
```
- Used when opening a chat from a profile (start or open existing 1:1).

---

## 3. GET – Load messages in a conversation

**URL:** `GET {MESSAGE_BASE_URL}/get_messages.php?conversation_id={id}&limit=50[&after_id=][&before_id=]`  
- **after_id**: load messages after this id (e.g. for polling new messages).
- **before_id**: load messages before this id (e.g. “load older”).

**Response (200):**
```json
{
  "success": true,
  "messages": [
    {
      "id": 1,
      "conversation_id": 1,
      "sender_id": 2,
      "type": "text",
      "body": "Hello",
      "attachment_url": null,
      "attachment_mime": null,
      "is_encrypted": 0,
      "created_at": "2026-02-27 10:00:00"
    }
  ],
  "has_more": false
}
```
- **type:** `text` | `image` | `audio` | `video` | `file`
- **has_more:** true if there are older messages to load (when using `before_id`).

**Errors:** 401 (auth), 403 (not a participant), or `success: false` + `error`.

---

## 4. POST – Send text message

**URL:** `POST {MESSAGE_BASE_URL}/send_message.php`  
**Content-Type:** `application/x-www-form-urlencoded`  
**Body:** `conversation_id=1&type=text&body=Hello%20world`

**Response (200):**
```json
{
  "success": true,
  "message": {
    "id": 101,
    "conversation_id": 1,
    "sender_id": 1,
    "type": "text",
    "body": "Hello world",
    "attachment_url": null,
    "attachment_mime": null,
    "is_encrypted": 0,
    "created_at": "2026-02-27 10:01:00"
  }
}
```

---

## 5. POST – Send attachment (image, audio, video, file)

**URL:** `POST {MESSAGE_BASE_URL}/send_message.php`  
**Content-Type:** `multipart/form-data`  
**Fields:** `conversation_id`, `type` (image|audio|video|file), optional `body`  
**File:** `attachment` (file bytes)

**Response (200):** Same as send text – `success: true` and `message` object with `attachment_url`, `attachment_mime` set.

---

## 6. POST – Mark conversation as read

**URL:** `POST {MESSAGE_BASE_URL}/mark_read.php`  
**Body:** `conversation_id=1` and optionally `last_read_message_id=100`

**Response (200):** `{ "success": true }`

---

## Summary – endpoints to implement or verify

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | get_conversations.php | Chat list (recent on top) |
| GET | get_or_create_conversation.php?other_user_id= | Open/start 1:1 chat |
| GET | get_messages.php?conversation_id=&limit=&after_id=&before_id= | Load messages |
| POST | send_message.php (form) | Send text |
| POST | send_message.php (multipart) | Send image/audio/video/file |
| POST | mark_read.php | Mark read |

If any of these are missing on your backend, create them to match the JSON shapes above so the app’s Messages screen and chat work correctly.
