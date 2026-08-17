# Untappd API Schema Reference

Source: https://untappd.com/api/docs  
Base URL: `https://api.untappd.com/v4/` (HTTPS required)

## Status Legend

| Badge | Meaning |
|-------|---------|
| ✅ **Implemented** | Router case + `CDUntappdAPIClient` method + response model all exist |
| ⚠️ **Route Only** | `CDUntappdRouter` case exists but no client method or response wrapper |
| 🔲 **Not Implemented** | Nothing exists — no router case, no model, no client method |

## Global API Notes

- Every request must supply either `access_token` **or** `client_id` + `client_secret`
- Rate limit: 100 calls / hour per API key; 100 calls / hour per authenticated user
- Response headers: `X-Ratelimit-Limit`, `X-Ratelimit-Remaining`
- All dates returned as strings (e.g. `"Thu, 01 Jan 2015 00:00:00 +0000"`)
- All responses share the same `meta` envelope — see [Meta Envelope](#meta-envelope)

## Table of Contents

- [Meta Envelope](#meta-envelope)
- [Authentication](#authentication)
- [Feeds](#feeds)
  - [Activity Feed](#activity-feed-✅-implemented)
  - [User Activity Feed](#user-activity-feed-✅-implemented)
  - [Beer Activity Feed](#beer-activity-feed-✅-implemented)
  - [Brewery Activity Feed](#brewery-activity-feed-✅-implemented)
  - [Venue Activity Feed](#venue-activity-feed-✅-implemented)
  - [Notifications](#notifications-✅-implemented)
- [Info / Search](#info--search)
  - [User Info](#user-info-✅-implemented)
  - [User Wish List](#user-wish-list-✅-implemented)
  - [User Friends](#user-friends-✅-implemented)
  - [User Badges](#user-badges-✅-implemented)
  - [User Beers](#user-beers-✅-implemented)
  - [Beer Info](#beer-info-✅-implemented)
  - [Brewery Info](#brewery-info-✅-implemented)
  - [Venue Info](#venue-info-✅-implemented)
  - [Beer Search](#beer-search-✅-implemented)
  - [Brewery Search](#brewery-search-✅-implemented)
- [Actions](#actions)
  - [Checkin](#checkin-✅-implemented)
  - [Toast / Un-toast](#toast--un-toast-✅-implemented)
  - [Add Comment](#add-comment-✅-implemented)
  - [Remove Comment](#remove-comment-✅-implemented)
  - [Pending Friends](#pending-friends-✅-implemented)
  - [Add Friend](#add-friend-✅-implemented)
  - [Remove Friend](#remove-friend-✅-implemented)
  - [Accept Friend](#accept-friend-✅-implemented)
  - [Reject Friend](#reject-friend-✅-implemented)
  - [Add to Wish List](#add-to-wish-list-✅-implemented)
  - [Remove from Wish List](#remove-from-wish-list-✅-implemented)
- [Utilities](#utilities)
  - [Foursquare Lookup](#foursquare-lookup-✅-implemented)

---

## Meta Envelope

Every response shares the same outer envelope. The existing `CDUntappdMetadata` model covers this.

```json
{
  "meta": {
    "code": 200,
    "response_time": { "time": 0.1, "measure": "seconds" },
    "http_code": 200,
    "error_detail": "string (only present on error)",
    "error_type": "string (only present on error)"
  },
  "response": { ... }
}
```

**Current model:** `Source/CDUntappdMetadata.swift` — no changes needed.

---

## Authentication

OAuth 2.0 server-side flow. Already implemented in `CDUntappdOAuthClient` and `CDUntappdOAuthViewController`. No schema changes needed.

**Step 1 — Authorization redirect**
```
GET https://untappd.com/oauth/authenticate/
```
| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `client_id` | String | ✅ | Your app's client ID |
| `response_type` | String | ✅ | Always `"code"` |
| `redirect_url` | String | ✅ | Must match registered URL |
| `state` | String | ○ | Optional CSRF prevention token |

**Step 2 — Code exchange**
```
GET https://untappd.com/oauth/authorize/
```
| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `client_id` | String | ✅ | |
| `client_secret` | String | ✅ | |
| `response_type` | String | ✅ | Always `"code"` |
| `redirect_url` | String | ✅ | |
| `code` | String | ✅ | Code from Step 1 redirect |

**Response:**
```json
{ "response": { "access_token": "string" } }
```

Current implementation decodes this via `CDUntappdOAuthCredential` using `CodingKey` raw value `"response.access_token"`. See [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys).

---

## Feeds

---

### Activity Feed ✅ Implemented

```
GET /v4/checkin/recent
```
**Auth required:** Yes (`access_token`)
**Client method:** `fetchActivityFeed(maxId:minId:limit:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdActivityFeedResponse` → `[CDUntappdCheckin]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `max_id` | Int | ○ | Return results with checkin_id ≤ max_id |
| `min_id` | Int | ○ | Return results with checkin_id ≥ min_id (newer) |
| `limit` | Int | ○ | Default 25, max 50 |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "checkins": {
      "count": 25,
      "items": [ { /* CDUntappdCheckin shape */ } ]
    }
  }
}
```

**Schema verification — `CDUntappdActivityFeedResponse`:** decodes via nested-container `init(from:)` (`response` → `checkins` → `items` → `[CDUntappdCheckin]`), not a dotted `CodingKey` path — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys). Reused as-is by [User](#user-activity-feed-✅-implemented), [Beer](#beer-activity-feed-✅-implemented), [Brewery](#brewery-activity-feed-✅-implemented), and [Venue Activity Feed](#venue-activity-feed-✅-implemented) below — all five share this identical response shape.

**Schema verification — `CDUntappdCheckin`:** `comments` (`[CDUntappdComment]?`) is now decoded, following the `{"items": [...]}`-wrapped shape already verified for this type's `badges`/`media` fields and used consistently for list fields elsewhere in the API. Unlike `badges`/`media`, this specific shape has not been captured from a live response — no endpoint response containing a checkin with comments has been verified against this doc. Treat as a confident inference (flagged as such in the model's own doc comment), not a verified shape. `toasts` remains commented out — no `CDUntappdToast` model exists yet. Otherwise unchanged, already correct.

---

### User Activity Feed ✅ Implemented

```
GET /v4/user/checkins/{USERNAME}
```
**Auth required:** No (pass client credentials or access_token)
**Client method:** `fetchUserActivityFeed(forUsername:maxId:minId:limit:)` in `CDUntappdAPIClient`
**Response model:** Reuses `CDUntappdActivityFeedResponse` — identical shape to [Activity Feed](#activity-feed-✅-implemented).

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `USERNAME` | String (path) | ○ | Omit to use authenticated user |
| `max_id` | Int | ○ | |
| `min_id` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 25 |

---

### Beer Activity Feed ✅ Implemented

```
GET /v4/beer/checkins/{BID}
```
**Auth required:** No
**Client method:** `fetchBeerActivityFeed(forBid:maxId:minId:limit:)` in `CDUntappdAPIClient`
**Response model:** Reuses `CDUntappdActivityFeedResponse`.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `BID` | Int (path) | ✅ | Beer ID |
| `max_id` | Int | ○ | |
| `min_id` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 25 |

---

### Brewery Activity Feed ✅ Implemented

```
GET /v4/brewery/checkins/{BREWERY_ID}
```
**Auth required:** No
**Client method:** `fetchBreweryActivityFeed(forBreweryId:maxId:minId:limit:)` in `CDUntappdAPIClient`
**Response model:** Reuses `CDUntappdActivityFeedResponse`.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `BREWERY_ID` | Int (path) | ✅ | |
| `max_id` | Int | ○ | |
| `min_id` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 25 |

---

### Venue Activity Feed ✅ Implemented

```
GET /v4/venue/checkins/{VENUE_ID}
```
**Auth required:** No
**Client method:** `fetchVenueActivityFeed(forVenueId:maxId:minId:limit:)` in `CDUntappdAPIClient`
**Response model:** Reuses `CDUntappdActivityFeedResponse`.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `VENUE_ID` | Int (path) | ✅ | |
| `max_id` | Int | ○ | |
| `min_id` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 25 |

---

### Notifications ✅ Implemented

```
GET /v4/notifications
```
**Auth required:** Yes (`access_token`)
**Client method:** `fetchNotifications(offset:limit:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdNotificationsResponse` → `[CDUntappdNotification]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `offset` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 25 |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "items": [
      {
        "notification_id": 1,
        "type": "toast",
        "created_at": "string",
        "user": { "uid": 1, "user_name": "string", "first_name": "string", "user_avatar": "string" },
        "checkin": {
          "checkin_id": 1,
          "checkin_comment": "string or null"
        }
      }
    ]
  }
}
```

**Schema verification — `CDUntappdNotificationsResponse`:** decodes via nested-container `init(from:)` (`response` → `items` → `[CDUntappdNotification]`), not a dotted `CodingKey` path — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys). One level shallower than [Activity Feed](#activity-feed-✅-implemented)'s `response.checkins.items` — there is no intermediate `notifications` container, `items` sits directly under `response`.

**Schema verification — `CDUntappdNotification`:** `checkin` reuses the existing `CDUntappdCheckin` model (its `comment` field maps from `checkin_comment`, matching every other endpoint that embeds a checkin — the flat `"shout"` key in an earlier draft of this doc's sample JSON did not match that convention and has been corrected above). `user` reuses the existing `CDUntappdUser` model, which already treats every field as optional so the compact user object here decodes cleanly.

---

## Info / Search

---

### User Info ✅ Implemented

```
GET /v4/user/info/{USERNAME}
```
**Client method:** `fetchUserInfo(forUsername:compact:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdUserInfoResponse` → `CDUntappdUser`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `USERNAME` | String (path) | ○ | Omit with `access_token` for authenticated user |
| `compact` | String | ○ | `"true"` omits checkins, media, recent_brews |

**Schema verification — `CDUntappdUserInfoResponse`:**

| JSON path | CodingKey raw value | Status |
|-----------|---------------------|--------|
| `meta` | `"meta"` | ✅ |
| `response.user` | `"response.user"` | ⚠️ See Issue #1 |

**Schema verification — `CDUntappdUser`:**

| JSON key | CodingKey raw value | Swift property | Status |
|----------|---------------------|----------------|--------|
| `uid` | `"uid"` | `uid: Int?` | ✅ |
| `user_name` | `"user_name"` | `username: String?` | ✅ |
| `first_name` | `"first_name"` | `firstName: String?` | ✅ |
| `last_name` | `"last_name"` | `lastName: String?` | ✅ |
| `user_avatar` | `"user_avatar"` | `userAvatar: URL?` | ✅ |
| `user_avatar_hd` | `"user_avatar_hd"` | `userAvatatHd: URL?` | ⚠️ Typo in property name: `userAvatatHd` should be `userAvatarHd` |
| `user_cover_photo` | `"user_cover_photo"` | `userCoverPhoto: URL?` | ✅ |
| `location` | `"location"` | `location: String?` | ✅ |
| `bio` | `"bio"` | `bio: String?` | ✅ |
| `url` (website) | `"url"` | `website: URL?` | ⚠️ API docs show this key as `"website"` — verify against live response |
| `is_private` | `"is_private"` | `isPrivate: Bool?` | ✅ |
| `relationship` | `"relationship"` | `relationship: String?` | ✅ |
| `stats` | `"stats"` | `stats: CDUntappdStats?` | ✅ |
| `checkins.items` | `"checkins.items"` | `checkins: [CDUntappdCheckin]?` | ⚠️ See Issue #1 |
| `date_joined` | `"date_joined"` | `dateJoined: String?` | ✅ |
| `settings` | `"settings"` | `settings: CDUntappdSettings?` | ✅ |

**Typo fix needed:** Rename `userAvatatHd` → `userAvatarHd` in `CDUntappdUser.swift`:
- Change property name on line 44
- Change `CodingKey` case on line 72
- This is a public property rename — it is a breaking API change. Defer to v3.0.0.

---

### User Wish List ✅ Implemented

```
GET /v4/user/wishlist/{USERNAME}
```
**Client method:** `fetchUserWishList(forUsername:offset:limit:sort:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdUserWishListResponse` → `CDUntappdWishList` → `[CDUntappdWishListItem]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `USERNAME` | String (path) | ○ | |
| `offset` | Int | ○ | Zero-based |
| `limit` | Int | ○ | Default 25, max 50 |
| `sort` | String | ○ | `date`, `checkin`, `highest_rated`, `lowest_rated`, `highest_abv`, `lowest_abv` |

**Schema verification — `CDUntappdUserWishListResponse`:**

| JSON path | CodingKey raw value | Status |
|-----------|---------------------|--------|
| `meta` | `"meta"` | ✅ |
| `response` | `"response"` | ✅ |

**Schema verification — `CDUntappdWishList`:**

| JSON key | CodingKey raw value | Swift property | Status |
|----------|---------------------|----------------|--------|
| `response.beers.items` | `"beers.items"` | `items: [CDUntappdWishListItem]?` | ⚠️ See Issue #1 |
| `updated_at` | `"updated_at"` | `updatedAt: String?` | ✅ |

**Schema verification — `CDUntappdWishListItem`:**

The API returns wish list items with a `beer` object and a `wish_list_added_at` timestamp. The current model has `createdAt` mapped to `"created_at"`, but the live API field for wish list items is `"wish_list_added_at"`.

| JSON key | CodingKey raw value | Swift property | Status |
|----------|---------------------|----------------|--------|
| `beer` | `"beer"` | `beer: CDUntappdBeer?` | ✅ |
| `brewery` | `"brewery"` | `brewery: CDUntappdBrewery?` | ✅ |
| `wish_list_added_at` | `"created_at"` | `createdAt: String?` | ⚠️ Wrong key — should be `"wish_list_added_at"` |

**Fix needed in `CDUntappdWishListItem.swift`:**
```swift
// Change:
case createdAt = "created_at"
// To:
case createdAt = "wish_list_added_at"
```

---

### User Friends ✅ Implemented

```
GET /v4/user/friends/{USERNAME}
```
**Client method:** `fetchUserFriends(forUsername:offset:limit:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdUserFriendsResponse` → `[CDUntappdFriend]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `USERNAME` | String (path) | ○ | |
| `offset` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 25 |

**Schema verification — `CDUntappdUserFriendsResponse`:**

| JSON path | CodingKey raw value | Status |
|-----------|---------------------|--------|
| `meta` | `"meta"` | ✅ |
| `response.items` | `"response.items"` | ⚠️ See Issue #1 |

**Schema verification — `CDUntappdFriend`:**

The API returns friends list items where each item is a friendship object wrapping a user. The current `CDUntappdFriend` has a `user: CDUntappdUser?` sub-object, which matches the actual API shape (each friend item contains a nested `user` object).

| JSON key | CodingKey raw value | Swift property | Status |
|----------|---------------------|----------------|--------|
| `friendship_hash` | `"friendship_hash"` | `friendshipHash: String?` | ✅ |
| `user` | `"user"` | `user: CDUntappdUser?` | ✅ |
| `mutual_friends.items` | `"mutual_friends.items"` | `mutualFriends: [CDUntappdFriend]?` | ⚠️ See Issue #1 |
| `created_at` | `"created_at"` | `createdAt: String?` | ✅ |

---

### User Badges ✅ Implemented

```
GET /v4/user/badges/{USERNAME}
```
**Client method:** `fetchUserBadges(forUsername:offset:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdUserBadgesResponse` → `[CDUntappdBadge]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `USERNAME` | String (path) | ○ | |
| `offset` | Int | ○ | |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "badges": {
      "count": 10,
      "items": [
        {
          "badge_id": 1,
          "badge_name": "string",
          "badge_description": "string",
          "badge_image": { "sm": "url", "md": "url", "lg": "url" },
          "user_badge_id": 1,
          "created_at": "string"
        }
      ]
    }
  }
}
```

**Schema verification — `CDUntappdUserBadgesResponse`:** decodes via nested-container `init(from:)` (`response` → `badges` → `items`), not a dotted `CodingKey` path — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys). An earlier draft of this response model omitted the intermediate `badges` container (decoding `response.items` directly); caught and fixed during v3.1.0 code review before merge, since the real API nests one level deeper than that draft assumed.

**Schema verification — `CDUntappdBadge`:** unchanged, all fields already matched.

---

### User Beers ✅ Implemented

```
GET /v4/user/beers/{USERNAME}
```
**Client method:** `fetchUserBeers(forUsername:offset:limit:sort:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdUserBeersResponse` → `[CDUntappdBeerItem]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `USERNAME` | String (path) | ○ | |
| `offset` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 50 |
| `sort` | String | ○ | `date`, `checkin`, `highest_rated`, `lowest_rated`, `highest_rated_you`, `lowest_rated_you` — see `CDUntappdUserBeersSortType` |
| `start_date` | String | 🔲 | Format: `YYYY-MM-DD` — **not implemented**, not required by v3.1.0's scope |
| `end_date` | String | 🔲 | Format: `YYYY-MM-DD` — **not implemented**, not required by v3.1.0's scope |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "beers": {
      "count": 25,
      "total_count": 500,
      "items": [
        {
          "count": 3,
          "first_created_at": "string",
          "recent_created_at": "string",
          "beer": { /* CDUntappdBeer shape */ },
          "brewery": { /* CDUntappdBrewery shape */ }
        }
      ]
    }
  }
}
```

**Schema verification — `CDUntappdUserBeersResponse`:** decodes via nested-container `init(from:)` (`response` → `beers` → `items`). Item shape uses the shared `CDUntappdBeerItem` model (`count`/`first_created_at`/`recent_created_at`/`beer`/`brewery`) rather than a dedicated `CDUntappdUserBeerItem` type — reused by [Beer Search](#beer-search-✅-implemented) too, since both endpoints return the same item shape.

**`sort`:** a dedicated `CDUntappdUserBeersSortType` enum was added instead of reusing `CDUntappdUserWishListSortType` — the wish-list enum offers `highest_abv`/`lowest_abv`, which this endpoint doesn't accept, and was missing `highest_rated_you`/`lowest_rated_you`, which it does. Verified against the live Untappd API docs.

**Known gap:** `start_date`/`end_date` filtering was not implemented — not required by [issue #3](https://github.com/chrisdhaan/CDUntappdKit/issues/3)'s checklist. Would be a small additive follow-up (two more optional String params on `userBeersParameters`) if a consumer needs it.

**Response model's `totalCount` field was dropped** from the original plan — `CDUntappdUserBeersResponse` currently only exposes the `beers` array, not `response.beers.total_count`. Same category of gap as `start_date`/`end_date`: cheap to add later, not required by the tracked issue.

---

### Beer Info ✅ Implemented

```
GET /v4/beer/info/{BID}
```
**Client method:** `fetchBeerInfo(forBid:compact:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdBeerInfoResponse` → `CDUntappdBeer`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `BID` | Int (path) | ✅ | Beer ID |
| `compact` | String | ○ | `"true"` omits checkins, media, variants |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "beer": {
      "bid": 456,
      "beer_name": "string",
      "beer_label": "url",
      "beer_abv": 6.5,
      "beer_ibu": 60,
      "beer_description": "string",
      "beer_style": "IPA - American",
      "auth_rating": 4.0,
      "rating_score": 3.8,
      "rating_count": 1000,
      "stats": {
        "total_count": 1000,
        "monthly_count": 50,
        "total_user_count": 800,
        "user_count": 1
      },
      "brewery": { /* CDUntappdBrewery shape */ },
      "checkins": { "items": [] },
      "media": { "items": [] }
    }
  }
}
```

**Schema verification — `CDUntappdBeer`:**

| JSON key | CodingKey raw value | Swift property | Status |
|----------|---------------------|----------------|--------|
| `bid` | `"bid"` | `id: Int?` | ✅ |
| `beer_name` | `"beer_name"` | `name: String?` | ✅ |
| `beer_description` | `"beer_description"` | `description: String?` | ✅ |
| `beer_style` | `"beer_style"` | `style: String?` | ✅ |
| `beer_abv` | `"beer_abv"` | `abv: Double?` | ✅ |
| `beer_ibu` | `"beer_ibu"` | `ibu: Double?` | ✅ |
| `auth_rating` | `"auth_rating"` | `rating: Double?` | ✅ |
| `rating_score` | `"rating_score"` | `overallRating: Double?` | ✅ |
| `rating_count` | `"rating_count"` | `totalRatings: Int?` | ✅ |
| `beer_label` | `"beer_label"` | `label: URL?` | ✅ |
| `is_in_production` | `"is_in_production"` | `isInProduction: Bool?` | ✅ Fixed in v3.1.0 — API returns `1`/`0` (Int); `CDUntappdBeer` now decodes this leniently from either an Int or a Bool (custom `init(from:)`, matching the existing `CDUntappdBrewery.isActive`/`CDUntappdVenue.isVerified` pattern below). Caught during v3.1.0 code review. |
| `has_had` | `"has_had"` | `hasHad: Bool?` | ✅ |
| `wish_list` | `"wish_list"` | `isOnWishList: Bool?` | ✅ |
| `created_at` | `"created_at"` | `createdAt: String?` | ✅ |
| `stats` | — | — | 🔲 `CDUntappdBeer` still has no `stats` property — not required by [issue #3](https://github.com/chrisdhaan/CDUntappdKit/issues/3)'s checklist, left as a future addition (`CDUntappdBeerStats`: `total_count`/`monthly_count`/`total_user_count`/`user_count`). |

**Response model:** `CDUntappdBeerInfoResponse` decodes via nested-container `init(from:)` (`response` → `beer`), not a dotted `CodingKey` path — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys).

---

### Brewery Info ✅ Implemented

```
GET /v4/brewery/info/{BREWERY_ID}
```
**Client method:** `fetchBreweryInfo(forBreweryId:compact:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdBreweryInfoResponse` → `CDUntappdBrewery`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `BREWERY_ID` | Int (path) | ✅ | |
| `compact` | String | ○ | `"true"` omits checkins, media, beer_list |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "brewery": {
      "brewery_id": 1,
      "brewery_name": "string",
      "brewery_slug": "string",
      "brewery_label": "url",
      "brewery_description": "string",
      "brewery_website": "url",
      "brewery_active": 1,
      "country_name": "string",
      "contact": { "twitter": "string", "facebook": "url", "instagram": "string", "url": "url" },
      "location": { "brewery_city": "string", "brewery_state": "string", "lat": 0.0, "lng": 0.0 },
      "stats": { "total_count": 0, "unique_count": 0, "monthly_count": 0, "weekly_count": 0, "user_count": 0 },
      "checkins": { "items": [] },
      "media": { "items": [] },
      "beer_list": { "items": [] }
    }
  }
}
```

**Schema verification — `CDUntappdBrewery`:**

| JSON key | CodingKey raw value | Swift property | Status |
|----------|---------------------|----------------|--------|
| `brewery_id` | `"brewery_id"` | `id: Int?` | ✅ |
| `brewery_name` | `"brewery_name"` | `name: String?` | ✅ |
| `brewery_active` | `"brewery_active"` | `isActive: Bool?` | ✅ Already fixed pre-v3.1.0 (predates this release) — API returns `1`/`0` (Int); `CDUntappdBrewery` decodes leniently from either an Int or a Bool via a custom `init(from:)`. This lenient-decode pattern was the precedent followed for `CDUntappdBeer.isInProduction`'s v3.1.0 fix above, in preference to this doc's originally-suggested `Bool?` → `Int?` type change. |
| `brewery_label` | `"brewery_label"` | `label: URL?` | ✅ |
| `brewery_slug` | `"brewery_slug"` | `slug: String?` | ✅ |
| `location.lat` | `"location.lat"` | `latitude: Double?` | ✅ |
| `location.lng` | `"location.lng"` | `longitude: Double?` | ✅ |
| `location.brewery_city` | `"location.brewery_city"` | `city: String?` | ✅ |
| `location.brewery_state` | `"location.brewery_state"` | `state: String?` | ✅ |
| `country_name` | `"country_name"` | `country: String?` | ✅ |
| `contact.facebook` | `"contact.facebook"` | `facebookUrl: URL?` | ✅ |
| `contact.twitter` | `"contact.twitter"` | `twitterHandle: String?` | ✅ |
| `contact.instagram` | `"contact.instagram"` | `instagramHandle: String?` | ✅ |
| `contact.url` | `"contact.url"` | `website: URL?` | ✅ |
| `brewery_description` | — | — | 🔲 Still not decoded — not required by [issue #3](https://github.com/chrisdhaan/CDUntappdKit/issues/3)'s checklist, left as a future addition. |
| `stats` | — | — | 🔲 Still missing (`CDUntappdBreweryStats`) — same as above, left as a future addition. |

**Response model:** `CDUntappdBreweryInfoResponse` decodes via nested-container `init(from:)` (`response` → `brewery`), not a dotted `CodingKey` path — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys).

---

### Venue Info ✅ Implemented

```
GET /v4/venue/info/{VENUE_ID}
```
**Client method:** `fetchVenueInfo(forVenueId:compact:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdVenueInfoResponse` → `CDUntappdVenue`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `VENUE_ID` | Int (path) | ✅ | |
| `compact` | String | ○ | `"true"` omits checkins, media, top_beers |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "venue": {
      "venue_id": 1,
      "venue_name": "string",
      "venue_slug": "string",
      "primary_category": "string",
      "parent_category_id": "string",
      "categories": { "count": 1, "items": [ { "category_id": 1, "category_name": "string", "category_key": "string", "is_primary": true } ] },
      "location": { "venue_address": "string", "venue_city": "string", "venue_state": "string", "venue_country": "string", "lat": 0.0, "lng": 0.0 },
      "foursquare": { "foursquare_id": "string", "foursquare_url": "url" },
      "venue_icon": { "sm": "url", "md": "url", "lg": "url" },
      "is_verified": 0,
      "stats": { "total_checkins": 0, "total_user_count": 0, "weekly_checkins": 0 },
      "contact": { "twitter": "string", "venue_url": "url" },
      "checkins": { "items": [] },
      "media": { "items": [] },
      "top_beers": { "items": [] }
    }
  }
}
```

**Schema verification — `CDUntappdVenue`:**

| JSON key | CodingKey raw value | Swift property | Status |
|----------|---------------------|----------------|--------|
| `venue_id` | `"venue_id"` | `id: Int?` | ✅ |
| `venue_name` | `"venue_name"` | `name: String?` | ✅ |
| `is_verified` | `"is_verified"` | `isVerified: Bool?` | ✅ Already fixed pre-v3.1.0 (predates this release) — decodes leniently from either an Int or a Bool, same pattern as `CDUntappdBrewery.isActive` above. |
| `parent_category_id` | `"parent_category_id"` | `parentCategoryId: String?` | ✅ |
| `primary_category` | `"primary_category"` | `primaryCategory: String?` | ✅ |
| `categories.items` | `"categories.items"` | `categories: [CDUntappdCategory]?` | ✅ |
| `venue_icon.sm` | `"venue_icon.sm"` | `smallIcon: URL?` | ✅ |
| `venue_icon.md` | `"venue_icon.md"` | `mediumIcon: URL?` | ✅ |
| `venue_icon.lg` | `"venue_icon.lg"` | `largeIcon: URL?` | ✅ |
| `venue_slug` | `"venue_slug"` | `slug: String?` | ✅ |
| `location.lat` | `"location.lat"` | `latitude: Double?` | ✅ |
| `location.lng` | `"location.lng"` | `longitude: Double?` | ✅ |
| `location.venue_address` | `"location.venue_address"` | `address: String?` | ✅ |
| `location.venue_city` | `"location.venue_city"` | `city: String?` | ✅ |
| `location.venue_state` | `"location.venue_state"` | `state: String?` | ✅ |
| `location.venue_country` | `"location.venue_country"` | `country: String?` | ✅ |
| `foursquare.foursquare_id` | `"foursquare.foursquare_id"` | `foursqaureId: String?` | 🔲 Typo still present: `foursqaureId` → should be `foursquareId`. Breaking rename, out of scope for v3.1.0 (additive-only release) — same status as [Schema Issue #3](#schema-issue-3--typos-in-public-property-names). |
| `foursquare.foursquare_url` | `"foursquare.foursquare_url"` | `foursqaureUrl: URL?` | 🔲 Typo still present: `foursqaureUrl` → should be `foursquareUrl`. Same as above. |
| `contact.twitter` | `"contact.twitter"` | `twitterHandle: String?` | ✅ |
| `contact.venue_url` | `"contact.venue_url"` | `website: URL?` | ✅ |
| `stats` | — | — | 🔲 Still missing (`CDUntappdVenueStats`) — not required by [issue #3](https://github.com/chrisdhaan/CDUntappdKit/issues/3)'s checklist, left as a future addition. |

**Response model:** `CDUntappdVenueInfoResponse` decodes via nested-container `init(from:)` (`response` → `venue`), not a dotted `CodingKey` path — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys).

---

### Beer Search ✅ Implemented

```
GET /v4/search/beer
```
**Client method:** `searchBeers(query:offset:limit:sort:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdBeerSearchResponse` → `[CDUntappdBeerItem]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `q` | String | ✅ | Search term — Untappd recommends "Brewery Name + Beer Name" |
| `offset` | Int | ○ | |
| `limit` | Int | ○ | Default 25, max 50 |
| `sort` | String | ○ | `checkin` (default), `name` — see `CDUntappdBeerSearchSortType` |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "beers": {
      "count": 25,
      "items": [
        {
          "beer": { "bid": 1, "beer_name": "string", "beer_label": "url", "beer_abv": 5.0, "beer_ibu": 40, "beer_style": "string", "rating_score": 3.8 },
          "brewery": { "brewery_id": 1, "brewery_name": "string", "brewery_slug": "string", "brewery_label": "url" }
        }
      ]
    }
  }
}
```

**Schema verification — `CDUntappdBeerSearchResponse`:** decodes via nested-container `init(from:)` (`response` → `beers` → `items`), reusing the same shared `CDUntappdBeerItem` model as [User Beers](#user-beers-✅-implemented) — rather than a dedicated `CDUntappdBeerSearchResult` type as originally planned. Search results simply decode `count`/`first_created_at`/`recent_created_at` as `nil` (those fields don't exist in the search response), which is a minor field-access-fidelity tradeoff, not a decoding bug, in exchange for one fewer type. `count` (total results found) is not currently exposed on `CDUntappdBeerSearchResponse` — same category of gap as `CDUntappdUserBeersResponse.totalCount` above.

---

### Brewery Search ✅ Implemented

```
GET /v4/search/brewery
```
**Client method:** `searchBreweries(query:offset:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdBrewerySearchResponse` → `[CDUntappdBrewery]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` OR `client_id`+`client_secret` | String | ✅ | |
| `q` | String | ✅ | Search term |
| `offset` | Int | ○ | |
| `limit` | Int | 🔲 | Default 25, max 50 — **not implemented**; `searchBreweries` only takes `query`/`offset`, not required by v3.1.0's scope |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "breweries": {
      "count": 10,
      "items": [
        {
          "brewery_id": 1,
          "brewery_name": "string",
          "brewery_slug": "string",
          "brewery_label": "url",
          "brewery_country": "string",
          "brewery_city": "string",
          "brewery_state": "string"
        }
      ]
    }
  }
}
```

**Schema verification — `CDUntappdBrewerySearchResponse`:** decodes via nested-container `init(from:)` (`response` → `breweries` → `items`), with search-result items decoding as **flat `CDUntappdBrewery` objects**, exactly as documented above — no extra item wrapper type needed, matching this doc's original research.

**Note on how this shipped:** the first PR draft introduced an unnecessary `CDUntappdBreweryItem{brewery: CDUntappdBrewery}` wrapper type and nested items one level too deep. An automated code-review pass then "corrected" the top-level key from `breweries` to a singular `brewery`, based on an unverifiable claim about the live API docs — which contradicted this document's `breweries` (plural) shape, and which this document's example (written from earlier direct research) turned out to be right about. Both issues were caught by cross-checking this document against the shipped code and fixed before merge: the response model now matches this doc's documented shape exactly (`response.breweries.items[]`, flat `CDUntappdBrewery` items), and `CDUntappdBreweryItem.swift` was deleted as dead code. **Takeaway:** this document is the higher-trust source for real API shapes in this repo — prefer it over an agent's unverifiable recollection of API docs it couldn't actually fetch.

`count` (total results found) is not currently exposed on `CDUntappdBrewerySearchResponse` — same category of gap as the other search/list endpoints above.

---

## Actions

All action endpoints require `access_token` — they cannot use client credentials.

---

### Checkin ✅ Implemented

```
POST /v4/checkin/add
```
**Client method:** `addCheckin(bid:gmtOffset:timezone:foursquareId:latitude:longitude:shout:rating:facebook:twitter:foursquare:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdCheckinResponse` → `CDUntappdCheckin`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `gmt_offset` | String | ✅ | Hours offset from GMT e.g. `"-5"` |
| `timezone` | String | ✅ | Abbreviation e.g. `"EST"` |
| `bid` | Int | ✅ | Beer ID |
| `foursquare_id` | String | ○ | Foursquare MD5 venue ID |
| `geolat` | Float | ○ | Required if adding location |
| `geolng` | Float | ○ | Required if adding location |
| `shout` | String | ○ | Comment, max 140 characters |
| `rating` | Float | ○ | `1.0`–`5.0`, half increments allowed, `0` not allowed |
| `facebook` | String | ○ | `"on"` or `"off"` (default `"off"`) |
| `twitter` | String | ○ | `"on"` or `"off"` (default `"off"`) |
| `foursquare` | String | ○ | `"on"` or `"off"` — requires geolat/geolng |

**Response shape:** Returns the created `CDUntappdCheckin` object inside `response.checkin`.

**Schema verification — `CDUntappdCheckinResponse`:** decodes via nested-container `init(from:)` (`response` → `checkin`), not the dotted `CodingKey` path shown in the original implementation-plan snippet — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys). POST body parameters are encoded via `CDUntappdParameterEncoding.httpBodyRequest(for:parameters:)`, this endpoint's first use of `httpBody` encoding in the client.

---

### Toast / Un-toast ✅ Implemented

Toggles a toast on a check-in (calling it again removes the toast).

```
POST /v4/checkin/toast/{CHECKIN_ID}
```
**Client method:** `toast(checkinId:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdToastResponse`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `CHECKIN_ID` | Int (path) | ✅ | |

**Response shape:**
```json
{ "meta": { "code": 200 }, "response": { "result": "success" } }
```

**Schema verification — `CDUntappdToastResponse`:** decodes via nested-container `init(from:)` (`response` → `result`), not the dotted `CodingKey` path shown in the original implementation-plan snippet — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys).

---

### Add Comment ✅ Implemented

```
POST /v4/checkin/addcomment/{CHECKIN_ID}
```
**Client method:** `addComment(toCheckinId:comment:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdAddCommentResponse` → `CDUntappdComment`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `CHECKIN_ID` | Int (path) | ✅ | |
| `comment` | String | ✅ | Max 140 characters |

**Response shape:** Returns the created comment object with `comment_id`, `user`, `comment`, `created_at`.

**Schema verification — `CDUntappdAddCommentResponse`:** decodes via nested-container `init(from:)` (`response` → `comment`), not the dotted `CodingKey` path shown in the original implementation-plan snippet — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys).

**Schema verification — `CDUntappdComment`:** unchanged, matches the original implementation-plan snippet exactly.

---

### Remove Comment ✅ Implemented

```
POST /v4/checkin/deletecomment/{COMMENT_ID}
```
**Client method:** `removeComment(commentId:)` in `CDUntappdAPIClient`
**Response model:** none — returns `Void`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `COMMENT_ID` | Int (path) | ✅ | |

**Response shape:** Returns HTTP 204 — `response` object is empty.

**Schema verification:** since there's no body to decode, this endpoint uses `CDUntappdURLSession`'s `Void`-returning `perform(_:)` overload, which validates only the HTTP status code (200–299) — a deviation from the original implementation-plan note suggesting `CDUntappdMetadata` as the return type. No new response model was needed.

---

### Pending Friends ✅ Implemented

Returns pending friend requests for the authenticated user.

```
GET /v4/user/pending
```
**Client method:** `fetchPendingFriends(offset:limit:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdPendingFriendsResponse` → `[CDUntappdFriend]`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `offset` | Int | ○ | |
| `limit` | Int | ○ | Default: all results |

**Response shape:** Array of user objects (same shape as friends list items).

**Schema verification — `CDUntappdPendingFriendsResponse`:** the `items` array decodes as `[CDUntappdFriend]`, not `[CDUntappdUser]` as the original implementation-plan snippet said — pending-friend list items have the same shape as `CDUntappdUserFriendsResponse`'s items (including the `mutual_friends` field), so the existing `CDUntappdFriend` model was reused rather than introducing a duplicate user-only type. It also decodes via nested-container `init(from:)` (`response` → `items`), not the dotted `CodingKey` path shown in the original snippet — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys).

---

### Add Friend ✅ Implemented

Sends a friend request to a user.

```
GET /v4/friend/request/{TARGET_ID}
```
**Client method:** `addFriend(targetId:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdActionResultResponse`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `TARGET_ID` | Int (path) | ✅ | Target user's uid |

**Response shape:** `{ "response": { "result": boolean } }`

**Schema verification — `CDUntappdActionResultResponse`:** decodes via nested-container `init(from:)` (`response` → `result`), not the dotted `CodingKey` path shown in the original implementation-plan snippet — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys). Named `CDUntappdActionResultResponse`, not `CDUntappdFriendActionResponse` as the original plan named it, since it's shared by all six boolean-result action endpoints (the four friend actions plus add/remove wish list), not just the friend ones.

---

### Remove Friend ✅ Implemented

```
GET /v4/friend/remove/{TARGET_ID}
```
**Client method:** `removeFriend(targetId:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdActionResultResponse`

Same shape as [Add Friend](#add-friend-✅-implemented).

---

### Accept Friend ✅ Implemented

```
GET /v4/friend/accept/{TARGET_ID}
```
**Client method:** `acceptFriend(targetId:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdActionResultResponse`

Same shape as [Add Friend](#add-friend-✅-implemented).

---

### Reject Friend ✅ Implemented

```
GET /v4/friend/reject/{TARGET_ID}
```
**Client method:** `rejectFriend(targetId:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdActionResultResponse`

Same shape as [Add Friend](#add-friend-✅-implemented).

**Shared model for six action endpoints** (the four friend actions here plus [Add to Wish List](#add-to-wish-list-✅-implemented) / [Remove from Wish List](#remove-from-wish-list-✅-implemented)): `Source/CDUntappdActionResultResponse.swift`, decoding `{ "response": { "result": Bool } }` via nested-container `init(from:)`.

---

### Add to Wish List ✅ Implemented

```
GET /v4/user/wishlist/add
```
**Client method:** `addToWishList(bid:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdActionResultResponse` (reused — see [friend actions](#reject-friend-✅-implemented))

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `bid` | Int | ✅ | Beer ID to add |

**Response shape:** `{ "response": { "result": boolean } }`

---

### Remove from Wish List ✅ Implemented

```
GET /v4/user/wishlist/delete
```
**Client method:** `removeFromWishList(bid:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdActionResultResponse` (reused — see [friend actions](#reject-friend-✅-implemented))

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `bid` | Int | ✅ | Beer ID to remove |

**Response shape:** Same boolean result.

---

## Utilities

---

### Foursquare Lookup ✅ Implemented

```
GET /v4/venue/foursquare_lookup/{VENUE_ID}
```
**Auth required:** Yes (`access_token`)
**Client method:** `lookupVenue(byFoursquareId:)` in `CDUntappdAPIClient`
**Response model:** `CDUntappdFoursquareLookupResponse` → `CDUntappdVenue`

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `access_token` | String | ✅ | |
| `VENUE_ID` | String (path) | ✅ | Foursquare v2 venue ID |

**Full response shape:**
```json
{
  "meta": { "code": 200 },
  "response": {
    "venue": {
      "venue_id": 1,
      "venue_name": "string",
      "foursquare": { "foursquare_id": "string", "foursquare_url": "url" }
    }
  }
}
```

**Schema verification — `CDUntappdFoursquareLookupResponse`:** decodes via nested-container `init(from:)` (`response` → `venue`), not a dotted `CodingKey` path — see [Schema Issue #1](#schema-issue-1--dotted-path-codingkeys). Reuses the existing `CDUntappdVenue` model, whose own decoder already expects `foursquare_id`/`foursquare_url` nested under a `foursquare` object (not top-level keys, unlike an earlier draft of this doc's sample JSON).

**Schema verification — `CDUntappdVenue`:** unchanged, no new fields needed for this endpoint.

---

## Known Schema Issues

### Schema Issue #1 — Dotted-path CodingKeys

Several models use dotted strings as `CodingKey` raw values to express nested JSON paths:
```swift
case user = "response.user"          // CDUntappdUserInfoResponse
case items = "beers.items"           // CDUntappdWishList
case friends = "response.items"      // CDUntappdUserFriendsResponse
case mutualFriends = "mutual_friends.items"  // CDUntappdFriend
```

**Swift's `Codable` does not support dotted key paths as `CodingKey` raw values.** The decoder looks for a literal JSON key named `"response.user"`, not a nested path. If the live API returns a standard nested structure (`{"response": {"user": {...}}}`), these properties will always decode as `nil`.

This means all three "implemented" endpoints may silently return `nil` for their primary payload fields in practice.

**How to verify:** Call `fetchUserInfo(forUsername:compact:)` in the iOS Example app and print whether `response.user` is non-nil.

**Fix (if broken):** Replace dotted-path keys with proper nested container decoding using `init(from:)`. Example for `CDUntappdUserInfoResponse`:

```swift
public struct CDUntappdUserInfoResponse: Decodable, Sendable {
    public var metadata: CDUntappdMetadata?
    public var user: CDUntappdUser?

    private enum RootKeys: String, CodingKey { case meta, response }
    private enum ResponseKeys: String, CodingKey { case user }

    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        metadata = try root.decodeIfPresent(CDUntappdMetadata.self, forKey: .meta)
        let responseContainer = try root.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response)
        user = try responseContainer.decodeIfPresent(CDUntappdUser.self, forKey: .user)
    }
}
```

Apply the same pattern to all dotted-path models. This is the most impactful bug to verify and fix before implementing new endpoints — all new response models in this document use the same convention and will have the same issue if the convention is broken.

### Schema Issue #2 — `Bool` vs `Int` for flag fields

`CDUntappdBrewery.isActive` and `CDUntappdVenue.isVerified` are declared as `Bool?` but the Untappd API returns `1`/`0` integers. Swift's `JSONDecoder` in its default configuration cannot decode an integer as a `Bool` — it will throw a type mismatch error, causing the entire parent struct to fail to decode.

**Fix:** Change both to `Int?` and add a computed `Bool` property:
```swift
// In CDUntappdBrewery:
public var isActive: Int?
public var isActiveFlag: Bool { isActive == 1 }

// In CDUntappdVenue:
public var isVerified: Int?
public var isVerifiedFlag: Bool { isVerified == 1 }
```
Or use a custom `init(from:)` that manually handles both types.

### Schema Issue #3 — Typos in public property names

| File | Current | Correct |
|------|---------|---------|
| `CDUntappdUser.swift:44` | `userAvatatHd` | `userAvatarHd` |
| `CDUntappdVenue.swift:54` | `foursqaureId` | `foursquareId` |
| `CDUntappdVenue.swift:55` | `foursqaureUrl` | `foursquareUrl` |

All three are `public` properties — renaming them is a breaking API change. Fix in v3.0.0 alongside the other breaking changes in Improvement 5.

### Schema Issue #4 — Wish list `created_at` vs `wish_list_added_at`

`CDUntappdWishListItem.createdAt` maps to `"created_at"` but the Untappd API returns the wish list timestamp as `"wish_list_added_at"`. Change the `CodingKey` raw value from `"created_at"` to `"wish_list_added_at"` in `CDUntappdWishListItem.swift`.
