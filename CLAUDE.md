# CDUntappdKit

Swift wrapper for the Untappd API. Supports iOS 12+, macOS 10.13+, tvOS 12+, watchOS 4+.

## Repository Layout

| Path | Purpose |
|------|---------|
| `Source/` | Library source — 35 Swift files |
| `Source/CDUntappdKit.docc/` | DocC documentation catalog |
| `Tests/CDUntappdKitTests/` | Swift Testing unit tests |
| `iOS Example/` | Demo app (requires valid Untappd credentials) |
| `Resources/` | OAuth storyboard |
| `Documentation/` | Usage guide, architecture, migration guide |
| `docs/` | DocC-generated API reference (served by GitHub Pages) |
| `Package.swift` | SPM manifest (swift-tools-version:6.0) |
| `CDUntappdKit.podspec` | CocoaPods spec |
| `.github/workflows/ci.yml` | GitHub Actions CI |
| `.swiftformat` | SwiftFormat configuration |
| `Gemfile` | Ruby gem dependencies (CocoaPods) |

## Platform Support

| Platform | Minimum | Reason |
|----------|---------|--------|
| iOS | 12.0 | os.log, async URLSession back-deployment floor |
| macOS | 10.13 | os.log availability |
| tvOS | 12.0 | Matches iOS |
| watchOS | 4.0 | SPM minimum expressible without deprecation warnings |
| visionOS | 1.0 | UIKit-based; matches CDMarkdownKit 3.1.0 precedent |

## Architecture

See `Documentation/ARCHITECTURE.md` for the full design overview.

Key classes:
- `CDUntappdAPIClient` — Primary public API client, `@MainActor`
- `CDUntappdOAuthClient` — OAuth token management via UserDefaults
- `CDUntappdRouter` — Alamofire `URLRequestConvertible` enum
- `CDUntappdOAuthViewController` — iOS WKWebView-based OAuth flow

## Building

```bash
# SPM
swift build
swift test

# DocC docs (generates docs/ directory)
swift package --disable-sandbox generate-documentation \
  --target CDUntappdKit \
  --output-path docs \
  --transform-for-static-hosting \
  --hosting-base-path CDUntappdKit

# Format source (apply)
swiftformat Source Tests

# Check formatting (CI mode)
swiftformat Source Tests --lint

# Pod lint
bundle exec pod lib lint --allow-warnings
```

## CI Jobs

| Job | Runner | Purpose |
|-----|--------|---------|
| iOS (×5) | macos-26 + macos-15 | Build all iOS Xcode versions |
| macOS (×6) | macos-26 + macos-15 | Build all macOS Xcode versions |
| tvOS (×5) | macos-26 + macos-15 | Build all tvOS Xcode versions |
| watchOS (×5) | macos-26 + macos-15 | Build all watchOS Xcode versions |
| visionOS (×4) | macos-26 | Build all visionOS Xcode versions |
| Catalyst | macos-15 | Catalyst build |
| CocoaPods | macos-15 | pod lib lint |
| SPM | macos-15 | swift test |
| SwiftLint | macos-15 | Strict lint enforcement |
| SwiftFormat | macos-15 | Format check (`--lint` mode) |
| DocC Build | macos-15 | Documentation build verification |
| CodeQL | macos-15 | Security scanning |

## Known Limitations / Tech Debt

- OAuth token stored in `UserDefaults` — should migrate to Keychain
- Only 3 of 20+ Untappd endpoints are implemented
- No watchOS OAuth flow (WKWebView unavailable on watchOS)
- No visionOS OAuth flow — `authenticate()` is `#if os(iOS) || os(visionOS)` but the UIApplication-based top-view-controller lookup may need a visionOS-specific window scene approach
- `@unchecked Sendable` on `CDUntappdAPIClient` — pending full thread-safety audit
