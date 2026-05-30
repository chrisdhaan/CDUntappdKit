# CDUntappdKit 2.0.0 Modernization Plan

This document is the authoritative implementation guide for modernizing CDUntappdKit to match the conventions and quality bar established by CDMarkdownKit 3.0.0. Every section corresponds to a discrete, committable unit of work. Follow sections in order; later sections may depend on earlier ones.

**Reference:** CDMarkdownKit 3.1.0 (commits 4ece4c7, f835225, 41fc92f, 944a0b8) is the canonical modernized state for all naming, structure, CI configuration, and tooling choices. 3.1.0 adds DocC documentation (replacing Jazzy), visionOS platform support, and SwiftFormat enforcement — all of which apply to CDUntappdKit.

---

## Table of Contents

1. [Repository & GitHub Community Health](#1-repository--github-community-health)
2. [CI/CD Modernization](#2-cicd-modernization)
3. [Swift Package Manager Modernization](#3-swift-package-manager-modernization)
4. [CocoaPods Modernization](#4-cocoapods-modernization)
5. [Carthage Removal](#5-carthage-removal)
6. [Ruby Toolchain — Gemfile](#6-ruby-toolchain--gemfile)
7. [Privacy Manifest](#7-privacy-manifest)
8. [Xcode Project Modernization](#8-xcode-project-modernization)
9. [Source Code — Swift 6 Concurrency](#9-source-code--swift-6-concurrency)
10. [Async/Await API Migration](#10-asyncawait-api-migration)
11. [Unit Tests](#11-unit-tests)
12. [API Documentation — DocC](#12-api-documentation--docc)
13. [Documentation Updates](#13-documentation-updates)
14. [CLAUDE.md & ARCHITECTURE.md](#14-claudemd--architecturemd)
15. [Version Bump to 2.0.0](#15-version-bump-to-200)
16. [visionOS Support](#16-visionary-os-support)
17. [SwiftFormat](#17-swiftformat)

---

## Current State Summary

| Area | Current | Target |
|------|---------|--------|
| Version | 1.1.0 | 2.0.0 |
| Swift tools version | 5.6 | 6.0 |
| iOS deployment target | 10.0 | 12.0 |
| macOS deployment target | 10.12 | 10.13 |
| tvOS deployment target | 10.0 | 12.0 |
| watchOS deployment target | 3.0 | 4.0 |
| visionOS deployment target | Not supported | 1.0 |
| Swift versions (podspec) | 5.3, 5.4, 5.5 | 5 |
| Alamofire version | 5.6.1 (pinned) | 5.9+ (upToNextMajor) |
| swift-docc-plugin | absent | 1.3.0+ |
| CI runners | macOS-10.15/11/12 | macos-15/macos-26 |
| CI formatter | xcpretty | xcbeautify |
| CI actions | checkout@v3, cache@v3 | checkout@v4, cache@v4 |
| Dependency management | Carthage + SPM + CocoaPods | SPM + CocoaPods |
| API style | Completion handlers | async/await |
| Tests | None | Swift Testing framework |
| Documentation | README only | README + Usage.md + DocC |
| Privacy manifest | None | PrivacyInfo.xcprivacy |
| swiftLanguageVersions | deprecated | swiftLanguageModes: [.v5] |
| Versioned Package files | 4 files (5.3–5.5) | Removed |
| Copyright year | 2016–2022 | 2016–2026 |
| SwiftFormat | None | .swiftformat config + CI lint job |

---

## 1. Repository & GitHub Community Health

### 1.1 Add FUNDING.yml ✅

**File to create:** `.github/FUNDING.yml`

```yaml
github: chrisdhaan
```

This adds a "Sponsor" button to the repository on GitHub.

### 1.2 Replace ISSUE_TEMPLATE.md with Directory Structure ✅

**Delete:** `.github/ISSUE_TEMPLATE.md`

**Create:** `.github/ISSUE_TEMPLATE/config.yml`

```yaml
blank_issues_enabled: false
contact_links:
  - name: Usage Question
    url: https://stackoverflow.com/questions/tagged/cduntappdkit
    about: Please ask usage questions on Stack Overflow using the `cduntappdkit` tag.
  - name: Security Vulnerability
    url: mailto:contact@christopherdehaan.me
    about: Please report security vulnerabilities privately via email.
```

**Create:** `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
---
name: Bug Report
about: Report a reproducible bug or regression.
labels: bug
---

**What did you do?**
<!-- A clear description of the steps that produced the bug. -->

**What did you expect to happen?**

**What actually happened?**

**CDUntappdKit version:**

**Swift version:**

**Platform and OS version:**

**Minimal reproducible example:**
<!-- A short Swift snippet that demonstrates the bug. -->
```

**Create:** `.github/ISSUE_TEMPLATE/feature_request.md`

```markdown
---
name: Feature Request
about: Suggest a new feature or enhancement.
labels: enhancement
---

**What problem does this feature solve?**

**Describe the solution you'd like.**

**Have you considered any alternatives?**
```

### 1.3 Update PULL_REQUEST_TEMPLATE.md ✅

**File:** `.github/PULL_REQUEST_TEMPLATE.md`

Replace the current emoji-laden template with the modernized format used by CDMarkdownKit:

```markdown
### Issue

> Link to the GitHub issue this PR addresses.

### Goals

> Bullet list of what this PR accomplishes.

### Implementation Details

> Describe any non-obvious implementation decisions.

### Testing Details

> How was this tested? List new tests added, or explain why no tests are needed.
```

The key changes: remove emoji, replace HTML comment instructions with blockquote guidance, remove the checkbox at the top.

### 1.4 Update LICENSE Copyright Year ✅

**File:** `LICENSE`

Update the copyright line from:

```
Copyright (c) 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
```

to:

```
Copyright (c) 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
```

---

## 2. CI/CD Modernization

The current `.github/workflows/ci.yml` uses macOS-10.15/11/12 runners (retired), Xcode 12.x/13.x (outdated), xcpretty (unmaintained), checkout@v3/cache@v3 (outdated), and Carthage for dependency resolution. The entire workflow needs to be rewritten.

### 2.1 Key Changes Summary

| Change | Current | Target |
|--------|---------|--------|
| macOS runners | macOS-10.15/11/12 | macos-15 / macos-26 |
| Xcode versions | 12.4–13.4.1 | 16.4 (macos-15) + 26.1.1–26.4.1 (macos-26) |
| Output formatter | xcpretty | xcbeautify --renderer github-actions |
| Checkout action | actions/checkout@v3 | actions/checkout@v4 |
| Cache action | actions/cache@v3 | actions/cache@v4 |
| Dependency resolution | Carthage | Removed (SPM handles all) |
| Swift Package builds | swift build | swift test -c debug |
| Added jobs | — | SwiftLint, CodeQL, CocoaPods (dedicated) |
| Path triggers | Source/**, .github/workflows/**, Package.swift | + Tests/** |
| concurrency group | ci (static) | ${{ github.ref_name }} |
| Pod lint invocation | gem install + pod lib lint | bundle install + bundle exec pod lib lint |

### 2.2 New ci.yml — Complete Replacement

**File:** `.github/workflows/ci.yml`

```yaml
name: "CDUntappdKit CI"

on:
  push:
    branches:
      - master
    paths:
      - ".github/workflows/**"
      - "Package.swift"
      - "Source/**"
      - "Tests/**"
  pull_request:
    paths:
      - ".github/workflows/**"
      - "Package.swift"
      - "Source/**"
      - "Tests/**"

concurrency:
  group: ${{ github.ref_name }}
  cancel-in-progress: true

jobs:
  iOS:
    name: Test ${{ matrix.name }}
    runs-on: ${{ matrix.runner }}
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        include:
          - runner: macos-26
            xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
            destination: "OS=26.2,name=iPhone 17 Pro"
            name: "iOS 26 (Xcode 26.4.1)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.3.app/Contents/Developer
            destination: "OS=26.2,name=iPhone 17 Pro"
            name: "iOS 26 (Xcode 26.3)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.2.app/Contents/Developer
            destination: "OS=26.2,name=iPhone 17 Pro"
            name: "iOS 26 (Xcode 26.2)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
            destination: "OS=26.1,name=iPhone 17 Pro"
            name: "iOS 26 (Xcode 26.1.1)"
          - runner: macos-15
            xcode: /Applications/Xcode_16.4.app/Contents/Developer
            destination: "OS=18.5,name=iPhone 16 Pro"
            name: "iOS 18 (Xcode 16.4)"
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s ${{ matrix.xcode }}
      - name: List available simulators
        run: xcrun simctl list
      - name: Install xcbeautify
        run: brew install xcbeautify
      - name: ${{ matrix.name }} - Debug
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit iOS" -destination "${{ matrix.destination }}" -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
      - name: ${{ matrix.name }} - Release
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit iOS" -destination "${{ matrix.destination }}" -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions

  macOS:
    name: Test ${{ matrix.name }}
    runs-on: ${{ matrix.runner }}
    timeout-minutes: 10
    strategy:
      fail-fast: false
      matrix:
        include:
          - runner: macos-26
            xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
            name: "macOS 26 (Xcode 26.4.1)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.3.app/Contents/Developer
            name: "macOS 26 (Xcode 26.3)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.2.app/Contents/Developer
            name: "macOS 26 (Xcode 26.2)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
            name: "macOS 26 (Xcode 26.1.1)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.0.1.app/Contents/Developer
            name: "macOS 26 (Xcode 26.0.1)"
          - runner: macos-15
            xcode: /Applications/Xcode_16.4.app/Contents/Developer
            name: "macOS 15 (Xcode 16.4)"
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s ${{ matrix.xcode }}
      - name: Install xcbeautify
        run: brew install xcbeautify
      - name: ${{ matrix.name }} - Debug
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit macOS" -destination "platform=macOS" -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
      - name: ${{ matrix.name }} - Release
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit macOS" -destination "platform=macOS" -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions

  tvOS:
    name: Test ${{ matrix.name }}
    runs-on: ${{ matrix.runner }}
    timeout-minutes: 10
    strategy:
      fail-fast: false
      matrix:
        include:
          - runner: macos-26
            xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
            destination: "OS=26.4,name=Apple TV 4K (3rd generation) (at 1080p)"
            name: "tvOS 26 (Xcode 26.4.1)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.3.app/Contents/Developer
            destination: "OS=26.2,name=Apple TV 4K (3rd generation) (at 1080p)"
            name: "tvOS 26 (Xcode 26.3)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.2.app/Contents/Developer
            destination: "OS=26.2,name=Apple TV 4K (3rd generation) (at 1080p)"
            name: "tvOS 26 (Xcode 26.2)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
            destination: "OS=26.1,name=Apple TV 4K (3rd generation) (at 1080p)"
            name: "tvOS 26 (Xcode 26.1.1)"
          - runner: macos-15
            xcode: /Applications/Xcode_16.4.app/Contents/Developer
            destination: "OS=18.5,name=Apple TV 4K (3rd generation) (at 1080p)"
            name: "tvOS 18 (Xcode 16.4)"
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s ${{ matrix.xcode }}
      - name: List available simulators
        run: xcrun simctl list
      - name: Install xcbeautify
        run: brew install xcbeautify
      - name: ${{ matrix.name }} - Debug
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit tvOS" -destination "${{ matrix.destination }}" -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
      - name: ${{ matrix.name }} - Release
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit tvOS" -destination "${{ matrix.destination }}" -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions

  watchOS:
    name: Test ${{ matrix.name }}
    runs-on: ${{ matrix.runner }}
    timeout-minutes: 10
    strategy:
      fail-fast: false
      matrix:
        include:
          - runner: macos-26
            xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
            destination: "OS=26.4,name=Apple Watch Series 11 (46mm)"
            name: "watchOS 26 (Xcode 26.4.1)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.3.app/Contents/Developer
            destination: "OS=26.2,name=Apple Watch Series 11 (46mm)"
            name: "watchOS 26 (Xcode 26.3)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.2.app/Contents/Developer
            destination: "OS=26.2,name=Apple Watch Series 11 (46mm)"
            name: "watchOS 26 (Xcode 26.2)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
            destination: "OS=26.1,name=Apple Watch Series 11 (46mm)"
            name: "watchOS 26 (Xcode 26.1.1)"
          - runner: macos-15
            xcode: /Applications/Xcode_16.4.app/Contents/Developer
            destination: "OS=11.5,name=Apple Watch Series 10 (46mm)"
            name: "watchOS 11 (Xcode 16.4)"
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s ${{ matrix.xcode }}
      - name: List available simulators
        run: xcrun simctl list
      - name: Install xcbeautify
        run: brew install xcbeautify
      - name: ${{ matrix.name }} - Debug
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit watchOS" -destination "${{ matrix.destination }}" -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
      - name: ${{ matrix.name }} - Release
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit watchOS" -destination "${{ matrix.destination }}" -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions

  Catalyst:
    name: Test Catalyst
    runs-on: macos-15
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
      - name: Install xcbeautify
        run: brew install xcbeautify
      - name: Catalyst - Debug
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit iOS" -destination "platform=macOS" -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
      - name: Catalyst - Release
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit iOS" -destination "platform=macOS" -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions

  CocoaPods:
    name: pod lib lint
    runs-on: macos-15
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
      - uses: actions/cache@v4
        with:
          path: Pods
          key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
          restore-keys: |
            ${{ runner.os }}-pods-
      - name: Install Gems
        run: bundle install
      - name: pod lib lint
        run: bundle exec pod lib lint --allow-warnings

  SPM:
    name: Test with SPM
    runs-on: macos-15
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
      - name: Install xcbeautify
        run: brew install xcbeautify
      - name: swift test
        run: set -o pipefail && swift test -c debug 2>&1 | xcbeautify --renderer github-actions

  visionOS:
    name: Test ${{ matrix.name }}
    runs-on: ${{ matrix.runner }}
    timeout-minutes: 10
    strategy:
      fail-fast: false
      matrix:
        include:
          - runner: macos-26
            xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
            destination: "OS=26.2,name=Apple Vision Pro"
            name: "visionOS 26 (Xcode 26.4.1)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.3.app/Contents/Developer
            destination: "OS=26.2,name=Apple Vision Pro"
            name: "visionOS 26 (Xcode 26.3)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.2.app/Contents/Developer
            destination: "OS=26.2,name=Apple Vision Pro"
            name: "visionOS 26 (Xcode 26.2)"
          - runner: macos-26
            xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
            destination: "OS=26.1,name=Apple Vision Pro"
            name: "visionOS 26 (Xcode 26.1.1)"
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s ${{ matrix.xcode }}
      - name: List available simulators
        run: xcrun simctl list
      - name: Install xcbeautify
        run: brew install xcbeautify
      - name: ${{ matrix.name }} - Debug
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit visionOS" -destination "${{ matrix.destination }}" -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
      - name: ${{ matrix.name }} - Release
        run: |
          set -o pipefail
          env NSUnbufferedIO=YES xcodebuild -project "CDUntappdKit.xcodeproj" -scheme "CDUntappdKit visionOS" -destination "${{ matrix.destination }}" -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions

  swiftlint:
    name: SwiftLint
    runs-on: macos-15
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Install SwiftLint
        run: brew install swiftlint
      - name: Lint
        run: swiftlint lint --strict

  swiftformat:
    name: SwiftFormat
    runs-on: macos-15
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Install SwiftFormat
        run: brew install swiftformat
      - name: Check formatting
        run: swiftformat Source Tests --lint

  documentation:
    name: DocC Build
    runs-on: macos-15
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
      - name: Build DocC
        run: |
          swift package --disable-sandbox generate-documentation \
            --target CDUntappdKit \
            --output-path /tmp/docc-output \
            --transform-for-static-hosting \
            --hosting-base-path CDUntappdKit \
            2>&1 | tee docc.log
      - name: Fail on DocC warnings
        run: grep -qE "^warning:" docc.log && exit 1 || exit 0

  codeql:
    name: CodeQL
    runs-on: macos-15
    timeout-minutes: 20
    permissions:
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: swift
      - name: Build
        run: |
          xcodebuild -project CDUntappdKit.xcodeproj \
            -scheme "CDUntappdKit iOS" \
            -destination "generic/platform=iOS" \
            -configuration Debug \
            clean build
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
```

### 2.3 Notes on CI Architecture

- **No Carthage steps**: All dependency resolution is now handled by Xcode/SPM directly. The `Cartfile`, `Cartfile.resolved`, and `.gitmodules` are removed in Section 5.
- **`swift test` instead of `swift build`**: Once Section 11 (Unit Tests) is complete, the SPM job runs tests rather than just building. Until tests exist, temporarily use `swift build -c debug` and update after Section 11 is done.
- **`bundle exec pod lib lint`**: Requires the Gemfile from Section 6. Remove `--use-libraries` flag (not needed with modern Alamofire SPM distribution).
- **SwiftLint strict mode**: The `.swiftlint.yml` already exists and includes appropriate rules. The CI job enforces it strictly on every push.
- **SwiftFormat lint mode**: The `swiftformat` job runs `--lint` (check only, no writes) against `Source` and `Tests`. It fails if any file is not formatted according to `.swiftformat`. See Section 17 for the config file and how to apply formatting locally.
- **DocC build job**: The `documentation` job runs `swift package generate-documentation` to verify the DocC catalog compiles without warnings. The actual static site is generated and committed locally (see Section 12). The CI job does not publish — it only verifies.
- **visionOS job**: Runs only on `macos-26` runners (visionOS simulator not available on `macos-15` with Xcode 16.x). Requires the `CDUntappdKit visionOS` Xcode scheme added in Section 16.
- **CodeQL**: Builds the iOS scheme for Swift security analysis. Results appear in the GitHub Security tab.
- **Simulator destinations**: The destination strings above reflect runtimes confirmed available on GitHub-hosted runners as of 2026-05. Verify against the `actions/runner-images` repository if builds fail.

---

## 3. Swift Package Manager Modernization

### 3.1 Remove Versioned Package Files

Delete the following files (they are redundant once the primary Package.swift supports modern tooling):

- `Package@swift-5.3.swift`
- `Package@swift-5.4.swift`
- `Package@swift-5.5.swift`

### 3.2 Update Package.swift

**File:** `Package.swift`

Replace the entire file with:

```swift
// swift-tools-version:6.0
//
//  Package.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 05/07/2017.
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import PackageDescription

let package = Package(name: "CDUntappdKit",
                      platforms: [.iOS(.v12),
                                  .macOS(.v10_13),
                                  .tvOS(.v12),
                                  .watchOS(.v4),
                                  .visionOS(.v1)],
                      products: [.library(name: "CDUntappdKit",
                                          targets: ["CDUntappdKit"]),
                                 .library(name: "CDUntappdKitDynamic",
                                          type: .dynamic,
                                          targets: ["CDUntappdKit"])],
                      dependencies: [
                          .package(url: "https://github.com/Alamofire/Alamofire.git",
                                   .upToNextMajor(from: "5.9.0")),
                          .package(url: "https://github.com/apple/swift-docc-plugin",
                                   from: "1.3.0")
                      ],
                      targets: [.target(name: "CDUntappdKit",
                                        dependencies: [
                                            .product(name: "Alamofire", package: "Alamofire")
                                        ],
                                        path: "Source",
                                        exclude: ["Info.plist"],
                                        resources: [.process("PrivacyInfo.xcprivacy")],
                                        swiftSettings: [
                                            .enableUpcomingFeature("ExistentialAny")
                                        ],
                                        linkerSettings: [
                                            .linkedFramework("UIKit",
                                                             .when(platforms: [.iOS, .tvOS, .visionOS])),
                                            .linkedFramework("Cocoa",
                                                             .when(platforms: [.macOS]))
                                        ]),
                                .testTarget(
                                    name: "CDUntappdKitTests",
                                    dependencies: ["CDUntappdKit"]
                                )],
                      swiftLanguageModes: [.v5])
```

**Key changes from current:**

| Change | Old | New |
|--------|-----|-----|
| swift-tools-version | 5.6 | 6.0 |
| iOS platform | .v10 | .v12 |
| macOS platform | .v10_12 | .v10_13 |
| tvOS platform | .v10 | .v12 |
| watchOS platform | .v3 | .v4 |
| visionOS platform | absent | .v1 |
| Alamofire version | "== 5.6.1" (via upToNextMajor 5.6.1) | upToNextMajor 5.9.0 |
| swift-docc-plugin | absent | from: "1.3.0" |
| swiftLanguageVersions | [.v5] (deprecated) | replaced by swiftLanguageModes |
| swiftLanguageModes | absent | [.v5] |
| Dynamic product | absent | CDUntappdKitDynamic added |
| PrivacyInfo resource | absent | .process("PrivacyInfo.xcprivacy") |
| ExistentialAny | absent | .enableUpcomingFeature("ExistentialAny") |
| UIKit linker setting | iOS, tvOS | iOS, tvOS, visionOS |
| Cocoa linker setting | absent | macOS (explicit) |
| Test target | absent | CDUntappdKitTests added |

**Why `upToNextMajor(from: "5.9.0")`:** Alamofire 5.9+ includes stable `async/await` overloads on `DataRequest` and `DataTask`. Pinning to exactly `5.6.1` prevented users from getting security updates. The `.upToNextMajor` constraint preserves source compatibility while allowing patch/minor updates.

---

## 4. CocoaPods Modernization

**File:** `CDUntappdKit.podspec`

Replace with:

```ruby
Pod::Spec.new do |s|
  s.name = 'CDUntappdKit'
  s.version = '2.0.0'
  s.cocoapods_version = '>= 1.13.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An extensive Swift wrapper for the Untappd API.'
  s.description = <<-DESC
    This Swift wrapper covers all possible network endpoints and responses for the Untappd API.
  DESC
  s.homepage = 'https://github.com/chrisdhaan/CDUntappdKit'
  s.author = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source = { :git => 'https://github.com/chrisdhaan/CDUntappdKit.git', :tag => s.version.to_s }
  s.documentation_url = 'https://chrisdhaan.github.io/CDUntappdKit/'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '4.0'
  s.visionos.deployment_target = '1.0'

  s.swift_versions = ['5']

  s.source_files = 'Source/*.swift'
  s.resource_bundles = { 'CDUntappdKit' => ['Source/PrivacyInfo.xcprivacy'] }

  s.framework = 'Foundation'
  s.ios.framework  = 'UIKit'
  s.osx.framework  = 'Cocoa'
  s.tvos.framework  = 'UIKit'
  s.watchos.framework  = 'UIKit'
  s.visionos.framework  = 'UIKit'

  s.dependency 'Alamofire', '~> 5.9'
end
```

**Key changes from current:**

| Change | Old | New |
|--------|-----|-----|
| Version | 1.0.0 (stale — current is 1.1.0) | 2.0.0 |
| cocoapods_version | absent | >= 1.13.0 (required for PrivacyInfo) |
| deployment targets | iOS 10, macOS 10.12, tvOS 10, watchOS 3 | iOS 12, macOS 10.13, tvOS 12, watchOS 4, visionOS 1 |
| swift_versions | ['5.3', '5.4', '5.5'] | ['5'] |
| resource_bundles | absent | PrivacyInfo.xcprivacy |
| documentation_url | absent | GitHub Pages URL |
| Alamofire dependency | '5.6.1' (exact pin) | '~> 5.9' |
| visionos.deployment_target | absent | '1.0' |
| visionos.framework | absent | 'UIKit' |
| frameworks | UIKit only for iOS/tvOS | Foundation + platform UIKit/Cocoa/UIKit for visionOS |

**Note:** The `documentation_url` points to `https://chrisdhaan.github.io/CDUntappdKit/` which will be populated by Section 12 (Jazzy documentation). Set up GitHub Pages from the `docs/` directory to serve it.

---

## 5. Carthage Removal

Carthage is being removed as a supported installation method and as the CI dependency resolver. Alamofire is available via SPM; CocoaPods users use the podspec dependency.

### 5.1 Files to Delete

- `Cartfile`
- `Cartfile.resolved`
- `.gitmodules` (only references the Alamofire submodule)
- `Carthage/` directory (tracked only as a CI cache; the `Carthage/Build` directory is already gitignored but `Carthage/Checkouts` containing the Alamofire submodule may be partially tracked)

### 5.2 Update .gitignore

**File:** `.gitignore`

Remove or leave the `Carthage/Build` line (it doesn't hurt). Add the following entries that CDMarkdownKit uses:

```gitignore
# Mac OS X
.DS_Store

# Xcode

## Build generated
build/
DerivedData

## Various settings
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata

## Other
*.xccheckout
*.moved-aside
*.xcuserstate
*.xcscmblueprint

## Obj-C/Swift specific
*.hmap
*.ipa

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
.build/

# Bundler
.bundle/

# Jazzy documentation
docs/undocumented.json
```

The `Carthage/Build` entry can be removed since Carthage itself is being removed. The `.bundle/` entry is new (needed for Section 6). The `docs/undocumented.json` entry suppresses Jazzy's machine-path-containing file from the repo.

### 5.3 Remove Carthage from README

Update the README (Section 13) to remove all Carthage installation instructions. The supported installation methods become: Swift Package Manager, CocoaPods, and Git Submodule.

---

## 6. Ruby Toolchain — Gemfile

### 6.1 Add Gemfile

**File:** `Gemfile`

```ruby
source "https://rubygems.org"

gem "cocoapods"
```

This pins the CocoaPods gem for reproducible CI builds. Note: unlike the original 3.0.0 plan, the `jazzy` gem is **not included** — CDMarkdownKit 3.1.0 migrated from Jazzy to DocC, so CDUntappdKit skips Jazzy entirely and goes straight to DocC (Section 12).

### 6.2 Generate Gemfile.lock

After creating the Gemfile, run `bundle lock` locally to generate `Gemfile.lock`. Commit both files. This ensures CI uses exactly the same gem versions as local development.

```bash
bundle lock
```

### 6.3 Add .ruby-version

**File:** `.ruby-version`

```
4.0.3
```

Pins the Ruby version to match the Homebrew-installed Ruby on the CI macOS runners, ensuring consistent gem compilation. Update this value if the runner image changes its default Ruby version.

### 6.4 Add .bundle/ to .gitignore

The `.bundle/` directory contains machine-specific Bundler configuration (SQLite3 build path, cache settings). It must not be committed. This is already included in the updated `.gitignore` from Section 5.2.

**Note on jazzy:** An earlier draft of this plan included `gem "jazzy", "0.15.4"` in the Gemfile. That is removed. CDMarkdownKit 3.1.0 removed Jazzy from its Gemfile when it migrated to DocC. Since no implementation has begun, CDUntappdKit skips Jazzy and adopts DocC directly (Section 12).

---

## 7. Privacy Manifest

Apple requires a privacy manifest for SDKs distributed via the App Store. CDUntappdKit makes network requests (Untappd API) and stores a token in `UserDefaults`. The privacy manifest declares these practices.

### 7.1 Create PrivacyInfo.xcprivacy

**File:** `Source/PrivacyInfo.xcprivacy`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

**Explanation of entries:**
- `NSPrivacyTracking: false` — CDUntappdKit does not track users across apps.
- `NSPrivacyCollectedDataTypes: []` — The SDK itself does not collect data; data collection is the host app's responsibility.
- `NSPrivacyAccessedAPITypes` — Declares `UserDefaults` usage with reason `CA92.1` ("Access info from the same app that wrote it"). The OAuth access token is stored in and read from `UserDefaults` by the same app.

**Note on Keychain migration (future):** The current implementation stores the OAuth access token in `UserDefaults`, which is not ideal for security-sensitive data. A future improvement (beyond the 2.0.0 scope) would migrate to `Keychain`. If that migration happens, update the reason code to the appropriate Keychain API reason instead.

---

## 8. Xcode Project Modernization

### 8.1 Update LastUpgradeCheck and LastUpgradeVersion

**File:** `CDUntappdKit.xcodeproj/project.pbxproj`

Search for `LastUpgradeCheck` and `LastUpgradeVersion`. Update all occurrences from their current value (`1320` or similar) to `2640` (Xcode 16.x compatibility marker).

Also set `BuildIndependentTargetsInParallel = YES` in the project-level build settings to enable parallel target builds.

### 8.2 Update Deployment Targets in Xcode Project

All four platform targets (iOS, macOS, tvOS, watchOS) and any Example app targets must have their deployment targets updated:

| Platform | Old | New |
|----------|-----|-----|
| iOS | 10.0 | 12.0 |
| macOS | 10.12 | 10.13 |
| tvOS | 10.0 | 12.0 |
| watchOS | 3.0 | 4.0 |

Update `IPHONEOS_DEPLOYMENT_TARGET`, `MACOSX_DEPLOYMENT_TARGET`, `TVOS_DEPLOYMENT_TARGET`, and `WATCHOS_DEPLOYMENT_TARGET` in `project.pbxproj`.

### 8.3 Add SwiftLint Build Phase

Add a SwiftLint run script build phase to all four library schemes. The script must:
1. Export Homebrew's bin path so `which swiftlint` resolves correctly.
2. `cd` to `$SRCROOT` so SwiftLint finds lintable source files.
3. Disable `ENABLE_USER_SCRIPT_SANDBOXING` (required for recursive linting).

**Build phase script:**
```bash
export PATH="$PATH:/opt/homebrew/bin"
if which swiftlint > /dev/null; then
    cd "$SRCROOT"
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

In `project.pbxproj`, for each scheme's target, set:
```
ENABLE_USER_SCRIPT_SANDBOXING = NO;
```

### 8.4 Update Copyright Year in All Source Files

Every `.swift` file in `Source/` contains a copyright header of the form:

```swift
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
```

Update all occurrences to `2016-2026`. This is a mechanical find-and-replace across all 34 source files. The easiest approach:

```bash
find Source -name "*.swift" -exec sed -i '' 's/2016-2022/2016-2026/g' {} +
```

Also update any headers in the iOS Example app source files (`iOS Example/Source/`).

### 8.5 Remove Alamofire from Xcode Workspace Framework References

The `CDUntappdKit.xcworkspace` currently references the Carthage-built Alamofire xcframework. After removing Carthage (Section 5), Alamofire must be re-integrated via SPM within Xcode. In Xcode, go to each target's "Frameworks, Libraries, and Embedded Content" and remove any references to `Alamofire.xcframework` from Carthage. Then add the Alamofire SPM package (`https://github.com/Alamofire/Alamofire.git`, upToNextMajor from 5.9.0) through Xcode's "Add Package Dependency" dialog. This matches what Package.swift specifies.

### 8.6 Update Xcode Schemes

Each scheme file under `CDUntappdKit.xcodeproj/xcshareddata/xcschemes/` has a `LastUpgradeVersion` attribute. Update these from their current value to `2640`.

---

## 9. Source Code — Swift 6 Concurrency

These changes prepare all source files for Swift 6 concurrency checking. They do not yet change the public API (that is Section 10).

### 9.1 Enable ExistentialAny and Add Protocol `any` Annotations

With `swift-tools-version:6.0` and `.enableUpcomingFeature("ExistentialAny")` in Package.swift, bare protocol type references in function signatures will produce warnings. Update all existential uses.

**Files likely requiring changes:**
- `CDUntappdRouter.swift` — `URLRequestConvertible` protocol conformance
- `CDUntappdOAuthRouter.swift` — same
- `CDUntappdAPIClient.swift` — any protocol-typed parameters or properties

### 9.2 Add Sendable Conformance to Models

All model structs (`CDUntappdUser`, `CDUntappdBeer`, `CDUntappdBrewery`, etc.) are value types and can trivially conform to `Sendable`. Add `Sendable` to each struct declaration:

```swift
public struct CDUntappdUser: Decodable, Sendable { ... }
```

**Files to update (all 22 model structs):**
`CDUntappdUser.swift`, `CDUntappdBeer.swift`, `CDUntappdBrewery.swift`, `CDUntappdVenue.swift`, `CDUntappdCheckin.swift`, `CDUntappdWishList.swift`, `CDUntappdWishListItem.swift`, `CDUntappdFriend.swift`, `CDUntappdBadge.swift`, `CDUntappdStats.swift`, `CDUntappdMedia.swift`, `CDUntappdRecentBrew.swift`, `CDUntappdCategory.swift`, `CDUntappdContact.swift`, `CDUntappdSource.swift`, `CDUntappdSettings.swift`, `CDUntappdMetadata.swift`, and all three response wrapper types.

Also add `Sendable` to the `CDUntappdUserWishListSortType` enum in `CDUntappdEnums.swift`.

### 9.3 Mark CDUntappdOAuthViewController with @MainActor

`CDUntappdOAuthViewController` is a `UIViewController` subclass and must always run on the main actor. Add `@MainActor` to its class declaration:

```swift
#if os(iOS)
@MainActor
public class CDUntappdOAuthViewController: UIViewController {
```

### 9.4 Mark CDUntappdAPIClient with @MainActor

`CDUntappdAPIClient` manages mutable state (the Alamofire session manager, the OAuth client, and pending request references). Since all callers interact with it from UI code, annotate the class:

```swift
@MainActor
public class CDUntappdAPIClient: NSObject {
```

This enforces that all calls to `CDUntappdAPIClient` happen on the main actor, preventing data races on the internal session and request tracking without requiring locks.

### 9.5 Add @unchecked Sendable to CDUntappdAPIClient and CDUntappdOAuthClient

If CDUntappdAPIClient needs to be shared across actor boundaries (e.g., passed into an actor's initializer), mark it `@unchecked Sendable` while the thread-safety story is being established:

```swift
@MainActor
public class CDUntappdAPIClient: NSObject, @unchecked Sendable {
```

This is a transitional marker; a future clean-up can remove it once the concurrency model is fully verified.

### 9.6 Replace print() Debugging with os.log

The current implementation uses `print()` for error reporting, which is not suitable for a framework:

```swift
print(error?.localizedDescription ?? "Unknown error.")
```

Replace with structured logging using `os.log` (available on all target platforms):

```swift
import os.log

private let logger = Logger(subsystem: "me.christopherdehaan.CDUntappdKit", category: "API")

// Replace:
print(error?.localizedDescription ?? "Unknown error.")
// With:
logger.error("API request failed: \(error?.localizedDescription ?? "Unknown error.")")
```

Add `import os.log` to `CDUntappdAPIClient.swift` and `CDUntappdOAuthClient.swift`. This change is platform-compatible (iOS 12+, macOS 10.13+, tvOS 12+, watchOS 4+) with the new deployment targets.

---

## 10. Async/Await API Migration

This is the most significant source-level change. The completion-handler API is replaced with `async throws` overloads. This is a breaking change that justifies the 2.0.0 major version bump.

**Rationale:** Alamofire 5.5+ provides `async/await` support via `.serializingDecodable()` and `.value`. Using async/await eliminates completion handler nesting, integrates naturally with Swift structured concurrency, and is now the expected API pattern for networking libraries in 2026.

### 10.1 Update CDUntappdAPIClient.swift

**Current pattern (remove):**
```swift
public func fetchUserInfo(forUsername username: String?,
                          compact: Bool,
                          completion: @escaping (CDUntappdUserInfoResponse?) -> Void) {
    guard let manager = self.manager else { return }
    manager.request(CDUntappdRouter.userInfo(parameters: ...))
        .validate()
        .responseDecodable(of: CDUntappdUserInfoResponse.self) { response in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
}
```

**New pattern (add):**
```swift
public func fetchUserInfo(forUsername username: String?,
                          compact: Bool) async throws -> CDUntappdUserInfoResponse {
    guard let manager = self.manager else {
        throw CDUntappdKitError.sessionUnavailable
    }
    return try await manager.request(CDUntappdRouter.userInfo(parameters: ...))
        .validate()
        .serializingDecodable(CDUntappdUserInfoResponse.self)
        .value
}
```

Apply the same pattern to all three implemented endpoints:
- `fetchUserInfo(forUsername:compact:)` → `async throws -> CDUntappdUserInfoResponse`
- `fetchUserWishList(forUsername:offset:limit:sort:)` → `async throws -> CDUntappdUserWishListResponse`
- `fetchUserFriends(forUsername:offset:limit:)` → `async throws -> CDUntappdUserFriendsResponse`

### 10.2 Add CDUntappdKitError

Create `Source/CDUntappdKitError.swift` to replace the nil-on-failure pattern:

```swift
//
//  CDUntappdKitError.swift
//  CDUntappdKit
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
//
//  MIT License
//

import Foundation

/// Errors thrown by CDUntappdKit.
public enum CDUntappdKitError: Error, Sendable {
    /// The Alamofire session manager is not initialized (OAuth not configured).
    case sessionUnavailable
    /// The API returned an error response.
    case apiError(String)
    /// The response could not be decoded.
    case decodingFailed(Error)
}
```

This replaces the current pattern of silently calling `completion(nil)` on errors.

### 10.3 Update CDUntappdOAuthClient.swift

The OAuth flow involves a `WKWebView` redirect (iOS-only) and token storage. The async migration here is simpler since authentication is event-driven:

- Keep `isAuthorized()` as a synchronous computed property — it just reads from `UserDefaults`.
- Make `accessToken()` synchronous — same, it reads from `UserDefaults`.
- The `authorize()` method (which presents `CDUntappdOAuthViewController`) can remain synchronous since it triggers a UI flow, but consider adding an `async` variant that uses a `CheckedContinuation` to suspend until the user completes the OAuth flow:

```swift
public func authorize() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
        // Present CDUntappdOAuthViewController
        // On success: continuation.resume(returning: accessToken)
        // On failure: continuation.resume(throwing: error)
    }
}
```

This is a more advanced change. If it introduces too much complexity, the OAuth flow can remain callback-based for 2.0.0 and be migrated in a future release.

### 10.4 Cancel API Requests

The current `cancelAllPendingAPIRequests()` is synchronous. With async/await, callers use Swift's structured concurrency cancellation (`Task.cancel()`). Deprecate `cancelAllPendingAPIRequests()` or remove it. Document that callers should cancel the `Task` that wraps the async call.

### 10.5 Update iOS Example App

The iOS Example app (`iOS Example/Source/`) uses the completion handler API. Update all call sites to use `async/await` within `Task { }` blocks, following the same pattern CDMarkdownKit used for its example app:

```swift
// Old
untappdAPIClient.fetchUserInfo(forUsername: "DehaanSolo", compact: false) { response in
    // handle response
}

// New
Task { [weak self] in
    do {
        let response = try await self?.untappdAPIClient.fetchUserInfo(forUsername: "DehaanSolo",
                                                                      compact: false)
        // handle response on main actor
    } catch {
        // handle error
    }
}
```

---

## 11. Unit Tests

CDUntappdKit currently has **zero tests**. This section establishes a comprehensive test suite using the Swift Testing framework (available from the same deployment floors as the new targets).

### 11.1 Create Test Directory Structure

```
Tests/
└── CDUntappdKitTests/
    ├── Models/
    │   ├── CDUntappdUserTests.swift
    │   ├── CDUntappdBeerTests.swift
    │   ├── CDUntappdBreweryTests.swift
    │   ├── CDUntappdVenueTests.swift
    │   ├── CDUntappdCheckinTests.swift
    │   └── CDUntappdMetadataTests.swift
    ├── Routing/
    │   ├── CDUntappdRouterTests.swift
    │   └── CDUntappdOAuthRouterTests.swift
    ├── Client/
    │   ├── CDUntappdAPIClientTests.swift
    │   └── CDUntappdOAuthClientTests.swift
    ├── Extensions/
    │   ├── StringExtensionTests.swift
    │   └── ParametersExtensionTests.swift
    ├── Fixtures/
    │   ├── user_info.json
    │   ├── user_wish_list.json
    │   └── user_friends.json
    └── CDUntappdKitTests.swift
```

### 11.2 Test Strategy

Because CDUntappdKit makes real network calls, tests are divided into:

1. **Unit tests (no network):** Model decoding from JSON fixtures, router URL construction, extension methods.
2. **Integration tests (network):** Skipped unless `UNTAPPD_CLIENT_ID` and `UNTAPPD_CLIENT_SECRET` environment variables are set.

All tests use Swift Testing (`import Testing`).

### 11.3 Model Decoding Tests

Each model test verifies:
1. That the model decodes correctly from a fixture JSON file.
2. That optional fields decode as `nil` when absent.
3. That `CodingKeys` mappings are correct.

**Example: `CDUntappdUserTests.swift`**

```swift
import Testing
import Foundation
@testable import CDUntappdKit

@Suite("CDUntappdUser Tests")
@MainActor
struct CDUntappdUserTests {

    let fixtureURL = Bundle.module.url(forResource: "user_info", withExtension: "json")!

    @Test
    func decodesUsernameCorrectly() throws {
        let data = try Data(contentsOf: fixtureURL)
        let response = try JSONDecoder().decode(CDUntappdUserInfoResponse.self, from: data)
        #expect(response.user?.userName == "DehaanSolo")
    }

    @Test
    func decodesStatsCorrectly() throws {
        let data = try Data(contentsOf: fixtureURL)
        let response = try JSONDecoder().decode(CDUntappdUserInfoResponse.self, from: data)
        #expect(response.user?.stats != nil)
    }
}
```

Create JSON fixture files under `Tests/CDUntappdKitTests/Fixtures/` by capturing real Untappd API responses (with personal data anonymized) or constructing minimal valid JSON that matches each model's `CodingKeys`.

### 11.4 Router Tests

Test that the router constructs correct URLs and HTTP methods:

```swift
import Testing
import Foundation
@testable import CDUntappdKit

@Suite("CDUntappdRouter Tests")
struct CDUntappdRouterTests {

    @Test
    func userInfoRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test",
                                          "compact": "false"]
        let request = try CDUntappdRouter.userInfo(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func userInfoRouteContainsUsername() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test",
                                          "compact": "false"]
        let request = try CDUntappdRouter.userInfo(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("userinfo") == true)
    }

    @Test
    func userWishListRouteContainsSortParameter() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test",
                                          "sort": "highest_abv"]
        let request = try CDUntappdRouter.userWishList(parameters: parameters).asURLRequest()
        #expect(request.url?.query?.contains("sort") == true)
    }
}
```

### 11.5 Extension Tests

```swift
@Suite("String Extension Tests")
struct StringExtensionTests {

    @Test
    func pathAppendsCorrectly() {
        let base = "https://example.com/api"
        let result = base.path("v4/user/info/testuser")
        #expect(result == "https://example.com/api/v4/user/info/testuser")
    }

    @Test
    func fromBoolReturnsTrueString() {
        let result = String.fromBool(true)
        #expect(result == "true")
    }

    @Test
    func fromBoolReturnsFalseString() {
        let result = String.fromBool(false)
        #expect(result == "false")
    }
}
```

### 11.6 OAuth Client Tests

Test that `CDUntappdOAuthClient` correctly stores and retrieves tokens from `UserDefaults`:

```swift
@Suite("CDUntappdOAuthClient Tests")
@MainActor
struct CDUntappdOAuthClientTests {

    @Test
    func isNotAuthorizedInitially() {
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                           redirectUrl: "test://callback")
        // Clear any stored state
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        #expect(client.isAuthorized() == false)
    }

    @Test
    func isAuthorizedAfterStoringToken() {
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                           redirectUrl: "test://callback")
        UserDefaults.standard.set("fake_token", forKey: "CDUntappdAccessToken")
        #expect(client.isAuthorized() == true)
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
    }
}
```

### 11.7 Add Test Target to Xcode Project

In addition to the SPM manifest (Section 3), add a `CDUntappdKitTests` target to `CDUntappdKit.xcodeproj`. This allows tests to be run from Xcode's Test navigator in addition to `swift test`. The test target should:
- Depend on the `CDUntappdKit` framework target.
- Include the `Tests/CDUntappdKitTests/` folder.
- Have the same deployment target as the main library target for each platform scheme.

### 11.8 Update CI SPM Job

Once tests exist, change the SPM CI job from:
```yaml
run: set -o pipefail && swift build -c debug 2>&1 | xcbeautify --renderer github-actions
```
to:
```yaml
run: set -o pipefail && swift test -c debug 2>&1 | xcbeautify --renderer github-actions
```

(This is already reflected in the ci.yml in Section 2.2.)

---

## 12. API Documentation — DocC

CDMarkdownKit 3.1.0 migrated from Jazzy to DocC. CDUntappdKit skips Jazzy entirely and adopts DocC directly. Jazzy is **not** added to the Gemfile and `.jazzy.yaml` is **not** created.

### 12.1 Add swift-docc-plugin to Package.swift

This is already included in Section 3.2. The `swift-docc-plugin` dependency enables `swift package generate-documentation` and `swift package preview-documentation` commands without requiring a separate tool installation.

### 12.2 Create DocC Catalog

**Directory to create:** `Source/CDUntappdKit.docc/`

**File:** `Source/CDUntappdKit.docc/CDUntappdKit.md`

```markdown
# ``CDUntappdKit``

A Swift wrapper for the Untappd API. Supports iOS, macOS, tvOS, watchOS, and visionOS.

## Overview

CDUntappdKit handles OAuth 2.0 authentication and authenticated API requests against the
Untappd REST API, decoding responses into strongly-typed Swift model structs.

## Topics

### Getting Started

- <doc:GettingStarted>

### Client

- ``CDUntappdAPIClient``
- ``CDUntappdOAuthClient``

### Errors

- ``CDUntappdKitError``

### Models

- ``CDUntappdUser``
- ``CDUntappdBeer``
- ``CDUntappdBrewery``
- ``CDUntappdVenue``
- ``CDUntappdCheckin``
- ``CDUntappdWishList``
- ``CDUntappdFriend``
- ``CDUntappdBadge``
- ``CDUntappdStats``

### Routing

- ``CDUntappdRouter``
- ``CDUntappdOAuthRouter``

### Enumerations

- ``CDUntappdUserWishListSortType``
```

**File:** `Source/CDUntappdKit.docc/GettingStarted.md`

```markdown
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
        print(response.user?.userName ?? "")
    } catch {
        print(error)
    }
}
```
```

**File:** `Source/CDUntappdKit.docc/Info.plist`

Use the standard DocC catalog Info.plist — Xcode generates this automatically when you add a DocC catalog in the Xcode file navigator. If creating manually:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>CDUntappdKit</string>
    <key>CDDefaultCodeListingLanguage</key>
    <string>swift</string>
</dict>
</plist>
```

### 12.3 Add DocC-Compatible Documentation Comments

Write `///` doc comments on every `public` and `open` declaration in `Source/`. DocC renders these as the symbol reference. Focus on:

- `CDUntappdAPIClient` — class, `init`, each `fetch*` method
- `CDUntappdOAuthClient` — class, `init`, `authenticate()`, `isAuthorized()`, `accessToken()`
- `CDUntappdRouter` — enum cases with parameter descriptions
- All model types — struct declarations and key properties
- `CDUntappdKitError` — enum cases
- Extension methods — `untappdBrown()`, `untappdYellow()`, `path()`, `fromBool()`

**Example:**

```swift
/// The primary API client for interacting with the Untappd API.
///
/// Create one instance per application and hold a strong reference to it.
/// All methods are `@MainActor` — call them from the main thread or from a `Task`.
@MainActor
public class CDUntappdAPIClient: NSObject {

    /// Creates an Untappd API client.
    /// - Parameters:
    ///   - clientId: Your Untappd application client ID.
    ///   - clientSecret: Your Untappd application client secret.
    ///   - redirectUrl: The OAuth redirect URL registered with your application.
    public init(clientId: String, clientSecret: String, redirectUrl: String) { ... }

    /// Fetches user information for the given username.
    /// - Parameters:
    ///   - username: The Untappd username, or `nil` for the authenticated user.
    ///   - compact: Pass `true` to receive a compact response omitting extended fields.
    /// - Returns: The decoded ``CDUntappdUserInfoResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails.
    public func fetchUserInfo(forUsername username: String?,
                              compact: Bool) async throws -> CDUntappdUserInfoResponse { ... }
}
```

DocC supports `- Parameter`, `- Returns`, `- Throws`, and `- Note:` / `- Warning:` callouts. Use double-backtick symbol references (`` ``CDUntappdKitError`` ``) wherever linking to another type.

### 12.4 Generate docs/ (Static Hosting)

Run locally after completing 12.2 and 12.3:

```bash
swift package --disable-sandbox generate-documentation \
  --target CDUntappdKit \
  --output-path docs \
  --transform-for-static-hosting \
  --hosting-base-path CDUntappdKit
```

Commit the generated `docs/` directory. GitHub Pages will serve it at `https://chrisdhaan.github.io/CDUntappdKit/`.

**Note:** DocC static output uses a different URL structure than Jazzy. The podspec `documentation_url` and README links should point to `https://chrisdhaan.github.io/CDUntappdKit/documentation/cduntappdkit/`.

### 12.5 Set Up GitHub Pages

In repository settings on GitHub, configure GitHub Pages to serve from the `docs/` directory on the `master` branch. The `--hosting-base-path CDUntappdKit` flag in the generate command aligns with GitHub Pages' project-page URL scheme (`/<repo-name>/`).

### 12.6 Update .gitignore

The previous Jazzy plan added `docs/undocumented.json` to `.gitignore`. DocC does not produce that file, so that entry can be omitted. However, the `docs/` directory itself contains generated files that **should** be committed (for GitHub Pages) — do not add `docs/` to `.gitignore`.

---

## 13. Documentation Updates

### 13.1 Reformat CHANGELOG.md

Replace the current CHANGELOG format (checkbox-heavy, nested bullets) with the flat semantic versioning format used by CDMarkdownKit 3.0.0:

```markdown
# Change Log
All notable changes to this project will be documented in this file.
`CDUntappdKit` adheres to [Semantic Versioning](https://semver.org/).

## Table of Contents

- [2.0.0](#200)
- [1.1.0](#110)
- [1.0.0](#100)

---

## [2.0.0](https://github.com/chrisdhaan/CDUntappdKit/releases/tag/2.0.0)

Released on 2026-XX-XX.

### Added

- Async/await API overloads for all fetch methods
- Swift 6 concurrency safety: `@MainActor` on `CDUntappdAPIClient` and `CDUntappdOAuthViewController`, `Sendable` on all model types
- Comprehensive unit test suite using Swift Testing framework
- `CDUntappdKitError` enum for typed error propagation (replaces nil-on-failure completion handler pattern)
- Privacy manifest (`PrivacyInfo.xcprivacy`) declaring `UserDefaults` API usage
- API documentation generated by DocC, hosted at https://chrisdhaan.github.io/CDUntappdKit/documentation/cduntappdkit/
- `Documentation/Usage.md` with comprehensive usage examples
- SwiftLint enforcement in CI pipeline
- SwiftFormat enforcement in CI pipeline
- CodeQL security scanning in CI pipeline
- Dynamic library product (`CDUntappdKitDynamic`) in Swift Package Manager manifest
- `CLAUDE.md` for Claude Code project documentation
- `ARCHITECTURE.md` with system design overview
- visionOS 1.0+ platform support

### Updated

- Deployment targets: iOS 12.0+, macOS 10.13+, tvOS 12.0+, watchOS 4.0+
- Swift Package Manager: `swift-tools-version` 5.6 → 6.0, `swiftLanguageModes: [.v5]`, removed versioned Package manifests
- Alamofire dependency: pinned 5.6.1 → upToNextMajor 5.9.0
- CocoaPods: deployment targets, `swift_versions: ['5']`, `cocoapods_version >= 1.13.0`, `resource_bundles` for PrivacyInfo
- CI/CD: macOS-26/macos-15 runners, Xcode 26.1.1–26.4.1 + 16.4, xcbeautify output formatting, GitHub Actions v4, SwiftFormat + DocC build jobs
- README restructured as navigation hub
- Error logging: `print()` replaced with `os.log`
- Copyright year: 2022 → 2026

### Removed

- Completion handler API (replaced by async/await — breaking change)
- Carthage support (use Swift Package Manager or CocoaPods)
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
```

### 13.2 Restructure README.md as Navigation Hub

The current README is verbose with full usage examples inline. Restructure it to be a concise navigation hub (mirroring CDMarkdownKit 3.0.0's README style) with links to `Documentation/Usage.md` for detailed usage.

**Structure:**

```markdown
[logo image]

[badges: CI, GitHub Release, Swift versions, CocoaPods, SPM, License]

An extensive Swift wrapper for the Untappd API.

## Features

[concise feature list — what's implemented, what's planned]

## Requirements

| Platform | Minimum |
|----------|---------|
| iOS | 12.0+ |
| macOS | 10.13+ |
| tvOS | 12.0+ |
| watchOS | 4.0+ |
| Swift | 5.3+ |

## Installation

### Swift Package Manager
[brief SPM instructions]

### CocoaPods
[brief CocoaPods instructions]

### Git Submodule
[brief submodule instructions]

## Quick Start

[single concise initialization example and one fetch example]

## Documentation

For complete usage, see [Documentation/Usage.md](Documentation/Usage.md).
API reference is available at https://chrisdhaan.github.io/CDUntappdKit/

## Author
Christopher de Haan, contact@christopherdehaan.me

## License
MIT
```

**Remove from README:**
- Carthage installation instructions (Carthage support is dropped)
- Full inline usage examples (moved to Usage.md)
- The `[x]` / `[ ]` checkbox feature list (replace with plain bullets)

**Update in README:**
- Swift badge: `5.3_5.4_5.5_5.6` → `5.3+`
- Requirements table: update deployment targets
- All GitHub URLs that reference `chrisdhaan` — verify this is the correct GitHub handle

### 13.3 Create Documentation/Usage.md

**File:** `Documentation/Usage.md`

Create a comprehensive usage guide covering:

1. **Installation** — SPM, CocoaPods, Git Submodule setup with code examples
2. **Initialization** — Creating `CDUntappdAPIClient` with credentials
3. **Authentication** — OAuth flow via `CDUntappdOAuthViewController`, checking `isAuthorized()`
4. **Fetch Methods** — async/await usage for all three implemented endpoints with full example code
5. **Error Handling** — Catching `CDUntappdKitError` cases
6. **Sort Options** — `CDUntappdUserWishListSortType` reference
7. **Brand Assets** — `UIColor.untappdBrown()` and `UIColor.untappdYellow()`
8. **Platform Notes** — watchOS limitations (no `WKWebView`, authentication flow constraints)
9. **Advanced: Cancellation** — How to cancel in-flight requests using Swift `Task` cancellation
10. **Unimplemented Endpoints** — List of all Untappd API endpoints not yet implemented, to guide contributors

### 13.4 Create Migration Guide

**File:** `Documentation/CDUntappdKit 2.0 Migration Guide.md`

Cover the breaking changes developers need to address when upgrading from 1.x to 2.0:

1. **Deployment Targets Raised** — If your app targets iOS < 12, macOS < 10.13, tvOS < 12, or watchOS < 4, you cannot use CDUntappdKit 2.0.
2. **Completion Handlers Replaced** — All `fetch*` methods now use `async throws` instead of completion handlers. All call sites must be updated.
3. **Error Handling** — Errors are now thrown as `CDUntappdKitError` instead of being swallowed (nil completion). Wrap calls in `do-catch`.
4. **Carthage Removed** — Migrate to Swift Package Manager or CocoaPods.
5. **Cancelation Pattern** — `cancelAllPendingAPIRequests()` is removed; use `Task.cancel()` on the task wrapping async calls.
6. **Alamofire Version** — Updated to 5.9+; if your project pins Alamofire separately, ensure no version conflict.

---

## 14. CLAUDE.md & ARCHITECTURE.md

### 14.1 Create CLAUDE.md

**File:** `CLAUDE.md`

Create a project documentation file for Claude Code users. Model it after CDMarkdownKit's CLAUDE.md, adapted for CDUntappdKit:

```markdown
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
```

### 14.2 Create Documentation/ARCHITECTURE.md

**File:** `Documentation/ARCHITECTURE.md`

Document the system design, data flow, and key design decisions:

```markdown
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
```

---

## 15. Version Bump to 2.0.0

This is the final step, performed after all other sections are complete and all CI checks pass.

### 15.1 Files Requiring Version Updates

| File | Change |
|------|--------|
| `CDUntappdKit.podspec` | `s.version = '2.0.0'` (already reflected in Section 4) |
| `Source/CDUntappdKit.swift` | `let version = "2.0.0"` |
| `Source/CDUntappdKit.docc/CDUntappdKit.md` | Update version references if any are hardcoded |
| `README.md` | CocoaPods: `pod 'CDUntappdKit', '2.0.0'`; SPM: `.upToNextMajor(from: "2.0.0")` |
| `CHANGELOG.md` | Fill in release date |

### 15.2 Create Git Tag

```bash
git tag 2.0.0
git push origin 2.0.0
```

### 15.3 Publish to CocoaPods Trunk

After the tag is pushed to GitHub:

```bash
bundle exec pod trunk push CDUntappdKit.podspec --allow-warnings
```

(Requires CocoaPods trunk account. Run `pod trunk register contact@christopherdehaan.me 'Christopher de Haan'` once if not already registered.)

---

## 16. visionOS Support

CDMarkdownKit 3.1.0 added visionOS as a first-class supported platform. CDUntappdKit follows the same pattern. visionOS uses UIKit and supports `WKWebView`, so the API client and OAuth flow are broadly compatible.

### 16.1 Update Package.swift

Already covered in Section 3.2 — `.visionOS(.v1)` is added to the platforms array, `visionOS` is added to the UIKit linker setting `.when(platforms:)`.

### 16.2 Update podspec

Already covered in Section 4 — `s.visionos.deployment_target = '1.0'` and `s.visionos.framework = 'UIKit'`.

### 16.3 Update Source File Platform Guards

Several source files use `#if os(iOS) || os(tvOS) || os(watchOS)` guards for UIKit imports. Add `|| os(visionOS)` to each:

**Files requiring guard updates:**

- `CDColor.swift` — line 30: `#if os(iOS) || os(tvOS) || os(watchOS)` → `#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)`
- `CDUntappdAPIClient.swift` — line 73: `#if os(iOS)` → `#if os(iOS) || os(visionOS)` (guards the `authenticate()` method which uses UIKit)
- `CDUntappdOAuthViewController.swift` — line 28: `#if os(iOS)` → `#if os(iOS) || os(visionOS)` (WKWebView is available on visionOS)
- `UIApplication+CDUntappdKit.swift` — line 28: `#if os(iOS)` → evaluate carefully; `UIApplication.shared.windows` is deprecated in favor of `UIWindowScene` on visionOS. See 16.4.

**Mechanical find-and-replace** (after verifying each file's context):

```bash
find Source -name "*.swift" -exec grep -l "os(iOS) || os(tvOS) || os(watchOS)" {} \; | \
  xargs sed -i '' 's/os(iOS) || os(tvOS) || os(watchOS)/os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)/g'
```

### 16.4 Update UIApplication+CDUntappdKit.swift for visionOS

The current `topViewController()` helper uses `UIApplication.shared.windows.first { $0.isKeyWindow }`, which is deprecated on visionOS in favor of `UIWindowScene`. For 2.0.0, extend the guard to include visionOS but add a visionOS-compatible fallback:

```swift
#if os(iOS) || os(visionOS)
import UIKit

internal extension UIApplication {
    @available(iOSApplicationExtension, unavailable)
    class func topViewController(_ base: UIViewController? = {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow })
        else { return nil }
        return window.rootViewController
    }()) -> UIViewController? {
        // ... existing hierarchy traversal logic
    }
}
#endif
```

This replaces the deprecated `UIApplication.shared.windows` lookup with the modern `UIWindowScene`-based approach, which works correctly on both iOS and visionOS.

### 16.5 Add visionOS Xcode Scheme and Target

In Xcode:
1. Select the project file in the navigator.
2. Add a new target: duplicate the existing iOS target and rename it to `CDUntappdKit visionOS`.
3. Change the destination platform to visionOS in Build Settings.
4. Set `TARGETED_DEVICE_FAMILY` appropriately for visionOS.
5. Create a corresponding shared scheme named `CDUntappdKit visionOS` under `xcshareddata/xcschemes/`.

The CI job in Section 2.2 uses `-scheme "CDUntappdKit visionOS"` — this scheme must exist before CI will pass.

### 16.6 Update CI

Already covered in Section 2.2 — the `visionOS` CI job is defined with 4 `macos-26` matrix entries. No `macos-15` entry since visionOS simulator requires Xcode 26+.

### 16.7 Update Current State Summary

Add a visionOS row to the Current State Summary table at the top of this document after the changes are implemented:

| Area | Current | Target |
|------|---------|--------|
| visionOS deployment target | Not supported | 1.0 |

### 16.8 Update Documentation

- `CLAUDE.md` platform table: already updated in Section 14.1 to include visionOS 1.0.
- `Documentation/ARCHITECTURE.md`: Note that `CDUntappdOAuthViewController` is `#if os(iOS) || os(visionOS)`.
- `Documentation/Usage.md` (Section 13.3): Add visionOS to the Platform Notes section.
- `README.md` requirements table: Add visionOS 1.0+.
- `CHANGELOG.md` Added section: "visionOS 1.0+ platform support".

---

## 17. SwiftFormat

CDMarkdownKit 3.1.0 added SwiftFormat enforcement with a `.swiftformat` config and a CI lint job. CDUntappdKit should follow the same pattern.

### 17.1 Create .swiftformat

**File:** `.swiftformat`

```
# Swift language version target
--swiftversion 5.9

# Indentation: 4 spaces, no tabs
--indent 4
--tabwidth 4
--smarttabs enabled
--indentcase false

# Line length — matches the warning threshold in .swiftlint.yml
--maxwidth 149

# Line endings
--linebreaks lf

# Trailing syntax
--commas always
--semicolons never
--stripunusedargs closure-only

# Argument wrapping (disabled to prevent code expansion)
--wraparguments preserve
--wrapparameters preserve
--wrapcollections preserve

# Import grouping
--importgrouping testable-last

# File headers: leave existing MIT copyright blocks untouched
--header ignore

# Paths to exclude from formatting
--exclude .build,Pods,docs,Package.swift

# Rules disabled to preserve existing codebase conventions
--disable blankLinesAtStartOfScope,blankLinesAtEndOfScope,blankLineAfterImports,blankLinesBetweenScopes,extensionAccessControl,redundantSelf,redundantType,redundantInternal,wrap,wrapMultilineStatementBraces,wrapPropertyBodies
```

This is adapted directly from CDMarkdownKit 3.1.0's `.swiftformat`. The disabled rules preserve the codebase's existing conventions without forcing a sweeping reformatting of every file.

### 17.2 Apply SwiftFormat to Source Files

Before committing `.swiftformat`, run SwiftFormat in apply mode to fix any formatting issues in the existing source:

```bash
brew install swiftformat
swiftformat Source Tests
```

Review the diff to confirm the changes are mechanical (indentation, trailing commas, etc.) and do not alter logic. Commit the formatting changes separately from any logic changes to keep the diff readable.

### 17.3 CI Job

Already added in Section 2.2 — the `swiftformat` CI job runs:

```bash
swiftformat Source Tests --lint
```

`--lint` mode exits non-zero if any file would be changed, without modifying files. This enforces that all committed code passes the formatter.

### 17.4 Update .swiftlint.yml

SwiftLint and SwiftFormat enforce complementary rules. Verify that no rules conflict — specifically, that SwiftLint's `line_length` warning threshold (149) matches SwiftFormat's `--maxwidth 149`. Review after running both tools on the same source.

### 17.5 Developer Workflow

Add a note in `CLAUDE.md` under the Building section:

```bash
# Format source before committing
swiftformat Source Tests
```

This reminder prevents CI failures from the `swiftformat --lint` job catching uncommitted formatting drift.

---

## Appendix A: SwiftLint Configuration Review

The existing `.swiftlint.yml` is well-configured for the codebase. The only change needed is to update the `excluded` list to remove the `Carthage` entry (no longer present after Section 5) and add any new directories:

```yaml
excluded:
  - Example/Resources
  - .build
```

Also consider enabling `strict_fileprivate` and disabling `inclusive_language` may need revisiting for the new codebase with Swift 6. After the migration, run `swiftlint lint --strict` locally and fix any new warnings before committing.

## Appendix B: Alamofire Version Compatibility

CDUntappdKit 2.0.0 targets Alamofire 5.9+. Key `async/await` APIs available in this version range:

| API | Available Since |
|-----|----------------|
| `DataRequest.serializingDecodable(_:)` | Alamofire 5.4 |
| `DataTask<T>.value` | Alamofire 5.4 |
| `Session.request(_:)` async overloads | Alamofire 5.5 |

No code changes are needed in `CDUntappdRouter.swift` — it still implements `URLRequestConvertible`. The Alamofire API for building requests from `URLRequestConvertible` is unchanged.

## Appendix C: Commit Message Convention

Follow the same commit message style used in CDMarkdownKit 3.1.0. Each commit should be prefixed with one of:
- `chore:` — Tooling, configuration, metadata
- `ci:` — CI/CD changes
- `build:` — Package.swift, podspec, deployment targets
- `fix:` — Bug fixes
- `feat:` — New features
- `refactor:` — Code restructuring without behavior change
- `docs:` — Documentation only
- `test:` — Tests only

Example commit sequence:
1. `chore: Replace ISSUE_TEMPLATE.md with directory structure`
2. `chore: Update PULL_REQUEST_TEMPLATE.md format`
3. `chore: Add GitHub funding configuration`
4. `chore: Add Gemfile and Gemfile.lock`
5. `ci: Rewrite ci.yml for modern runners, xcbeautify, SwiftFormat, DocC, visionOS`
6. `build: Update swift-tools-version to 6.0 and swiftLanguageModes`
7. `build: Add dynamic library product to Package.swift`
8. `build: Add swift-docc-plugin dependency to Package.swift`
9. `build: Add PrivacyInfo.xcprivacy privacy manifest`
10. `build: Update deployment targets (iOS 12, macOS 10.13, tvOS 12, watchOS 4, visionOS 1)`
11. `build: Remove versioned Package@swift-X.Y.swift files`
12. `build: Update CocoaPods deployment targets and swift_versions`
13. `build: Add resource_bundles and cocoapods_version constraint to podspec`
14. `chore: Remove Carthage — Cartfile, Cartfile.resolved, .gitmodules`
15. `build: Replace Cartfile Alamofire with SPM in Xcode project`
16. `chore: Update copyright year to 2026`
17. `feat: Add CDUntappdKitError enum`
18. `feat: Migrate API to async/await`
19. `feat: Add Sendable conformance to all model types`
20. `feat: Add @MainActor to CDUntappdAPIClient and CDUntappdOAuthViewController`
21. `fix: Replace print() debugging with os.log`
22. `feat: Add test directory structure`
23. `feat: Implement model decoding tests`
24. `feat: Implement router and extension tests`
25. `docs: Add DocC catalog and documentation comments to public API`
26. `docs: Initialize docs/ directory with DocC static site`
27. `docs: Add Documentation/Usage.md`
28. `docs: Add CDUntappdKit 2.0 Migration Guide`
29. `docs: Restructure README as navigation hub`
30. `docs: Reformat CHANGELOG to semantic versioning standard`
31. `docs: Add CLAUDE.md and ARCHITECTURE.md`
32. `feat: Add visionOS 1.0 platform support`
33. `chore: Add SwiftFormat configuration and apply formatting`
34. `chore: Bump version to 2.0.0`
