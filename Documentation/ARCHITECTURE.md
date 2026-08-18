# CDUntappdKit Architecture

## System Overview

CDUntappdKit is a thin Swift wrapper around the Untappd REST API. It handles:
1. OAuth 2.0 authentication via WKWebView (iOS, visionOS)
2. Authenticated API requests using a native `URLSession`-backed pipeline
3. JSON decoding into strongly-typed Swift model structs

It has no third-party dependencies — `URLSession` is used directly via an internal `CDUntappdURLSession` actor.

## Key Components

### CDUntappdAPIClient
The primary public interface. Marked `@MainActor` to ensure all state mutations happen on the main thread. A plain `@MainActor` class needs no explicit `Sendable` conformance in Swift 6 — actor isolation already guarantees the safety `Sendable` exists to express — so it declares none (SwiftLint's `redundant_sendable` rule enforces this).

Responsibilities:
- Initializes and holds a `CDUntappdURLSession` actor for performing requests
- Exposes `async throws` methods for every currently-routed API endpoint
- Delegates OAuth flow to `CDUntappdOAuthClient`

### CDUntappdOAuthClient
Manages the OAuth credential lifecycle. Declared `final class CDUntappdOAuthClient: NSObject, Sendable` — `final` is required here because, unlike `CDUntappdAPIClient`, this class is not `@MainActor`-isolated, so it needs a real (not `@unchecked`) `Sendable` conformance, which the compiler only grants to non-isolated classes when they can't be subclassed.

Responsibilities:
- Constructs the Untappd authorization URL
- Parses the OAuth callback to extract the access token
- Stores and retrieves the token from the Keychain via the internal `CDUntappdKeychain` wrapper

### CDUntappdKeychain
An internal, non-public wrapper around Keychain Services (`SecItemAdd`/`SecItemCopyMatching`/`SecItemUpdate`/`SecItemDelete`) used to persist the OAuth access token. Replaced `UserDefaults` storage in v3.0.0 — `UserDefaults` is unencrypted and world-readable on a rooted device, which doesn't meet the App Store Review Guidelines' (§2.3.12) expectations for credential storage.

### CDUntappdRouter
An enum where each case represents an API endpoint and knows how to construct its `URLRequest` via `asURLRequest()`. As of v3.1.0, 17 cases exist, all `GET`; every case has a corresponding public method on `CDUntappdAPIClient`.

### CDUntappdOAuthRouter
Same pattern as `CDUntappdRouter`, but for the OAuth authorization and token exchange endpoints.

### CDUntappdParameterEncoding
Builds `GET` requests with URL-encoded query parameters, replicating the wire behavior the library relied on before the v3.0.0 Alamofire removal (`Bool` values numerically encoded as `"1"`/`"0"`, keys sorted for determinism). Currently `GET`-only — there is no `POST`/HTTP-body encoding path yet; adding one is a tracked prerequisite for the write/action endpoints in [issue #28](https://github.com/chrisdhaan/CDUntappdKit/issues/28).

### CDUntappdURLSession
An internal actor wrapping `URLSession`. Performs a built `URLRequest`, validates the HTTP status code, and decodes the response body, mapping every failure mode to a `CDUntappdKitError` case. Being an actor, its internal state needs no manual locking.

`cancelAllTasks()` (invoked by the deprecated `CDUntappdAPIClient.cancelAllPendingAPIRequests()`) waits for in-flight tasks to actually finish cancelling — not just for cancellation to be requested — by polling `session.allTasks` until empty, with a ~5s best-effort bound.

### CDUntappdOAuthViewController (iOS and visionOS)
A `UIViewController` wrapping `WKWebView` that presents the Untappd OAuth login page and intercepts the redirect callback. Available on iOS and visionOS via `#if os(iOS) || os(visionOS)` platform guard — see [Platform-Specific Behavior](#platform-specific-behavior) below for why the other three platforms don't get this.

## Request Lifecycle

```
Caller
  │
  ▼
CDUntappdAPIClient.fetchUserInfo(...)  ← @MainActor
  │
  ├── builds CDUntappdRouter.userInfo parameters
  ├── router.asURLRequest()
  │
  ▼
CDUntappdURLSession.perform(_:)  ← actor
  │
  └── validates HTTP status code (throws .httpError if non-2xx)
  └── decodes CDUntappdUserInfoResponse.self (throws .decodingFailed on failure)
         │
         ▼
     CDUntappdUserInfoResponse  ←  returned to caller
```

This is deliberately simple compared to some other native-URLSession API client libraries: there is no response-caching layer in the pipeline today. That's tracked as a separate, opt-in addition for a future release (v3.2.0 — [#8](https://github.com/chrisdhaan/CDUntappdKit/issues/8) response caching), not yet built.

`CDUntappdURLSession.perform(_:)` does have opt-in retry ([#9](https://github.com/chrisdhaan/CDUntappdKit/issues/9)) and middleware/interceptor ([#10](https://github.com/chrisdhaan/CDUntappdKit/issues/10)) layers:

- Pass a `CDUntappdRetryConfiguration` to `CDUntappdAPIClient.init`/`CDUntappdOAuthClient.init` (default `.disabled`, so behavior is unchanged unless a caller opts in) to retry transient network failures and retryable HTTP status codes with exponential backoff, on idempotent HTTP methods only. `cancelAllTasks()` cancels both in-flight `URLSession` tasks and any pending retry backoff sleep.
- Pass `eventMonitors: [any CDUntappdEventMonitor]` to observe request/response lifecycle events (start, terminal completion, retry) and/or `requestAdapters: [any CDUntappdRequestAdapter]` to mutate each outgoing request (e.g. custom headers) before it's sent — both default to `[]`. The adapter chain runs once per logical call, before the first attempt, not once per retry; any framework-set header an adapter strips is restored from the original request so a careless adapter can't accidentally break auth. Both `CDUntappdAPIClient` and `CDUntappdOAuthClient` thread the same monitors/adapters into their own `CDUntappdURLSession` instance.

## Model Hierarchy

Every response envelope pairs a `CDUntappdMetadata?` (the `meta` envelope, shared across all endpoints) with the endpoint's payload. As of v3.1.0 (17 implemented endpoints):

```
CDUntappdUserInfoResponse
  └── CDUntappdUser
        ├── CDUntappdStats
        ├── CDUntappdSettings
        ├── CDUntappdContact
        └── CDUntappdMedia

CDUntappdUserWishListResponse
  └── CDUntappdWishList
        └── [CDUntappdWishListItem]
              ├── CDUntappdBeer
              └── CDUntappdBrewery

CDUntappdUserFriendsResponse
  └── [CDUntappdFriend]
        └── CDUntappdUser

CDUntappdUserBadgesResponse
  └── [CDUntappdBadge]

CDUntappdUserBeersResponse
  └── [CDUntappdBeerItem]
        ├── CDUntappdBeer
        └── CDUntappdBrewery

CDUntappdBeerInfoResponse
  └── CDUntappdBeer

CDUntappdBreweryInfoResponse
  └── CDUntappdBrewery

CDUntappdVenueInfoResponse
  └── CDUntappdVenue
        └── [CDUntappdCategory]

CDUntappdBeerSearchResponse
  └── [CDUntappdBeerItem]        ← shared with CDUntappdUserBeersResponse

CDUntappdBrewerySearchResponse
  └── [CDUntappdBrewery]         ← flat, no item wrapper

CDUntappdActivityFeedResponse   ← shared by Activity/User/Beer/Brewery/Venue Activity Feed
  └── [CDUntappdCheckin]
        ├── CDUntappdUser
        ├── CDUntappdBrewery
        ├── CDUntappdBeer
        ├── CDUntappdVenue
        ├── [CDUntappdBadge]
        └── [CDUntappdMedia]

CDUntappdNotificationsResponse
  └── [CDUntappdNotification]
        ├── CDUntappdUser
        └── CDUntappdCheckin

CDUntappdFoursquareLookupResponse
  └── CDUntappdVenue
```

All model types are `struct`, `Decodable`, and `Sendable`. Response envelopes whose JSON nests payload data more than one level below `response` (e.g. `response.badges.items`) use a custom `init(from:)` with nested `KeyedDecodingContainer`s rather than a dotted-string `CodingKey` raw value — Swift's `Codable` does not treat `"response.badges.items"` as a path, only as a literal key name, so a dotted raw value silently decodes to `nil` against the real API instead of throwing. `Documentation/API_SCHEMA.md` tracks this as [Schema Issue #1](API_SCHEMA.md#schema-issue-1--dotted-path-codingkeys) and is the canonical reference for each endpoint's real response shape.

## Enum Design

`Source/CDUntappdEnums.swift` holds the library's `String`-backed enums, each mapping directly to an Untappd API query parameter value (the enum case's `rawValue` is used as-is, no conversion logic needed):

| Enum | Used by | Notes |
|------|---------|-------|
| `CDUntappdUserWishListSortType` | `fetchUserWishList` | `checkin`, `date`, `highest_abv`, `highest_rated`, `lowest_abv`, `lowest_rated` |
| `CDUntappdUserBeersSortType` | `fetchUserBeers` | `date`, `checkin`, `highest_rated`, `lowest_rated`, `highest_rated_you`, `lowest_rated_you` |
| `CDUntappdBeerSearchSortType` | `searchBeers` | `checkin`, `name` |

The three sort enums are intentionally endpoint-specific rather than one shared type — each Untappd endpoint accepts a different subset of sort values (verified against the live API docs during v3.1.0), so a single shared enum would either offer invalid values for some endpoints or be missing valid ones for others.

## Resource Files

### CDColor

`Source/CDColor.swift` defines `CDColor` as a platform typealias (`UIColor` on iOS/tvOS/watchOS/visionOS, `NSColor` on macOS). `Source/UIColor+CDUntappdKit.swift` adds Untappd's two brand colors as class functions:

```swift
CDColor.untappdBrown()   // RGB(202, 102, 26)
CDColor.untappdYellow()  // RGB(253, 191, 45)
```

Values are hardcoded RGB literals, not an asset catalog colorset — there is no `.xcassets` in this package.

## Error Handling

All async API methods throw `CDUntappdKitError`:

| Case | Meaning |
|------|---------|
| `.invalidRequest(underlying:)` | The `URLRequest` could not be constructed (e.g. an invalid URL from route parameters) |
| `.networkFailure(underlying:)` | `URLSession` threw a transport-level error (no connectivity, timeout, etc.) |
| `.httpError(statusCode:data:)` | The server returned a non-2xx HTTP status code |
| `.decodingFailed(underlying:)` | `JSONDecoder` failed to parse the response body |
| `.apiError(String)` | The API returned a 2xx response whose body describes an application-level error (via the `meta` envelope's error fields) |
| `.invalidCredentials(String)` | A required precondition (non-empty OAuth client ID/secret, non-empty authorization code) wasn't met, or the client wasn't authenticated when calling a write/action endpoint, so no request was sent |

Errors surface directly from `async throws` — there is no `nil`-on-error pattern. Read-only fetch methods still `precondition()` (not `assert()`, as of the v3.0.0 concurrency audit) on username/authentication requirements, enforced in Release builds too, not just Debug — a missing username or auth token there is treated as a caller bug. The 11 write/action endpoints (`CDUntappdAPIClient+Actions.swift`) instead throw `.invalidCredentials(String)` on a missing auth token, since a token can expire between an app's `isAuthenticated()` check and a write call — a routine runtime condition, not a programmer error (v3.2.0).

## Thread Safety

- `CDUntappdAPIClient` is `@MainActor` — call its methods from the main thread or from a `Task`. Its internal `CDUntappdURLSession` actor is `Sendable` by construction (all actors are), so holding a reference to it across the `@MainActor` boundary is safe without extra annotation.
- `CDUntappdOAuthClient` is `final class CDUntappdOAuthClient: Sendable` — a real, compiler-verified conformance, not `@unchecked`. `NSObject` inheritance was removed from `CDUntappdAPIClient` during the v3.0.0 concurrency audit (issue #11); `CDUntappdOAuthClient` still inherited it until v3.1.0, when it was confirmed unnecessary (no `@objc`/`override`/KVO usage anywhere in the class or its call sites, including `CDUntappdOAuthViewController`) and removed.
- `CDUntappdURLSession` is a Swift `actor` — its mutable state (in-flight `URLSessionTask`s tracked for cancellation) is serialized automatically by the actor runtime.
- Create one `CDUntappdAPIClient` instance per application and hold a strong reference to it, rather than constructing one per request.

## Platform-Specific Behavior

| Platform | OAuth flow | Notes |
|----------|-----------|-------|
| iOS | ✅ `CDUntappdOAuthViewController` | |
| visionOS | ✅ `CDUntappdOAuthViewController` | `authenticate()`'s `UIApplication`-based top-view-controller lookup is shared with iOS via the same `#if os(iOS) \|\| os(visionOS)` guard; it may need a visionOS-specific window-scene approach — tracked as a known limitation, not yet hit in practice |
| macOS | 🔲 None | No `WKWebView`-based flow exists for AppKit; all non-OAuth API methods work normally given an externally-obtained access token |
| tvOS | 🔲 None | Same as macOS |
| watchOS | 🔲 None | `WKWebView` is unavailable on watchOS entirely, not just unimplemented here; all non-OAuth API methods work normally given an externally-obtained access token |

Every fetch method that accepts an optional `username:` works identically across all five platforms — only the interactive OAuth *login* flow is iOS/visionOS-only. An app on macOS/tvOS/watchOS is expected to obtain the initial access token out-of-band (e.g. a companion iOS app, or a server-side OAuth exchange) and can then use `CDUntappdAPIClient` fully.

## Testing Architecture

### Unit and model-decode tests

Tests use Swift Testing (`import Testing`, `@Suite`/`@Test`/`#expect`), not XCTest. Response-model decode tests load a JSON fixture from `Tests/CDUntappdKitTests/Fixtures/` via `Bundle.module` and assert on the decoded structure:

```swift
@Suite("CDUntappdBeerInfoResponse Tests")
struct CDUntappdBeerInfoResponseTests {
    @Test
    func decodesNestedBeerFromRealisticResponseShape() throws {
        let url = try #require(Bundle.module.url(forResource: "beer_info", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdBeerInfoResponse.self, from: data)
        #expect(response.beer != nil)
    }
}
```

Every response-model test suite also has a companion test asserting the payload decodes to `nil` (not a thrown error) when the `response` key is entirely absent from the JSON, matching how the real API shapes an empty/error result.

### End-to-end client tests

`CDUntappdMockURLProtocol` (test-target-only, `Tests/CDUntappdKitTests/Testing/`) intercepts `URLSession` traffic without a real network call, letting tests exercise `CDUntappdAPIClient`'s actual fetch methods — including their `CDUntappdRouter`/`CDUntappdURLSession` plumbing — rather than only the model layer. It supports two independent, race-free ways to attach a stub (per-`URLRequest`-instance via `URLProtocol.setProperty`, or per-`URL` via a lock-protected dictionary), since Swift Testing's `.serialized` trait only serializes a suite's own tests against each other, never against a different suite running concurrently. `CDUntappdAPIClient` has a matching internal `urlSession:` initializer for tests to inject a `CDUntappdMockURLProtocol`-configured session.

This mock layer is internal to the test target — there is no public `CDUntappdKitTesting` product exposed to consumers (considered during v3.0.0, deferred: no concrete downstream need yet).

## Documentation Generation

API documentation is generated via Swift's native DocC system:

```bash
bash scripts/generate-docs.sh
```

The script regenerates the `docs/` directory (handling Jekyll bypass via `.nojekyll`, an `index.html` redirect, and `404.html`) from the `CDUntappdKit.docc` catalog in `Source/`. Generated docs are published via GitHub Pages. All public API is documented with triple-slash `///` comments, including cross-references to other documented types via double-backtick syntax (e.g. `` ``CDUntappdKitError`` ``).
