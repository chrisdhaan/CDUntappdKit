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
        <img src="https://img.shields.io/badge/Swift-5.3+-orange?style=flat" alt="Swift Versions">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/v/CDUntappdKit.svg?style=flat" alt="CocoaPods Compatible">
    </a>
    <a href="https://www.swift.org/package-manager">
        <img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat" alt="Swift Package Manager Compatible">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/l/CDUntappdKit.svg?style=flat" alt="License">
    </a>
</p>

An extensive Swift wrapper for the Untappd API with async/await support and comprehensive unit tests.

## Features

- **Authentication** — OAuth 2.0 via `CDUntappdOAuthViewController`
- **User Endpoints** — User Info, Wish List, Friends
- **Async/Await API** — Modern Swift concurrency support
- **Swift 6 Safety** — `@MainActor` and `Sendable` annotations
- **Comprehensive Tests** — 77 unit tests covering all functionality
- **Brand Assets** — Untappd brown and yellow colors
- **Multi-Platform** — iOS, macOS, tvOS, watchOS, visionOS
- **Documentation** — DocC API reference with interactive search

## Requirements

| Platform | Minimum |
|----------|---------|
| iOS | 12.0+ |
| macOS | 10.13+ |
| tvOS | 12.0+ |
| watchOS | 4.0+ |
| visionOS | 1.0+ |
| Swift | 5.3+ |

## Installation

### Swift Package Manager

Add CDUntappdKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/chrisdhaan/CDUntappdKit.git", .upToNextMajor(from: "2.0.0"))
]
```

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'CDUntappdKit', '~> 2.0'
```

### Git Submodule

Clone the repository and add `CDUntappdKit.xcodeproj` to your Xcode project:

```bash
git submodule add https://github.com/chrisdhaan/CDUntappdKit.git
```

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

API reference is available at https://chrisdhaan.github.io/CDUntappdKit/documentation/cduntappdkit/

## Author

Christopher de Haan, contact@christopherdehaan.me

## License

MIT

---

For more information, visit the [Untappd Developers](https://untappd.com/api/docs) portal.
