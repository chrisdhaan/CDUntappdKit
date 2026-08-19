# Change Log
All notable changes to this project will be documented in this file.
`CDUntappdKit` adheres to [Semantic Versioning](https://semver.org/).

## Table of Contents

- [4.0.0](#400)
- [3.3.0](#330)
- [3.2.1](#321)
- [3.2.0](#320)
- [3.1.0](#310)
- [3.0.0](#300)
- [2.0.0](#200)
- [1.1.0](#110)
- [1.0.0](#100)

---

## [4.0.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/4.0.0)

Released on 2026-08-19.

Removes three long-deprecated public API members.

### Removed

- `CDUntappdAPIClient.cancelAllPendingAPIRequests()` — deprecated since 2.0.0; use `Task.cancel()` on the task wrapping the async API call instead.
- `CDUntappdOAuthClient.authorize(withCode:completion:)` — deprecated since 3.0.0; use `authorize(withCode:)` (`async throws`) instead.
- `CDUntappdKitError.httpError(statusCode:data:)` — deprecated since 3.3.0; use `.httpErrorWithHeaders(statusCode:data:headers:)` instead.

---

## [3.3.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/3.3.0)

Released on 2026-08-19.

Adds a public testing product for mocking network calls, and surfaces HTTP response headers on failed requests.

### Added

- `CDUntappdKitTesting` SPM product — exposes `CDUntappdMockURLProtocol`, a `URLProtocol`-based request mock previously internal to this package's own test suite, so downstream consumers can mock CDUntappdKit-backed network calls in their own test suites without reimplementing a `URLProtocol` stub. `CDUntappdAPIClient`'s `urlSession:`-accepting initializer is now public to pair with it.
- `CDUntappdKitError.httpErrorWithHeaders(statusCode:data:headers:)` — carries the failed response's HTTP headers (e.g. `Retry-After`, rate-limit headers) alongside the status code and body.

### Deprecated

- `CDUntappdKitError.httpError(statusCode:data:)` — replaced by `httpErrorWithHeaders(statusCode:data:headers:)`. CDUntappdKit no longer throws this case; it remains declared only for source compatibility with existing exhaustive pattern matches.

---

## [3.2.1](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/3.2.1)

Released on 2026-08-18.

iOS Example modernization and documentation cleanup.

### Removed

- The documented Git Submodule install instructions from `README.md`/`Documentation/Usage.md` — this path never delivered the `PrivacyInfo.xcprivacy` privacy manifest, and Swift Package Manager is now the only documented install method. `CDUntappdKit.xcodeproj` can still be embedded manually via a git submodule; it's just no longer a recommended, documented path.

### iOS Example App

- Modernized to the `UIScene`/`SceneDelegate` app lifecycle

---

## [3.2.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/3.2.0)

Released on 2026-08-18.

"Client Configurability" — adds opt-in retry, middleware/interceptor, response-caching, and decoder-configuration surfaces to `CDUntappdAPIClient` and `CDUntappdOAuthClient`, plus throwing (rather than crashing) auth errors on write/action endpoints.

### Added

- `CDUntappdRetryConfiguration` — opt-in automatic retry with exponential backoff for `CDUntappdAPIClient` and `CDUntappdOAuthClient` requests, configurable via a new `retryConfiguration` init parameter on both (defaults to `.disabled`, so existing behavior is unchanged unless a caller opts in). Retries transient network failures and retryable HTTP status codes (default: `408, 429, 500, 502, 503, 504`) on idempotent HTTP methods only — POST requests (e.g. `addCheckin`, `toast`, `addComment`) are never auto-retried, so those can never be silently submitted twice. Note some write/action endpoints (`addFriend`, `removeFriend`, `acceptFriend`, `rejectFriend`, `addToWishList`, `removeFromWishList`) are `GET` requests and so are still retried like any other idempotent call.
- `CDUntappdEventMonitor` and `CDUntappdRequestAdapter` — opt-in hooks for observing network events and mutating outgoing requests, configurable via new `eventMonitors`/`requestAdapters` init parameters on `CDUntappdAPIClient` and `CDUntappdOAuthClient` (both default to `[]`, so existing behavior is unchanged unless a caller opts in). `CDUntappdEventMonitor` observes request start, terminal completion (success or non-retried failure), and retry attempts. `CDUntappdRequestAdapter` mutates a request once per logical call, before the first attempt — not once per retry — and any framework-set header an adapter strips is restored from the original request.
- `CDUntappdCacheConfiguration` and `CDUntappdAPIClient.clearCache()` — an opt-in, in-memory response cache for `GET` requests on `CDUntappdAPIClient` and `CDUntappdOAuthClient`, configurable via a new `cacheConfiguration` init parameter on both (defaults to `.disabled`, so existing behavior is unchanged unless a caller opts in). Entries expire after a configurable TTL (default 5 minutes) and only ever get written after a successful decode, so a corrupted or transient response can never poison the cache; if a cached entry later fails to decode (e.g. its shape no longer matches after an app update), it's evicted and the next call for that key hits the network fresh. Note this applies uniformly to every `GET` request, including the write/action endpoints noted above that happen to be `GET` — a repeated identical call within the TTL returns the cached result instead of re-hitting the network.
- `CDUntappdDecoderConfiguration` — customizes the `JSONDecoder.KeyDecodingStrategy`/`DateDecodingStrategy` used to decode every response, configurable via a new `decoderConfiguration` init parameter on `CDUntappdAPIClient` and `CDUntappdOAuthClient` (defaults to `.default`, matching a plain `JSONDecoder()`, so existing behavior is unchanged unless a caller opts in). Every model's explicit snake_case `CodingKeys` already handle Untappd's real response shapes without this — it exists to close the configuration-surface gap with retry/monitor/adapter/cache, not because any current model needs it.

### Updated

- The 11 write/action-endpoint methods on `CDUntappdAPIClient` (`addCheckin`, `toast`, `addComment`, `removeComment`, `fetchPendingFriends`, `addFriend`, `removeFriend`, `acceptFriend`, `rejectFriend`, `addToWishList`, `removeFromWishList`) now throw `CDUntappdKitError.invalidCredentials(_:)` when called without an active access token, instead of crashing via `precondition`. An expired or missing token between an `isAuthenticated()` check and a write call is a routine runtime condition, not a programmer error, so it's now catchable. Read-only fetch methods are unchanged and still precondition on authentication.

---

## [3.1.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/3.1.0)

Released on 2026-08-17.

"Expanded Endpoint Coverage" — implements every `CDUntappdRouter` case that previously had no corresponding `CDUntappdAPIClient` method. Every documented Untappd API endpoint is now backed by a public async/await API method.

### Added

- `CDUntappdAPIClient.fetchUserBadges(forUsername:offset:)` — user's earned badges
- `CDUntappdAPIClient.fetchUserBeers(forUsername:offset:limit:sort:)` — beers the user has checked in
- `CDUntappdAPIClient.fetchBeerInfo(forBid:compact:)` — beer info by ID
- `CDUntappdAPIClient.fetchBreweryInfo(forBreweryId:compact:)` — brewery info by ID
- `CDUntappdAPIClient.fetchVenueInfo(forVenueId:compact:)` — venue info by ID
- `CDUntappdAPIClient.searchBeers(query:offset:limit:sort:)` — beer search
- `CDUntappdAPIClient.searchBreweries(query:offset:)` — brewery search
- `CDUntappdUserBeersSortType` / `CDUntappdBeerSearchSortType` — endpoint-specific sort options for the two new endpoints that take a `sort` parameter (each accepts a different subset of values than `CDUntappdUserWishListSortType`, per the Untappd API docs)
- `CDUntappdAPIClient.fetchActivityFeed(maxId:minId:limit:)` — authenticated user's friend check-in feed
- `CDUntappdAPIClient.fetchUserActivityFeed(forUsername:maxId:minId:limit:)` — a specific user's check-in history
- `CDUntappdAPIClient.fetchBeerActivityFeed(forBid:maxId:minId:limit:)` — recent check-ins for a beer
- `CDUntappdAPIClient.fetchBreweryActivityFeed(forBreweryId:maxId:minId:limit:)` — recent check-ins for a brewery
- `CDUntappdAPIClient.fetchVenueActivityFeed(forVenueId:maxId:minId:limit:)` — recent check-ins at a venue
- `CDUntappdAPIClient.fetchNotifications(offset:limit:)` — authenticated user's toast and comment notifications
- `CDUntappdAPIClient.lookupVenue(byFoursquareId:)` — look up an Untappd venue by its Foursquare v2 venue ID
- `CDUntappdActivityFeedResponse` — shared response model for the five check-in activity feed endpoints above
- `CDUntappdNotification` / `CDUntappdNotificationsResponse` — notifications response models
- `CDUntappdFoursquareLookupResponse` — Foursquare lookup response model, wraps the existing `CDUntappdVenue`
- `CDUntappdAPIClient.addCheckin(bid:gmtOffset:timezone:foursquareId:latitude:longitude:shout:rating:facebook:twitter:foursquare:)` — post a new beer check-in
- `CDUntappdAPIClient.toast(checkinId:)` — toggle a toast on a check-in
- `CDUntappdAPIClient.addComment(toCheckinId:comment:)` — add a comment to a check-in
- `CDUntappdAPIClient.removeComment(commentId:)` — remove a comment from a check-in
- `CDUntappdAPIClient.fetchPendingFriends(offset:limit:)` — the authenticated user's pending friend requests
- `CDUntappdAPIClient.addFriend(targetId:)` / `.removeFriend(targetId:)` / `.acceptFriend(targetId:)` / `.rejectFriend(targetId:)` — friend request actions
- `CDUntappdAPIClient.addToWishList(bid:)` / `.removeFromWishList(bid:)` — wish list actions
- `CDUntappdCheckinResponse`, `CDUntappdToastResponse`, `CDUntappdComment` + `CDUntappdAddCommentResponse`, `CDUntappdPendingFriendsResponse`, `CDUntappdActionResultResponse` (shared by 6 of the 11 action endpoints) — new response models
- `CDUntappdParameterEncoding.httpBodyRequest(for:parameters:)` — POST/httpBody request encoding, the client's first mutating-request support (used by 4 of the 11 new endpoints; the other 7 are `GET`, same as every prior endpoint)
- Every `CDUntappdRouter` case now has a corresponding public `CDUntappdAPIClient` method — all 28 documented Untappd API endpoints are implemented
- `CDUntappdCheckin.comments` (`[CDUntappdComment]?`) — decodes a check-in's comment thread, following the same `{"items": [...]}`-wrapped shape already used by this type's `badges`/`media` fields. This exact shape has not been captured from a live response (unlike `badges`/`media`); treat as a confident inference pending live verification. `toasts` remains unimplemented — no `CDUntappdToast` model exists yet.
- 33 new tests for the info/search and feed endpoints (model decode coverage for all 10 new response types plus router path/method coverage for the 7 newest cases), plus 44 more for the action endpoints and their follow-up fixes — 222 tests across 42 suites

### Fixed

- `CDUntappdBeer.isInProduction` now decodes leniently from either a JSON boolean or a `1`/`0` integer, matching the existing behavior of `CDUntappdBrewery.isActive`/`CDUntappdVenue.isVerified` — the real Untappd API returns this field as an integer, which previously would have thrown a decoding error

### iOS Example App

- OAuth `clientId`/`clientSecret` now supplied via a gitignored `Secrets.xcconfig` (with a committed `Secrets.xcconfig.example` template), loaded via `Info.plist` and read at runtime through `Bundle.main.infoDictionary`
- Fixed three pre-existing build breaks in the `iOS Example` target (not part of CI, so previously unnoticed): a stale deployment target below `CDUntappdKit`'s iOS 15.0 floor, a nonisolated call into `CDUntappdAPIClient`'s `@MainActor` initializer, and a typo in `ViewController.swift` that had never compiled
- Added a short setup section to `README.md`

---

## [3.0.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/3.0.0)

Released on 2026-08-15.

"Networking & Concurrency Modernization" — replaces Alamofire with native `URLSession`, migrates OAuth token storage to the Keychain, and completes a full Swift 6 concurrency audit.

### Added

- Internal `CDUntappdURLSession` actor: a native `URLSession`-backed request/decode pipeline
- Internal `CDUntappdParameterEncoding` query encoder, replicating Alamofire's prior wire behavior (deterministic key-sorted, numeric-bool-encoded, percent-encoded query strings)
- Test-target-only `CDUntappdMockURLProtocol` for network-mocked test coverage of the new pipeline
- End-to-end test coverage for `fetchUserWishList`/`fetchUserFriends` against `CDUntappdMockURLProtocol` (previously only `fetchUserInfo` had it) — 145 tests across 26 suites
- Internal `CDUntappdKeychain` wrapper around Keychain Services for storing the OAuth access token

### Updated

- Deployment targets: iOS 15.0+, macOS 12.0+, tvOS 15.0+, watchOS 8.0+ (visionOS unchanged at 1.0+) — required for native `URLSession` async/await support with no back-deployment shim
- `CDUntappdKitError`: restructured to `.invalidRequest(underlying:)`, `.networkFailure(underlying:)`, `.httpError(statusCode:data:)`, `.decodingFailed(underlying:)` (now carries a labeled `underlying:` parameter), `.apiError(String)` (unchanged); added `.invalidCredentials(String)` for OAuth preflight validation failures
- `CDUntappdRouter` / `CDUntappdOAuthRouter`: no longer conform to `Alamofire.URLRequestConvertible`; `asURLRequest()` shape unchanged
- `CDUntappdOAuthClient.authorize(withCode:)`: now `async throws -> Void`, backed by the shared `CDUntappdURLSession` pipeline; this closes the last callback-based API in the library. The prior `authorize(withCode:completion:)` signature is kept as a `@available(*, deprecated, renamed:)` shim for one release cycle
- `CDUntappdOAuthViewController`: drives the new async `authorize(withCode:)` via `Task` instead of the completion-handler form
- OAuth access token now stored in the Keychain instead of `UserDefaults`; `CDUntappdOAuthClient`/`CDUntappdAPIClient` public API is unchanged
- The library now builds under full Swift 6 language mode (`Package.swift`'s `swiftLanguageModes` and the Xcode project's `SWIFT_VERSION` both moved from 5 to 6), with `@unchecked Sendable` removed from `CDUntappdAPIClient` and `CDUntappdOAuthClient` in favor of real, compiler-verified `Sendable` conformance (`CDUntappdOAuthClient` is now `final`, a requirement for a non-`@MainActor` class to conform to `Sendable` without an escape hatch)
- `CDUntappdAPIClient`/`CDUntappdOAuthClient` initializer parameters (`clientId`, `clientSecret`, `redirectUrl`) changed from implicitly-unwrapped `String!` to plain `String` — passing `nil` no longer compiles
- Input validation (`clientId`/`clientSecret`/`redirectUrl`/username-or-authentication checks) switched from `assert` to `precondition`, so it's enforced in Release builds too, not just Debug
- `cancelAllPendingAPIRequests()` is now `async` and suspends until in-flight requests have actually finished cancelling, not just until cancellation has been requested

### Removed

- Alamofire dependency (removed from `Package.swift` and `CDUntappdKit.xcodeproj`)
- `CDUntappdKitError.sessionUnavailable` case (dead code, never thrown)
- `NSObject` inheritance from `CDUntappdAPIClient` (no Objective-C runtime features were used)

---

## [2.0.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/2.0.0)

Released on 2026-08-14.

### Added

- Async/await API overloads for all fetch methods
- Swift 6 concurrency safety: `@MainActor` on `CDUntappdAPIClient` and `CDUntappdOAuthViewController`, `Sendable` on all model types
- Comprehensive unit test suite using Swift Testing framework (107 tests across 21 suites)
- `CDUntappdKitError` enum for typed error propagation (replaces nil-on-failure completion handler pattern)
- Privacy manifest (`PrivacyInfo.xcprivacy`) declaring `UserDefaults` API usage
- API documentation generated by DocC, hosted at https://chrisdhaan.github.io/CDUntappdKit/documentation/cduntappdkit/
- SwiftLint enforcement in CI pipeline
- SwiftFormat enforcement in CI pipeline
- CodeQL security scanning in CI pipeline
- Dynamic library product (`CDUntappdKitDynamic`) in Swift Package Manager manifest
- visionOS 1.0+ platform support

### Updated

- Deployment targets: iOS 12.0+, macOS 10.13+, tvOS 12.0+, watchOS 4.0+
- Swift Package Manager: `swift-tools-version` 5.6 → 6.0, `swiftLanguageModes: [.v5]`, removed versioned Package manifests
- Alamofire dependency: pinned 5.6.1 → upToNextMajor 5.9.0
- CI/CD: macOS-26/macos-15 runners, Xcode 26.1.1–26.4.1 + 16.4, xcbeautify output formatting, GitHub Actions v4, SwiftFormat + DocC build jobs
- Error logging: `print()` replaced with `os.log` structured logging
- Copyright year: 2022 → 2026

### Removed

- Completion handler API (replaced by async/await — breaking change)
- Carthage support (use Swift Package Manager)
- CocoaPods support (CocoaPods trunk is deprecating in 2026; use Swift Package Manager)
- Versioned Package manifests (Package@swift-5.3.swift through Package@swift-5.5.swift)

---

## [1.1.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/1.1.0)

Released on 2022-06-30.

### Added

- Swift 5.4, 5.5, and 5.6
- `validate` to API methods

### Updated

- Swift Package Manager minimum Swift version to 5.3
- `responseObject` model transformation to `responseDecodable`
- Models to use `Decodable`/`Encodable`, `struct` over `class`, `let` over `var`
- Alamofire dependency version
- CI test device, platform, Xcode, and SDK versions

### Removed

- ObjectMapper dependency
- Travis CI configuration

---

## [1.0.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/1.0.0)

Released on 2017-12-04.

### Added

- Authentication
- User Info endpoint
- User Wish List endpoint
- User Friends endpoint
- Untappd brand colors
- iOS, macOS, tvOS, watchOS platform support
