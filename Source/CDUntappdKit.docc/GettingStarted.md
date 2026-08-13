# Getting Started

Authenticate and make your first Untappd API request in three steps.

## Initialize the client

```swift
let client = CDUntappdAPIClient(
    clientId: "YOUR_CLIENT_ID",
    clientSecret: "YOUR_CLIENT_SECRET",
    redirectUrl: "yourapp://oauth/callback"
)
```

## Authenticate (iOS / visionOS)

```swift
client.authenticate()
```

This presents a `WKWebView`-based OAuth flow via `CDUntappdOAuthViewController`.

## Fetch user info

```swift
Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: "DehaanSolo",
                                                      compact: false)
        print(response.user?.username ?? "")
    } catch {
        print(error)
    }
}
```
