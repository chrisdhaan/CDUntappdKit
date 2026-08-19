<p align="center">
    <a href="https://github.com/chrisdhaan/CDUntappdKit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDUntappdKit/master/Documentation/cduntappdkit.png" alt="CDUntappdKit" width="850" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/chrisdhaan/CDUntappdKit/actions/workflows/ci.yml">
        <img src="https://github.com/chrisdhaan/CDUntappdKit/actions/workflows/ci.yml/badge.svg" alt="CI Status">
    </a>
    <a href="https://github.com/chrisdhaan/CDUntappdKit/releases">
        <img src="https://img.shields.io/github/release/chrisdhaan/CDUntappdKit.svg" alt="GitHub Release">
    </a>
    <a href="https://www.swift.org">
        <img src="https://img.shields.io/badge/Swift-6.0+-orange?style=flat" alt="Swift Versions">
    </a>
    <a href="https://www.swift.org/package-manager">
        <img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat" alt="Swift Package Manager Compatible">
    </a>
    <a href="https://github.com/chrisdhaan/CDUntappdKit/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/chrisdhaan/CDUntappdKit.svg" alt="License">
    </a>
</p>

An extensive Swift wrapper for the Untappd API with async/await support and comprehensive unit tests.

## Features

- **Authentication** — OAuth 2.0 via `CDUntappdOAuthViewController`
- **API Endpoints** — User Info, Wish List, Friends, Badges, Beers, Beer Info, Brewery Info, Venue Info, Beer Search, Brewery Search, Activity Feed, User/Beer/Brewery/Venue Activity Feed, Notifications, Foursquare Lookup
- **Async/Await API** — Modern Swift concurrency support
- **Swift 6 Safety** — `@MainActor` and `Sendable` annotations
- **Comprehensive Tests** — 178 unit tests covering all functionality
- **Brand Assets** — Untappd brown and yellow colors
- **Multi-Platform** — iOS, macOS, tvOS, watchOS, visionOS
- **Documentation** — DocC API reference with interactive search

## Requirements

| Platform | Minimum |
|----------|---------|
| iOS | 15.0+ |
| macOS | 12.0+ |
| tvOS | 15.0+ |
| watchOS | 8.0+ |
| visionOS | 1.0+ |
| Swift | 6.0+ |

## Installation

### Swift Package Manager

Add CDUntappdKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/chrisdhaan/CDUntappdKit.git", .upToNextMajor(from: "3.2.1"))
]
```

## iOS Example App

The `iOS Example` app reads its Untappd OAuth `clientId`/`clientSecret` from `iOS Example/Secrets.xcconfig` (gitignored). Before building it:

```bash
cp "iOS Example/Secrets.xcconfig.example" "iOS Example/Secrets.xcconfig"
```

Then edit `Secrets.xcconfig` with your own credentials from the [Untappd API](https://untappd.com/api/register).

## Quick Start

### Initialize the client

```swift
let client = CDUntappdAPIClient(
    clientId: "YOUR_CLIENT_ID",
    clientSecret: "YOUR_CLIENT_SECRET",
    redirectUrl: "yourapp://oauth/callback"
)
```

### Fetch user information

```swift
Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: "DehaanSolo", compact: false)
        if let user = response.user {
            print(user.username ?? "")
        }
    } catch {
        print(error)
    }
}
```

## Documentation

For complete usage examples, authentication flow details, error handling, and advanced topics, see [Documentation/Usage.md](Documentation/Usage.md).

Upgrading from 1.x? See the [2.0 Migration Guide](Documentation/CDUntappdKit%202.0%20Migration%20Guide.md).

API reference is available at https://chrisdhaan.github.io/CDUntappdKit/documentation/cduntappdkit/

## Author

Christopher de Haan, contact@christopherdehaan.me

## License

MIT

---

For more information, visit the [Untappd Developers](https://untappd.com/api/docs) portal.
