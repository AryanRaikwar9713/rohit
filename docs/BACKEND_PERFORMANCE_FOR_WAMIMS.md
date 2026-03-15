# WAMIMS – Backend performance guide (messages, feed, ads, reels)

This file is for the **backend / DevOps team**. The goal is to make the app feel fast even with **10M+ users** – especially for:
- Messages inbox + chat
- Social feed + reels
- Ads loading

The Flutter app already does client‑side optimisations (pagination, small page sizes, basic caching). To unlock full speed, the APIs and infra should follow these points.

---

## 1. Messaging API performance

### 1.1 Chat list – `get_conversations.php`

**Must have:**
- **Index** on `conversations(updated_at)` and `conversations(user_id)` (or `participant_user_id`) so this query is always **O(log N)**.
- Always **ORDER BY `updated_at` DESC** and **LIMIT 30–50** rows.
- For each conversation, **join OR pre‑compute**:
  - `other_user` minimal profile: `id`, `username`, `first_name`, `last_name`, `avatar file_url`
  - `last_message` fields used on UI: `id`, `sender_id`, `type`, `body`, `attachment_url`, `created_at`
  - `unread_count`
- Response JSON must match `docs/MESSAGING_BACKEND_REQUIREMENTS.md`.

**Example SQL sketch (NOT exact code):**
```sql
SELECT c.id AS conversation_id,
       u.id        AS other_user_id,
       u.username,
       u.first_name,
       u.last_name,
       u.avatar_path   AS file_url,
       lm.id           AS last_message_id,
       lm.sender_id,
       lm.type,
       lm.body,
       lm.attachment_url,
       lm.created_at   AS last_message_created_at,
       c.updated_at,
       uc.unread_count
FROM conversations c
JOIN users u       ON u.id = c.other_user_id_for(:current_user_id)
LEFT JOIN messages lm ON lm.id = c.last_message_id
LEFT JOIN unread_counts uc ON uc.conversation_id = c.id AND uc.user_id = :current_user_id
WHERE c.user_id = :current_user_id
ORDER BY c.updated_at DESC
LIMIT 50;
```

### 1.2 Messages list – `get_messages.php`

**Must have:**
- Index on `messages(conversation_id, id)`.
- Use **cursor pagination** based on `id`:
  - `after_id` → `WHERE conversation_id = ? AND id > :after_id`
  - `before_id` → `WHERE conversation_id = ? AND id < :before_id`
- Always **LIMIT 50** and order **ASC by `id`** (client can display in reverse if needed).
- Return `has_more: true/false` when there are older rows beyond `before_id`.

This keeps every scroll / pagination request **O(log N + page_size)** even when a chat has millions of messages.

### 1.3 Mark read – `mark_read.php`

- DB table `unread_counts(conversation_id, user_id, unread_count, last_read_message_id)` should be **indexed on (`conversation_id`, `user_id`)**.
- `mark_read` should **ONLY update the row for that user + conversation**, not scan large message tables.

### 1.4 Polling vs push

The current app uses **short polling** (every ~2–3 seconds) via `get_messages.php?after_id={last_message_id}` when user is inside a chat.

For 10M users you should plan to:
- Move to **WebSocket** or **SSE** for live chats (one persistent connection per active user).
- Or keep polling but **only when chat screen is visible**, and
  - Increase interval when connection is slow (e.g. 3–5s),
  - Use a **rate‑limit per user** on the backend.

Also:
- Use **push notifications (FCM/APNs)** for offline/background users. The mobile app already has FCM configured.

---

## 2. Social feed + reels performance

**API design:**
- Feed endpoints must support **cursor pagination** (e.g. `?after_id`, `?before_id` or `?cursor=`) with **LIMIT 10–20** items.
- Index posts by
  - `created_at DESC`
  - any `trending_score` / `hot_score` you use.
- Always return **compressed media URLs** (HLS / DASH playlist, JPEG/WEBP thumbs) hosted on **CDN / object storage** (CloudFront, Cloudflare, S3, etc.).

**Database / cache:**
- For home feed, maintain a pre‑computed timeline (Redis list / fan‑out‑on‑write) per user or per segment.
- Avoid `SELECT * FROM posts ORDER BY created_at DESC LIMIT 50` without proper indexes.
- Put **hot data** (latest reels, trending posts) in Redis / in‑memory cache with short TTL (30–120s).

---

## 3. Ads performance

- Ads configuration (placements, on/off flags, frequency caps) should be served from a **small, cached JSON** endpoint – e.g. `get_ad_config.php`.
  - Cache result in Redis for 1–5 minutes.
  - Keep JSON under ~5–10 KB if possible.
- Any custom ad tracking logs must be **batched** server‑side, not one write per impression.

---

## 4. General PHP/MySQL (or other stack) tuning

1. **Indexes:**
   - `conversations(user_id, updated_at)`
   - `messages(conversation_id, id)`
   - `messages(conversation_id, created_at)` (if you sort by time)
   - `users(id, username)`

2. **Pagination:**
   - Prefer `WHERE id > :cursor_id ORDER BY id ASC LIMIT 50` instead of `LIMIT 50 OFFSET 10000`.

3. **Compression & caching:**
   - Enable **gzip/brotli** on the web server so JSON responses are compressed.
   - Set proper **Cache-Control** for static files: avatars, thumbnails, JS/CSS, etc.

4. **Connection limits:**
   - Put APIs behind a **load balancer**.
   - Use stateless PHP/FPM/Node workers wherever possible.

5. **Monitoring:**
   - Track p95 / p99 latency per endpoint (especially `get_conversations.php`, `get_messages.php`, feed/reels APIs).
   - Add logging for slow queries (`> 200ms`) and fix queries or indexes.

---

## 5. What the mobile app expects

- Messaging endpoints and JSON shapes must follow `docs/MESSAGING_BACKEND_REQUIREMENTS.md`.
- Latency targets from mobile app POV:
  - Messages inbox: **< 500 ms** for initial load on good network.
  - Opening a chat: first 50 messages **< 700 ms**.
  - Loading older messages: subsequent pages **< 500 ms**.
  - Feed / reels first page: **< 800 ms**.

If you align the backend to this guide + the existing messaging requirements doc, the app can scale to millions of users with good perceived speed.
