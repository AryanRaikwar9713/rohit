# Backend notes – Stories, Profile, Login (for backend cursor)

Give these points to your backend developer / backend Cursor so APIs match what the app expects.

---

## 1. View My Story – current user’s story not showing

**Issue:** When user taps “View my story”, app calls **my_stories_api.php** to get their active stories. If the API returns empty or wrong structure, app shows upload screen instead of the story viewer.

**Required from my_stories_api.php** (`https://wamims.international/social/my_stories_api.php`):

- **Auth:** Request must include `Authorization: Bearer <token>` (same as other authenticated APIs).
- **Response (200):** JSON with an **`active_stories`** array at the **root** of the response (or inside a known key the app can map).
- **App expects this shape** (root-level keys):
  - `success` (bool)
  - `active_stories` (array) – **required**. Each item can have at least:
    - `id` (int)
    - `user_id` (int)
    - `media_url` (string, full URL or path)
    - `media_type` (string, e.g. `"image"` / `"video"`)
    - `created_at`, `expires_at` (optional)
  - If `active_stories` is missing or empty, app will open the “upload story” screen.

**Check:** For the logged-in user, ensure the API returns their **non-expired** stories in `active_stories`. If the key is different (e.g. `data.active_stories`), either change backend to send `active_stories` at root or tell frontend so we can parse accordingly.

---

## 2. Get Stories (home/social story ring) – include own story

**Issue:** On home/social, the first story circle is “Your story”. To show a ring around it when the user has a story, the app checks if **get_stories** response has any item with **`is_own_story: true`**.

**Required from story_api.php** (`action=get_stories&followed_only=1`):

- **Include the current user’s story** in the `stories` array when they have at least one active story.
- For the **current user’s** entry only, set **`is_own_story: true`** (or equivalent so app can treat it as “own story”).
- Each item in `stories` should have at least:
  - `user` (object with `id`, `username`/`name`, `avatar`)
  - `stories` (array of story items with `id`, `media_url`, `media_type`, etc.)
  - `is_own_story` (bool) for the logged-in user’s entry.

If the backend does not include the current user in `get_stories` or does not set `is_own_story`, the app will still work for “View my story” (it now fetches from my_stories_api first), but the “Your story” circle won’t show the “has story” state correctly until this is fixed.

---

## 3. Login / Register – profile image and name for home story circle

**Issue:** On the home screen, the first story circle shows the logged-in user’s **name** and **profile image**. If these are missing, the circle shows placeholder/default.

**Required:**

- **Login / register / social-login response:** In the **user** object, include:
  - **`full_name`** (string) – displayed under the “Your story” circle.
  - **`profile_image`** (string) – URL or path. If path, app will prepend base URL with `storage/avatars/` when needed.

If `profile_image` is empty, the app tries to load avatar from **vammis profile API** (`wamims_profile.php?user_id=...`). So either:

- Send **`profile_image`** in login/register response, or  
- Ensure **wamims_profile.php** returns **`data.user.avatar`** or **`data.user.avatar_url`** for that user.

---

## 4. Summary table

| API / Feature              | What backend should do |
|----------------------------|------------------------|
| **my_stories_api.php**     | Return `active_stories` array (with `id`, `media_url`, `media_type`, etc.) for the logged-in user’s active stories. Auth: Bearer token. |
| **story_api.php get_stories** | Include current user in `stories` and set `is_own_story: true` for their entry when they have stories. |
| **Login/register response** | Include user `full_name` and `profile_image` (or ensure vammis profile API returns avatar). |

---

*Generated for Wamims app – give this full file to backend cursor / developer.*
