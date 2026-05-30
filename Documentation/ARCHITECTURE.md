# CDUntappdKit Architecture

## System Overview

CDUntappdKit is a thin Swift wrapper around the Untappd REST API. It handles:
1. OAuth 2.0 authentication via WKWebView (iOS)
2. Authenticated API requests using Alamofire
3. JSON decoding into strongly-typed Swift model structs

## Key Components

### CDUntappdAPIClient
The primary public interface. Marked `@MainActor` to ensure all state mutations happen on the main thread.

Responsibilities:
- Initializes and holds the Alamofire `Session` configured with the OAuth interceptor
- Exposes `async throws` methods for each implemented API endpoint
- Delegates OAuth flow to `CDUntappdOAuthClient`

### CDUntappdOAuthClient
Manages the OAuth credential lifecycle.

Responsibilities:
- Constructs the Untappd authorization URL
- Parses the OAuth callback to extract the access token
- Stores and retrieves the token from `UserDefaults`

**Note:** UserDefaults is used for simplicity. A production-grade implementation should use the Keychain.

### CDUntappdRouter
An Alamofire `URLRequestConvertible` enum. Each case represents an API endpoint and knows how to construct its `URLRequest`.

### CDUntappdOAuthRouter
Same pattern as `CDUntappdRouter`, but for the OAuth authorization and token exchange endpoints.

### CDUntappdOAuthViewController (iOS only)
A `UIViewController` wrapping `WKWebView` that presents the Untappd OAuth login page and intercepts the redirect callback.

## Request Lifecycle

```
Caller
  │
  ▼
CDUntappdAPIClient.fetchUserInfo(...)  ← @MainActor
  │
  ├── builds CDUntappdRouter.userInfo parameters
  │
  ▼
Alamofire Session.request(CDUntappdRouter)
  │
  └── validates status code
  └── serializingDecodable(CDUntappdUserInfoResponse.self)
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
