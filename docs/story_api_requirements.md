## Story APIs – Requirements for Backend

These Flutter changes are already wired to these APIs. Once backend implements them with the contracts below, the app will start working automatically (no more Flutter changes needed).

### 1. Record story view (jab koi story dekhe – REQUIRED for views to work)

Views tabhi count honge jab backend ye API implement kare aur Flutter call kare.

**Endpoint (suggested)**  
`POST https://wamims.international/public/social/record_story_view_api.php`

**Headers**
- Same auth headers as existing story APIs.

**Body (form or JSON)**
- `story_id` (int, required): ID of the story being viewed.
- User ID comes from auth token – backend should use logged-in user as viewer.

**Backend behaviour**
1. Validate user is logged in.
2. Validate story exists and user has permission (followed user, etc).
3. INSERT into `story_views` table: `viewer_user_id`, `story_id`, `viewed_at`
4. Ignore duplicate (same user + story) – use UNIQUE constraint or skip if already exists.

**Response – 200 OK**
```json
{ "success": true }
```

**Flutter:** Calls this when user views a story (on story change in ViewStoryScreen). See StoryApi.recordStoryView().

---

### 2. Get story viewers (who viewed my story)

**Endpoint (suggested)**  
`GET https://wamims.international/public/social/story_viewers_api.php?story_id={story_id}`

**Headers**
- Same auth headers as existing story APIs (`DB().getHeaderForForm()`).

**Query params**
- `story_id` (int, required): ID of the story.

**Response – 200 OK**

```json
{
  "success": true,
  "story_id": 123,
  "total_views": 5,
  "viewers": [
    {
      "id": 10,
      "username": "john_doe",
      "name": "John Doe",
      "avatar": "https://.../avatar.png",
      "viewed_at": "2026-03-05T10:30:00Z"
    }
  ]
}
```

**Flutter expectations**
- If `success == true`, Flutter:
  - Uses `total_views` or `viewers.length` as view count.
  - Shows up to 3 avatars at the bottom of **MyStoryScreen** + full count (e.g. "5 views").
  - If response is error / non‑200, Flutter silently shows `0 views` (UI still works).

---

### 3. Like / unlike a story (double‑tap like)

**Endpoint (suggested)**  
`POST https://wamims.international/public/social/story_like_api.php`

**Headers**
- Same auth headers as existing story APIs.

**Body (form or JSON)**

```json
{
  "story_id": 123,
  "action": "like"   // or "unlike"
}
```

**Response – 200 OK**

```json
{
  "success": true,
  "story_id": 123,
  "is_liked": true,
  "likes_count": 7
}
```

**Flutter expectations**
- Flutter sends:
  - `story_id`: int
  - `action`: `"like"` when user double‑taps to like, `"unlike"` when they unlike.
- On success:
  - `is_liked` + `likes_count` can be used in future to show real like count.  
  - Right now Flutter only keeps local "Liked" state (double‑tap heart) but is already calling this endpoint in the background.
- On error / non‑200:
  - Flutter keeps local state and just logs the error (no crash).

---

### 4. Existing story APIs (already used)

These are already live and used in app:

1. **Create story**
   - `POST public/social/story_api.php?action=create_story`
   - Multipart: `media` (file), optional `caption`

2. **Get followed users' stories**
   - `GET public/social/story_api.php?action=get_stories&followed_only=1`
   - Returns list of users + their stories (`GetStoryResponceModel`)

3. **Get my own stories**
   - `GET social/my_stories_api.php`
   - Returns `GetMyStoryResponceModel` (used in MyStoryScreen)

No change needed in these; they are documented here only for completeness.

---

### 5. Tag people while creating story

**Endpoint (existing)**  
Re‑use existing create story endpoint:

`POST public/social/story_api.php?action=create_story`

**New request field**

- `tag_user_ids` – **string**, optional  
  - Comma separated user IDs: `"12,45,98"`  
  - Flutter already sends this field when user tags people on Add Story screen.

Example multipart form (simplified):

```http
media: <file>
caption: "Great day!"
tag_user_ids: "12,45,98"
```

**Backend behaviour**

- For each ID in `tag_user_ids`:
  - Validate user exists.
  - Create story‑tag relation.
  - Optionally send notification: “@you was mentioned in a story”.
- Response JSON can remain same as current create_story response; no Flutter changes needed.


