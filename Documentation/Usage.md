# CDUntappdKit Usage Guide

Complete guide to using CDUntappdKit for interacting with the Untappd API.

## Table of Contents

- [Installation](#installation)
- [Initialization](#initialization)
- [Authentication](#authentication)
- [Fetch Methods](#fetch-methods)
- [Error Handling](#error-handling)
- [Sort Options](#sort-options)
- [Brand Assets](#brand-assets)
- [Platform Notes](#platform-notes)
- [Advanced: Cancellation](#advanced-cancellation)
- [Unimplemented Endpoints](#unimplemented-endpoints)

---

## Installation

### Swift Package Manager

Add CDUntappdKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/chrisdhaan/CDUntappdKit.git", .upToNextMajor(from: "3.1.0"))
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [.product(name: "CDUntappdKit", package: "CDUntappdKit")]
    )
]
```

Then in your Xcode project, go to **File** > **Add Packages**, paste the URL, and select version 3.1.0 or later.

### Git Submodule

Clone the repository as a submodule:

```bash
git submodule add https://github.com/chrisdhaan/CDUntappdKit.git
```

Then drag `CDUntappdKit.xcodeproj` into your Xcode project and add `CDUntappdKit.framework` to your target's **Embedded Binaries**.

---

## Initialization

Create an instance of `CDUntappdAPIClient` with your Untappd application credentials:

```swift
import CDUntappdKit

let client = CDUntappdAPIClient(
    clientId: "YOUR_CLIENT_ID",
    clientSecret: "YOUR_CLIENT_SECRET",
    redirectUrl: "yourapp://oauth/callback"
)
```

Store this client as a property of your app delegate, view controller, or state manager so it persists for the lifetime of the application.

---

## Authentication

CDUntappdKit uses OAuth 2.0 to authenticate with the Untappd API.

### Present the OAuth Flow (iOS / visionOS)

On iOS and visionOS, call `authenticate()` to present a web view with the OAuth login flow:

```swift
client.authenticate()
```

This displays a `CDUntappdOAuthViewController` with an embedded `WKWebView`. The user logs in, grants permissions, and is redirected back to your app. The access token is automatically saved to the Keychain.

### Check Authorization Status

Check if the user is currently authorized:

```swift
if client.isAuthorized() {
    // User has an access token
} else {
    // User is not authorized; call authenticate()
}
```

### Fetch Current User Info (Without Username)

Once authorized, you can fetch the authenticated user's info by passing `nil` as the username:

```swift
Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: nil, compact: false)
        if let user = response.user {
            print("Logged in as: \(user.username ?? "")")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Unauthenticate

To sign out the user, clear the stored token:

```swift
client.unauthenticate()
```

This removes the access token from the Keychain. Subsequent API calls will use client credentials instead.

---

## Fetch Methods

All fetch methods use Swift's `async/await` syntax and are `@MainActor` restricted (safe to call from the main thread only). Wrap calls in `Task { }` from a non-async context.

### Fetch User Info

Retrieve information about a specific user or the authenticated user:

```swift
Task {
    do {
        let response = try await client.fetchUserInfo(
            forUsername: "DehaanSolo",
            compact: false
        )
        
        if let user = response.user {
            print("Username: \(user.username ?? "")")
            print("First Name: \(user.firstName ?? "")")
            print("Last Name: \(user.lastName ?? "")")
            print("Bio: \(user.bio ?? "")")
            print("Stats: \(user.stats?.totalCheckins ?? 0) check-ins")
        }
    } catch {
        print("Failed to fetch user info: \(error)")
    }
}
```

**Parameters:**
- `forUsername`: The username to fetch (or `nil` for the authenticated user). Requires authorization if `nil`.
- `compact`: Pass `true` to omit extended fields like checkins and media. Defaults to `false`.

### Fetch User Wish List

Get the list of beers a user wants to drink:

```swift
Task {
    do {
        let response = try await client.fetchUserWishList(
            forUsername: "DehaanSolo",
            offset: 0,
            limit: 25,
            sort: .highestABV
        )
        
        if let items = response.wishList?.items {
            for item in items {
                print("Beer: \(item.beer?.name ?? "")")
                print("ABV: \(item.beer?.abv ?? 0)%")
            }
        }
    } catch {
        print("Failed to fetch wish list: \(error)")
    }
}
```

**Parameters:**
- `forUsername`: The username (or `nil` for the authenticated user).
- `offset`: Zero-based offset for pagination. Pass `nil` to start from 0.
- `limit`: Maximum results to return (max 50). Pass `nil` for default (25).
- `sort`: How to sort results. Pass `nil` for date order.

### Fetch User Friends

Get the list of friends a user has on Untappd:

```swift
Task {
    do {
        let response = try await client.fetchUserFriends(
            forUsername: "DehaanSolo",
            offset: 0,
            limit: 25
        )
        
        if let friends = response.friends {
            for friend in friends {
                print("Friend: \(friend.user?.username ?? "")")
            }
        }
    } catch {
        print("Failed to fetch friends: \(error)")
    }
}
```

**Parameters:**
- `forUsername`: The username (or `nil` for the authenticated user).
- `offset`: Zero-based offset for pagination. Pass `nil` to start from 0.
- `limit`: Maximum results to return (max 25). Pass `nil` for default (25).

---

## Error Handling

All fetch methods throw `CDUntappdKitError` on failure. Always wrap async calls in `do-catch`:

```swift
Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: "DehaanSolo", compact: false)
        // Handle success
    } catch let error as CDUntappdKitError {
        switch error {
        case .invalidRequest(let underlyingError):
            print("Request could not be constructed: \(underlyingError)")
        case .networkFailure(let underlyingError):
            print("Network request failed: \(underlyingError)")
        case .httpError(let statusCode, let data):
            print("HTTP error \(statusCode)")
        case .apiError(let message):
            print("API error: \(message)")
        case .decodingFailed(let underlyingError):
            print("Response decode failed: \(underlyingError)")
        }
    } catch {
        print("Unexpected error: \(error)")
    }
}
```

### Error Cases

- **`invalidRequest(Error)`** — The request could not be constructed (e.g. an invalid URL from route parameters).
- **`networkFailure(Error)`** — A transport-level failure occurred (no connection, timed out, etc).
- **`httpError(statusCode: Int, data: Data)`** — The API returned a non-2xx HTTP status code.
- **`apiError(String)`** — The Untappd API returned an error response (invalid username, rate limit, etc.).
- **`decodingFailed(Error)`** — The response body couldn't be decoded into the expected model.

---

## Sort Options

When fetching the wish list, use `CDUntappdUserWishListSortType` to sort results:

```swift
CDUntappdUserWishListSortType.date         // Sort by date added (default)
CDUntappdUserWishListSortType.checkin      // Sort by number of check-ins
CDUntappdUserWishListSortType.highestABV   // Sort by highest ABV
CDUntappdUserWishListSortType.lowestABV    // Sort by lowest ABV
CDUntappdUserWishListSortType.highestRated // Sort by highest global rating
CDUntappdUserWishListSortType.lowestRated  // Sort by lowest global rating
```

Example:

```swift
let response = try await client.fetchUserWishList(
    forUsername: "DehaanSolo",
    offset: 0,
    limit: 25,
    sort: .highestRated
)
```

---

## Brand Assets

Use Untappd's official brand colors in your UI:

```swift
// Untappd brown (RGB 202, 102, 26)
let brownColor = UIColor.untappdBrown()

// Untappd yellow (RGB 253, 191, 45)
let yellowColor = UIColor.untappdYellow()

// Apply to views
button.backgroundColor = UIColor.untappdBrown()
label.textColor = UIColor.untappdYellow()
```

On macOS, use `NSColor` instead of `UIColor`:

```swift
let brownColor = NSColor.untappdBrown()
let yellowColor = NSColor.untappdYellow()
```

---

## Platform Notes

### watchOS Limitations

On watchOS, the OAuth authentication flow is not available because `WKWebView` is not supported.

**Use Client Credentials Only** — Call API methods without calling `authenticate()`. Requests will use your `clientId` and `clientSecret` instead of an access token. This limits you to public data.

The access token is stored in the Keychain, which is not automatically shared between an iOS app and its paired watchOS app — that requires a Keychain access group shared via the `com.apple.security.application-groups` entitlement, which this library does not currently configure. Authenticating on iOS will not make `isAuthorized()` return `true` on watchOS.

### macOS, tvOS, iOS, visionOS

Full OAuth support is available on all other platforms via `CDUntappdOAuthViewController`.

---

## Advanced: Cancellation

To cancel in-flight API requests, cancel the `Task` wrapping the async call:

```swift
var currentTask: Task<Void, Never>?

// Start a request
currentTask = Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: "DehaanSolo", compact: false)
        // Handle response
    } catch is CancellationError {
        print("Request was cancelled")
    } catch {
        print("Request failed: \(error)")
    }
}

// Later, cancel it
currentTask?.cancel()
```

When a task is cancelled while awaiting a network request, the underlying `URLSessionTask` is cancelled. The async call throws `CancellationError`.

**Note:** The deprecated method `cancelAllPendingAPIRequests()` is no longer available. Use `Task.cancel()` instead for fine-grained control.

---

## Unimplemented Endpoints

The following Untappd API endpoints are not yet implemented in CDUntappdKit. Contributions are welcome!

### Activity & Notifications
- Activity Feed (`/activity/feed`)
- User Activity Feed (`/user/activity/{username}`)
- The Pub / Local Activity (`/thepub`)
- Venue Activity Feed (`/venue/{id}/activity`)
- Beer Activity Feed (`/beer/{id}/activity`)
- Brewery Activity Feed (`/brewery/{id}/activity`)
- Notifications (`/user/notifications`)

### User Operations
- User Badges (`/user/badges/{username}`)
- User Beers (`/user/beers/{username}`)
- Pending Friends (`/user/friends/pending`)
- Add Friend (`/user/friends/add/{username}`)
- Remove Friend (`/user/friends/remove/{username}`)
- Accept Friend (`/user/friends/accept/{username}`)
- Reject Friend (`/user/friends/reject/{username}`)

### Beer & Brewery Info
- Beer Info (`/beer/{id}`)
- Brewery Info (`/brewery/{id}`)
- Beer Search (`/search/beer`)
- Brewery Search (`/search/brewery`)

### Check-in & Social
- Create Check-in (`/checkin/add`)
- Get Check-in (`/checkin/{id}`)
- Toast/Un-toast (`/checkin/{id}/toast`)
- Add Comment (`/checkin/{id}/comment`)
- Remove Comment (`/comment/{id}`)

### Wish List & User Content
- Add to Wish List (`/user/wishlist/add`)
- Remove from Wish List (`/user/wishlist/remove`)

### Venue & Location
- Venue Info (`/venue/{id}`)
- Foursquare Lookup (`/venue/foursquare/lookup`)

### How to Contribute

To implement a new endpoint:

1. Add a case to the `CDUntappdRouter` enum in `Source/CDUntappdRouter.swift`
2. Create the response model in `Source/CDUntappd*.swift`
3. Add a public `fetch*` method to `CDUntappdAPIClient` using `async throws`
4. Add unit tests in `Tests/CDUntappdKitTests/`
5. Submit a pull request

See `ARCHITECTURE.md` for the complete design overview.
