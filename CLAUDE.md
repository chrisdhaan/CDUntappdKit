# CDUntappdKit

Swift wrapper for the Untappd API. Supports iOS 15+, macOS 12+, tvOS 15+, watchOS 8+.

## Repository Layout

| Path | Purpose |
|------|---------|
| `Source/` | Library source — 50 Swift files |
| `Source/CDUntappdKit.docc/` | DocC documentation catalog |
| `Tests/CDUntappdKitTests/` | Swift Testing unit tests |
| `iOS Example/` | Demo app (requires valid Untappd credentials) |
| `Resources/` | OAuth storyboard |
| `Documentation/` | Usage guide, architecture, migration guide |
| `docs/` | DocC-generated API reference (served by GitHub Pages) |
| `scripts/generate-docs.sh` | Regenerates `docs/` (handles Jekyll/`.nojekyll`, index.html redirect, 404.html) |
| `Package.swift` | SPM manifest (swift-tools-version:6.0) |
| `.github/workflows/ci.yml` | GitHub Actions CI |
| `.swiftformat` | SwiftFormat configuration |

## Platform Support

| Platform | Minimum | Reason |
|----------|---------|--------|
| iOS | 15.0 | Native URLSession async/await (`data(for:)`, `allTasks`) requires no back-deployment shim |
| macOS | 12.0 | Matches iOS's URLSession async/await floor |
| tvOS | 15.0 | Matches iOS |
| watchOS | 8.0 | Matches iOS's URLSession async/await floor |
| visionOS | 1.0 | UIKit-based; matches CDMarkdownKit 3.1.0 precedent |

## Architecture

See `Documentation/ARCHITECTURE.md` for the full design overview.

Key classes:
- `CDUntappdAPIClient` — Primary public API client, `@MainActor`
- `CDUntappdOAuthClient` — OAuth token management via UserDefaults
- `CDUntappdRouter` — Enum encoding Untappd API endpoints as `URLRequest`s
- `CDUntappdOAuthViewController` — iOS WKWebView-based OAuth flow

## Building

```bash
# SPM
swift build
swift test

# DocC docs (generates docs/ directory, fixes up Jekyll/index.html/404.html)
bash scripts/generate-docs.sh

# Format source before committing
swiftformat Source Tests

# Check formatting (CI mode)
swiftformat Source Tests --lint
```

## CI Jobs

| Job | Runner | Purpose |
|-----|--------|---------|
| iOS (×5) | macos-26 + macos-15 | Build all iOS Xcode versions |
| macOS (×11) | macos-26 + macos-15 | Build all macOS Xcode versions |
| tvOS (×5) | macos-26 + macos-15 | Build all tvOS Xcode versions |
| watchOS (×5) | macos-26 + macos-15 | Build all watchOS Xcode versions |
| visionOS (×4) | macos-26 | Build all visionOS Xcode versions |
| Catalyst | macos-15 | Catalyst build |
| SPM | macos-15 | swift test |
| SwiftLint | macos-15 | Strict lint enforcement |
| SwiftFormat | macos-15 | Format check (`--lint` mode) |
| DocC Build | macos-15 | Documentation build verification |
| CodeQL | macos-15 | Security scanning |

## Known Limitations / Tech Debt

- 17 of 28 Untappd endpoints are implemented — the 11 remaining are the write/action endpoints (checkin, toast, comments, friend requests, wish list add/remove), tracked in [issue #28](https://github.com/chrisdhaan/CDUntappdKit/issues/28)
- No watchOS OAuth flow (WKWebView unavailable on watchOS)
- No visionOS OAuth flow — `authenticate()` is `#if os(iOS) || os(visionOS)` but the UIApplication-based top-view-controller lookup may need a visionOS-specific window scene approach
