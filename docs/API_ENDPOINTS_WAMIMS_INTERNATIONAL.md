# API endpoints – wamims.international

Base URL used in app: **https://wamims.international**

Agar server sirf **HTTP** pe hai to `lib/configs.dart` me `DOMAIN_URL` ko  
`"http://wamims.international"` kar do.

---

## Endpoints to verify on new server

Naye domain pe ye paths same structure me hona chahiye. Jo fail ho, unhe backend pe fix karna hoga.

### Social
| Path | File | Purpose |
|------|------|---------|
| `/social/get_posts.php` | social_api.dart, vammis_profile_api.dart | Feed / profile posts |
| `/social/post_likes.php` | social_api.dart | Like post |
| `/social/post_comments.php` | social_api.dart | Comment on post |
| `/social/upload_posts.php` | social_api.dart | Create post |
| `/social/get_wallet.php` | wallet_api.dart | Wallet summary |
| `/social/impact/get_projects.php` | campainApi.dart, vammis_profile_api.dart | Projects list |
| `/social/my_stories_api.php` | story_api.dart | Own stories |
| `/social/reels/add_comment.php` | reels_api.dart | Reel comment |
| `/social/shopping/shop_product_create.php` | product_api.dart | Create product |
| `/social/social_api.php` | api_end_points.dart | Social API (create/get posts) |

### Public (under /public/social/)
| Path | Purpose |
|------|---------|
| `/public/social/search_content.php` | Search |
| `/public/social/followers_following_list_api.php` | Followers/following |
| `/public/social/story_api.php?action=get_stories` | Get stories |
| `/public/social/story_api.php?action=create_story` | Create story |
| `/public/social/reels/get_reels.php` | Reels feed |
| `/public/social/reels/reel_like.php` | Like reel |
| `/public/social/reels/get_comments.php` | Reel comments |
| `/public/social/reels/create_reel.php` | Upload reel |
| `/public/social/get_comments.php` | Post comments |
| `/public/social/follow_api.php` | Follow/unfollow |
| `/public/social/wamims_profile.php` | Profile get/update |
| `/public/social/impact/*` | Donate, projects, history, limits, account, etc. |
| `/public/social/bolt/*` | Bolt wallet, rewards, ads |
| `/public/social/ads/social_like_bolt.php` | Like bolt |
| `/public/social/ads/watch_ad_reward_bolt.php` | Ad reward |
| `/public/social/point/index.php` | Points (summary, history) |
| `/public/social/shopping/*` | Shop register, categories, product order |
| `/public/social/shop/*` | Events, coupons |
| `/public/social/channel_api.php` | Video channel |
| `/public/social/social_media_api.php` | Social accounts |

---

## Quick test

1. App run karke login karo, feed/post/reels/stories open karke dekho.
2. Koi 404/500 aaye to backend pe check karo ki wahi path `https://wamims.international` (ya `http://...`) pe serve ho rahe hain.
3. Images/avatars: `resolveImageUrl()` `DOMAIN_URL` use karta hai, so storage path naye domain pe same hona chahiye (e.g. `/storage/avatars/...`).
