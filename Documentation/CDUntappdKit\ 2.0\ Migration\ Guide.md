# CDUntappdKit 2.0 Migration Guide

Guide for upgrading from CDUntappdKit 1.x to 2.0. Version 2.0 is a major release with breaking changes.

## Table of Contents

- [Deployment Targets Raised](#deployment-targets-raised)
- [Completion Handlers Replaced with Async/Await](#completion-handlers-replaced-with-asyncawait)
- [Error Handling Changes](#error-handling-changes)
- [Carthage Removed](#carthage-removed)
- [CocoaPods Removed](#cocoapods-removed)
- [Cancellation Pattern Changed](#cancellation-pattern-changed)
- [Alamofire Version Updated](#alamofire-version-updated)

---

## Deployment Targets Raised

CDUntappdKit 2.0 requires higher minimum deployment targets than 1.x.

### New Minimum Versions

| Platform | 1.x | 2.0 |
|----------|-----|-----|
| iOS | 10.0+ | **12.0+** |
| macOS | 10.12+ | **10.13+** |
| tvOS | 10.0+ | **12.0+** |
| watchOS | 3.0+ | **4.0+** |
| visionOS | Not supported | **1.0+** |

### What to Do

If your app targets versions lower than those above, you must either:

1. **Update your app's deployment target** to match CDUntappdKit 2.0's minimums, or
2. **Continue using CDUntappdKit 1.x** and do not upgrade

To check your current deployment target in Xcode:

1. Select your project in the Project Navigator
2. Select the target
3. Go to the **General** tab
4. Look for **Minimum Deployments** section

Update the minimum deployment target to 12.0 for iOS, 10.13 for macOS, etc.

---

## Completion Handlers Replaced with Async/Await

CDUntappdKit 2.0 replaces completion handler callbacks with Swift's modern `async/await` syntax.

### Before (1.x)

```swift
untappdAPIClient.fetchUserInfo(forUsername: "DehaanSolo",
                               compact: false) { (response) in
    if let response = response,
        let user = response.user {
        print(user.username ?? "")
    }
}
```

### After (2.0)

```swift
Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: "DehaanSolo",
                                                      compact: false)
        if let user = response.user {
            print(user.username ?? "")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### All Affected Methods

Update these method calls:

- `fetchUserInfo(forUsername:compact:)` — now `async throws`
- `fetchUserWishList(forUsername:offset:limit:sort:)` — now `async throws`
- `fetchUserFriends(forUsername:offset:limit:)` — now `async throws`

All methods must be called from `async` contexts (within `Task { }`, `async` functions, etc.).

### Calling from Non-Async Code

If you're updating a synchronous function, wrap the async call in a `Task`:

```swift
func loadUserProfile() {
    Task {
        do {
            let response = try await client.fetchUserInfo(forUsername: "DehaanSolo",
                                                          compact: false)
            // Update UI on main thread
            DispatchQueue.main.async {
                self.updateUI(with: response)
            }
        } catch {
            print("Failed to load user: \(error)")
        }
    }
}
```

### Making Your Own Async Functions

If you're building helper functions, make them `async throws`:

```swift
func fetchAndProcessUserData(username: String) async throws -> ProcessedUser {
    let response = try await client.fetchUserInfo(forUsername: username, compact: false)
    return processUserData(response.user)
}

// Call from Task
Task {
    let processed = try await fetchAndProcessUserData(username: "DehaanSolo")
}
```

---

## Error Handling Changes

In 1.x, API errors were swallowed and returned `nil` via the completion handler. In 2.0, errors are thrown and must be caught.

### Before (1.x)

```swift
untappdAPIClient.fetchUserInfo(forUsername: "DehaanSolo",
                               compact: false) { (response) in
    if let response = response {
        // Success path
    } else {
        // Error — but you don't know why
    }
}
```

### After (2.0)

```swift
Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: "DehaanSolo",
                                                      compact: false)
        // Success path
    } catch let error as CDUntappdKitError {
        switch error {
        case .sessionUnavailable:
            print("OAuth credentials not configured")
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

### Error Types

All errors thrown are now `CDUntappdKitError`:

- **`sessionUnavailable`** — Alamofire session failed to initialize
- **`apiError(String)`** — Untappd API returned an error (invalid username, rate limit, etc.)
- **`decodingFailed(Error)`** — Response couldn't be decoded into the model

This provides much better visibility into what went wrong.

---

## Carthage Removed

CDUntappdKit 2.0 no longer supports Carthage. You must migrate to Swift Package Manager.

### Migrate from Carthage

#### Option 1: Swift Package Manager (Recommended)

1. **Remove Carthage:**
   ```bash
   rm Cartfile Cartfile.resolved
   rm -rf Carthage/
   ```

2. **Add CDUntappdKit via Xcode:**
   - Go to **File** > **Add Packages**
   - Paste: `https://github.com/chrisdhaan/CDUntappdKit.git`
   - Select version **2.0.0** or later
   - Click **Add Package**

3. **Update your code:**
   ```swift
   import CDUntappdKit
   ```

---

## CocoaPods Removed

CDUntappdKit 2.0 drops CocoaPods as a distribution channel (CocoaPods trunk is being deprecated in 2026). Swift Package Manager is now the only supported install method — see [Swift Package Manager](#option-1-swift-package-manager-recommended) above.

---

## Cancellation Pattern Changed

In 1.x, cancellation used the `cancelAllPendingAPIRequests()` method. In 2.0, use Swift's `Task` cancellation API for finer control.

### Before (1.x)

```swift
// Cancel all requests
untappdAPIClient.cancelAllPendingAPIRequests()
```

### After (2.0)

```swift
// Store the task
var currentTask: Task<Void, Never>?

// Start a request
currentTask = Task {
    do {
        let response = try await client.fetchUserInfo(forUsername: "DehaanSolo",
                                                      compact: false)
        // Handle response
    } catch is CancellationError {
        print("Request was cancelled")
    } catch {
        print("Request failed: \(error)")
    }
}

// Later, cancel the specific task
currentTask?.cancel()
```

### Why the Change?

The new pattern allows you to:

- Cancel **specific** requests instead of all requests
- Have fine-grained control over cancellation
- Use Swift's standard concurrency APIs
- Avoid the deprecated `cancelAllPendingAPIRequests()` method

### Deprecated Method

The old `cancelAllPendingAPIRequests()` method is marked `@available(*, deprecated)` and will be removed in a future version. If you're still using it:

```swift
// This is deprecated — don't use it
untappdAPIClient.cancelAllPendingAPIRequests()

// Use Task cancellation instead
currentTask?.cancel()
```

---

## Alamofire Version Updated

CDUntappdKit 2.0 requires Alamofire 5.9 or later (up from 5.6.1 in 1.x).

### What to Check

If your project **separately pins Alamofire**, ensure there's no version conflict:

#### Swift Package Manager

In your `Package.swift`, Alamofire should be `5.9` or higher:

```swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.0"))
]
```

### Why the Update?

Alamofire 5.9 includes:
- Bug fixes and performance improvements
- Better compatibility with modern Swift versions
- Enhanced error handling

If you don't separately pin Alamofire, CDUntappdKit 2.0 will automatically use 5.9+, and you don't need to do anything.

---

## Summary

| Feature | 1.x | 2.0 |
|---------|-----|-----|
| **iOS minimum** | 10.0+ | 12.0+ |
| **macOS minimum** | 10.12+ | 10.13+ |
| **tvOS minimum** | 10.0+ | 12.0+ |
| **watchOS minimum** | 3.0+ | 4.0+ |
| **visionOS** | Not supported | 1.0+ |
| **API style** | Completion handlers | async/await |
| **Error handling** | nil returns | Thrown errors |
| **Carthage** | Supported | Removed |
| **CocoaPods** | Supported | Removed |
| **Cancellation** | `cancelAllPendingAPIRequests()` | `Task.cancel()` |
| **Alamofire** | 5.6.1 | 5.9+ |

---

## Need Help?

- Check the [Usage Guide](Usage.md) for complete examples
- See the [API Reference](https://chrisdhaan.github.io/CDUntappdKit/) for method signatures
- Open an issue on [GitHub](https://github.com/chrisdhaan/CDUntappdKit/issues) if you encounter problems
