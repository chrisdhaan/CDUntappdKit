# CDUntappdKit

[![CI Status](http://img.shields.io/travis/chrisdhaan/CDUntappdKit.svg?style=flat)](https://travis-ci.org/chrisdhaan/CDUntappdKit)
[![Version](https://img.shields.io/cocoapods/v/CDUntappdKit.svg?style=flat)](http://cocoapods.org/pods/CDUntappdKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/CDUntappdKit.svg?style=flat)](http://cocoapods.org/pods/CDUntappdKit)
[![Platform](https://img.shields.io/cocoapods/p/CDUntappdKit.svg?style=flat)](http://cocoapods.org/pods/CDUntappdKit)

This Swift wrapper covers all possible network endpoints and responses for the Untappd Developers API.

For a demonstration of the capabilities of CDUntappdKit; run the iOS Example project after cloning the repo.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Resources](#resources)
- [License](#license)

---

## Pre-Release Software

This framework is currently in development. As of release 0.9.0 the code is stable and in a usable state to install in applications. But be aware that breaking changes may occur until 1.0.0 is released.

---

## Features

- [x] Authentication
- [ ] API Endpoints
  - [ ] Activity Feed
  - [ ] User Activity Feed
  - [ ] The Pub (Local)
  - [ ] Venue Activity Feed
  - [ ] Beer Activity Feed
  - [ ] Brewery Activity Feed
  - [ ] Notifications
  - [ ] User Info
  - [ ] User Wish List
  - [ ] User Friends
  - [ ] User Badges
  - [ ] User Beers
  - [ ] Brewery Info
  - [ ] Beer Info
  - [ ] Venue Info
  - [ ] Beer Search
  - [ ] Brewery Search
  - [ ] Checkin
  - [ ] Toast/Un-toast
  - [ ] Pending Friends
  - [ ] Add Friend
  - [ ] Remove Friend
  - [ ] Accept Friend
  - [ ] Reject Friend
  - [ ] Add Comment
  - [ ] Remove Comment
  - [ ] Add to Wish List
  - [ ] Remove from Wish List
  - [ ] Foursquare Lookup
- [ ] Documentation

---

## Requirements

- iOS 8.0+
- Xcode 8.1+
- Swift 3.0+

---

## Dependencies

- [AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)

---

## Installation

### Installation via CocoaPods

CDUntappdKit is available through [CocoaPods](http://cocoapods.org). CocoaPods is a dependency manager that automates and simplifies the process of using 3rd-party libraries like CDUntappdKit in your projects. You can install CocoaPods with the following command:

```ruby
gem install cocoapods
```

To integrate CDUntappdKit into your Xcode project using CocoaPods, simply add the following line to your Podfile:

```ruby
# use this line to install CDUntappdKit while in development
pod "CDUntappdKit", :git => "https://github.com/chrisdhaan/CDUntappdKit"
# this line will eventually be used upon the 1.0.0 release of CDUntappdKit and can be disregarded for now
pod "CDUntappdKit" "~> 1.0.0"
```

Afterwards, run the following command:

```ruby
pod install
```

### Installation via Carthage

CDUntappdKit is available through [Carthage](https://github.com/Carthage/Carthage). Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage via [Homebrew](http://brew.sh) with the following commands:

```ruby
brew update
brew install carthage
```

To integrate CDUntappdKit into your Xcode project using Carthage, simply add the following line to your Cartfile:

```ruby
# use this line to install CDUntappdKit while in development
github "chrisdhaan/CDUntappdKit"
# this line will eventually be used upon the 1.0.0 release of CDUntappdKit and can be disregarded for now
github "chrisdhaan/CDUntappdKit" ~> 1.0.0
```

Afterwards, run the following command:

```ruby
carthage update
```

Next, add the built CDUntappdKit.framework into your Xcode project.

### Installation via Swift Package Manager

CDUntappdKit is available through the [Swift Package Manager](https://swift.org/package-manager). The Swift Package Manager is a tool for automating the distribution of Swift code.

The Swift Package Manager is in early development, but CDUntappdKit does support its use on supported platforms. Until the Swift Package Manager supports non-host platforms, it is recommended to use CocoaPods, Carthage, or Git Submodules to build iOS, watchOS, and tvOS apps.

The Swift Package Manager is integrated into the Swift compiler.

To integrate CDUntappdKit into your Xcode project using The Swift Package Manager, simply add the following line to your Package.swift file:

```swift
dependencies: [
    .Package(url: "https://github.com/chrisdhaan/CDUntappdKit.git", majorVersion: 1)
]
```

Afterwards, run the following command:

```ruby
swift package fetch
```

### Installation via Git Submodule

CDUntappdKit is available through [Git Submodule](https://git-scm.com/docs/git-submodule) Git Submodule allows you to keep another Git repository in a subdirectory of your repository.

If your project is not initialized as a git repository, navigate into your top-level project directory, and install Git Submodule with the following command:

```git
git init
```

To integrate CDUntappdKit into your Xcode project using Git Submodule, simply run the following command:

```git
git submodule add https://github.com/chrisdhaan/CDUntappdKit.git
```

Afterwards, open the new **CDUntappdKit** folder, and drag the **CDUntappdKit.xcodeproj** into the **Project Navigator** of your Xcode project. A common location for the **CDUntappdKit.xcodeproj** is directly below the **Products** folder.

Next, select your application project in the **Project Navigator** to navigate to the target configuration window and select the application target under the **Targets** heading in the sidebar. In the tab bar at the top of that window, open the **General** panel. Click on the **+** button under the **Embedded Binaries** section. You will see two different CDUntappdKit.xcodeproj folders, each with a version of the CDUntappdKit.framework nested inside a Products folder. It does not matter which Products folder you choose from, select the CDUntappdKit.framework for iOS.

---

## Usage

---

## Author

Christopher de Haan, contact@christopherdehaan.me

## Resources

Visit the [Untappd Developers](https://untappd.com/api/docs) portal for additional resources regarding the Untappd API.

## License

CDUntappdKit is available under the MIT license. See the LICENSE file for more info.

---
