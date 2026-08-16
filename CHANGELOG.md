# Change Log
All notable changes to this project will be documented in this file.
`CDUntappdKit` adheres to [Semantic Versioning](https://semver.org/).

## Table of Contents

- [3.1.0](#310)
- [3.0.0](#300)
- [2.0.0](#200)
- [1.1.0](#110)
- [1.0.0](#100)

---

## [3.1.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/3.1.0)

Released on 2026-08-16.

"Expanded Endpoint Coverage" — implements the 7 `CDUntappdRouter` cases that previously had no corresponding `CDUntappdAPIClient` method. Every router case is now backed by a public async/await API method.

### Added

- `CDUntappdAPIClient.fetchUserBadges(forUsername:offset:)` — user's earned badges
- `CDUntappdAPIClient.fetchUserBeers(forUsername:offset:limit:sort:)` — beers the user has checked in
- `CDUntappdAPIClient.fetchBeerInfo(forBid:compact:)` — beer info by ID
- `CDUntappdAPIClient.fetchBreweryInfo(forBreweryId:compact:)` — brewery info by ID
- `CDUntappdAPIClient.fetchVenueInfo(forVenueId:compact:)` — venue info by ID
- `CDUntappdAPIClient.searchBeers(query:offset:limit:sort:)` — beer search
- `CDUntappdAPIClient.searchBreweries(query:offset:)` — brewery search
- `CDUntappdUserBeersSortType` / `CDUntappdBeerSearchSortType` — endpoint-specific sort options for the two new endpoints that take a `sort` parameter (each accepts a different subset of values than `CDUntappdUserWishListSortType`, per the Untappd API docs)
- 15 new tests (model decode coverage for the 7 new response types, plus a lenient-bool decode case for `CDUntappdBeer.isInProduction`) — 160 tests across 33 suites

### Fixed

- `CDUntappdBeer.isInProduction` now decodes leniently from either a JSON boolean or a `1`/`0` integer, matching the existing behavior of `CDUntappdBrewery.isActive`/`CDUntappdVenue.isVerified` — the real Untappd API returns this field as an integer, which previously would have thrown a decoding error

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
