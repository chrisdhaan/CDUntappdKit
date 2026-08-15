# CDUntappdKit Architecture

## System Overview

CDUntappdKit is a thin Swift wrapper around the Untappd REST API. It handles:
1. OAuth 2.0 authentication via WKWebView (iOS)
2. Authenticated API requests using a native `URLSession`-backed pipeline
3. JSON decoding into strongly-typed Swift model structs

## Key Components

### CDUntappdAPIClient
The primary public interface. Marked `@MainActor` to ensure all state mutations happen on the main thread.

Responsibilities:
- Initializes and holds a `CDUntappdURLSession` actor for performing requests
- Exposes `async throws` methods for each implemented API endpoint
- Delegates OAuth flow to `CDUntappdOAuthClient`

### CDUntappdOAuthClient
Manages the OAuth credential lifecycle.

Responsibilities:
- Constructs the Untappd authorization URL
- Parses the OAuth callback to extract the access token
- Stores and retrieves the token from the Keychain via the internal `CDUntappdKeychain` wrapper

### CDUntappdRouter
An enum where each case represents an API endpoint and knows how to construct its `URLRequest` via `asURLRequest()`.

### CDUntappdOAuthRouter
Same pattern as `CDUntappdRouter`, but for the OAuth authorization and token exchange endpoints.

### CDUntappdURLSession
An internal actor wrapping `URLSession`. Performs a built `URLRequest`, validates the HTTP status code, and decodes the response body, mapping every failure mode to a `CDUntappdKitError` case.

### CDUntappdOAuthViewController (iOS and visionOS)
A `UIViewController` wrapping `WKWebView` that presents the Untappd OAuth login page and intercepts the redirect callback. Available on iOS and visionOS via `#if os(iOS) || os(visionOS)` platform guard.

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

## Model Hierarchy

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
              └── CDUntappdBeer
                    └── CDUntappdBrewery

CDUntappdUserFriendsResponse
  └── [CDUntappdFriend]
```

All model types are `struct`, `Decodable`, and `Sendable`.
