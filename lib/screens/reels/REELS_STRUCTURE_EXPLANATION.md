# 🎬 REELS SCREEN STRUCTURE - Complete Explanation

## 📂 File Structure

```
lib/screens/reels/
├── reels_screen.dart              → Main Screen (UI)
├── reels_controller.dart          → Business Logic (GetX Controller)
├── reels_api.dart                 → API Calls
├── reel_response_model.dart       → API Response Models
├── reel_comment_response_model.dart → Comment Models
├── upload_reel_screen.dart        → Upload Reel UI
├── upload_reel_controller.dart    → Upload Logic
├── reels_login_screen.dart        → Login Screen
│
└── components/
    ├── reel_item_widget.dart      → Single Reel Display Widget
    ├── reel_comment_bottom_sheet.dart → Comments Bottom Sheet
    └── reels_widget.dart          → Horizontal Reel List (Dashboard)
```

---

## 🏗️ Architecture Flow

### 1️⃣ **ReelsScreen** (Main Entry Point)
```
ReelsScreen (StatefulWidget)
│
├── PageController → Vertical scrolling control
├── ReelsController → GetX Controller (via Get.put)
│
└── Body:
    ├── Loading State → CircularProgressIndicator
    ├── Empty State → "No reels available"
    └── PageView.builder → 
        └── ReelItemWidget (for each reel)
```

**Key Points:**
- **PageController**: Vertical scrolling ke liye (Instagram/TikTok style)
- **Full Screen Mode**: System UI hidden hai immersive mode mein
- **AppBar**: Top right mein "+" button hai reel upload karne ke liye

---

### 2️⃣ **ReelsController** (State Management)
```dart
RxList<Reel> apiReels          → List of all reels from API
RxBool isLoading               → Loading state
RxInt currentPage              → Pagination
RxBool hasMoreData            → More pages available?
Map<int, Player> videoControllers → Video players for each reel
```

**Main Functions:**
1. **loadReelsFromApi()** → API se reels fetch karta hai
2. **toggleLikeReel()** → Like/Unlike functionality
3. **addCommentOnReel()** → Comment add karta hai
4. **getReelComments()** → Comments fetch karta hai
5. **createReel()** → New reel upload karta hai
6. **onReelChanged()** → Reel change hone par video play/pause

---

### 3️⃣ **ReelsApi** (API Layer)
```dart
class ReelsApi {
  getReels()           → GET /get_reels.php
  likeReel()           → POST /reel_like.php
  addCommentOnReel()   → POST /reel_comments.php
  getReelComments()    → GET /get_comments.php
  createReel()         → POST /create_reel.php
}
```

**API Endpoints:**
- Base URL: `https://app.wamims.world/public/social/reels/`
- All APIs require headers from `DB().getHeaderForRow()`
- User ID from `DB().getUser()`

---

### 4️⃣ **ReelItemWidget** (Single Reel Display)
```
ReelItemWidget
│
├── Video Player (media_kit)
│   ├── VideoController
│   └── Player (media_kit)
│
├── UI Overlays:
│   ├── Profile Section (Right side top)
│   ├── Action Buttons (Right side):
│   │   ├── Like Button
│   │   ├── Comment Button
│   │   ├── Share Button
│   │   └── More Options
│   │
│   └── Bottom Content (Left side):
│       ├── Username
│       ├── Caption
│       └── Hashtags
│
└── Gestures:
    ├── Single Tap → Play/Pause
    └── Double Tap → Like + Heart Animation
```

**Features:**
- Video auto-play jab reel visible ho
- Double tap se like + heart animation
- Single tap se play/pause
- Comment bottom sheet open hota hai
- Share functionality

---

## 🔄 Data Flow

### Reels Load Karne Ka Flow:
```
1. User opens ReelsScreen
   ↓
2. ReelsController.onInit() runs
   ↓
3. loadReelsFromApi() called
   ↓
4. ReelsApi().getReels() makes HTTP request
   ↓
5. API Response → reel_response_model.dart
   ↓
6. Data saved in apiReels (RxList)
   ↓
7. PageView.builder rebuilds with ReelItemWidget
   ↓
8. Each ReelItemWidget initializes its video player
```

### Like Karne Ka Flow:
```
1. User taps Like button
   ↓
2. ReelItemWidget calls controller.toggleLikeReel(reelId)
   ↓
3. ReelsApi().likeReel() makes POST request
   ↓
4. API returns updated like count and isLiked status
   ↓
5. Controller updates apiReels[index].interactions
   ↓
6. UI automatically updates (GetX reactivity)
```

---

## 📦 Reel Model Structure

```dart
class Reel {
  int? id;                    // Reel ID
  User? user;                 // User who posted
  Content? content;           // Video content
  Stats? stats;               // View counts, etc.
  Interactions? interactions; // Likes, comments, shares
  Optimization? optimization; // Performance data
}

class Content {
  String? videoUrl;           // Main video URL
  String? thumbnailUrl;       // Thumbnail
  String? caption;           // Description
  List<String>? hashtags;     // Hashtags
  String? location;           // Location
  int? duration;              // Video duration
  Map<String, Quality>? qualities; // Different quality options
}

class Interactions {
  bool? isLiked;              // User liked this?
  int? likesCount;            // Total likes
  int? commentsCount;         // Total comments
  int? sharesCount;           // Total shares
}
```

---

## 🎥 Video Player Management

### Multiple Video Players:
```dart
Map<int, Player> videoControllers → Each reel ke liye separate player
```

**Why?**
- Simultaneous playback avoid karne ke liye
- Memory efficient
- Smooth scrolling

**How it works:**
1. Jab ek reel visible ho → uska player play
2. Jab doosri reel pe scroll → pehli wali pause, nayi play
3. `onReelChanged()` automatically handle karta hai

---

## 🎨 UI Components Breakdown

### ReelItemWidget Layout:
```
┌─────────────────────────────┐
│                             │
│      VIDEO PLAYER           │
│    (Full Screen)            │
│                             │
│  [Profile]  [Like]          │ ← Right Side
│             [Comment]        │
│             [Share]          │
│             [More]           │
│                             │
│  Username                    │ ← Bottom Left
│  Caption text               │
│  #hashtag1 #hashtag2        │
│                             │
└─────────────────────────────┘
```

---

## 🔑 Key Concepts

### 1. **GetX State Management**
- `RxList`, `RxBool` → Reactive variables
- `.obs` → Observable (UI automatically updates)
- `Obx()` → Watch changes and rebuild

### 2. **Media Kit Video Player**
- `Player` → Video playback engine
- `VideoController` → Flutter widget integration
- Auto-play/pause based on visibility

### 3. **Pagination**
- `currentPage` → Current page number
- `hasMoreData` → More pages available?
- Infinite scroll ready (but not implemented yet)

### 4. **API Integration**
- All requests use headers for authentication
- Error handling via `onError`, `onFailure`, `onSuccess`
- Logger for debugging

---

## 🚀 Usage Examples

### Reels Load Karna:
```dart
final controller = Get.find<ReelsController>();
await controller.loadReelsFromApi();
```

### Like Karne Ke Liye:
```dart
controller.toggleLikeReel(reelId);
```

### Comment Add Karne Ke Liye:
```dart
controller.addCommentOnReel(
  reelId: 123,
  comment: "Nice reel!",
);
```

### Refresh Karna:
```dart
await controller.refreshReels();
```

---

## 🐛 Common Issues & Solutions

1. **Video Not Playing?**
   - Check `reel.content?.videoUrl` is not null
   - Verify video player initialization

2. **Like Not Working?**
   - Check API response format
   - Verify `reel.interactions` is updated

3. **UI Not Updating?**
   - Make sure using `Obx()` widget
   - Check if `apiReels.refresh()` called

---

## 📝 Notes

- Old `ReelModel` ab deprecated hai
- New structure uses `Reel` class from `reel_response_model.dart`
- Video players are memory efficient (dispose properly)
- API calls are async and handle errors gracefully

