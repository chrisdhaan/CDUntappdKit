<p align="center">
    <a href="https://github.com/chrisdhaan/CDUntappdKit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDUntappdKit/master/Documentation/cduntappdkit.png" alt="CDUntappdKit" width="850" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/chrisdhaan/CDUntappdKit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDUntappdKit/master/Documentation/github.png" alt="Star CDUntappdKit On Github" />
    </a>
    <a href="http://stackoverflow.com/questions/tagged/cduntappdkit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDUntappdKit/master/Documentation/stackoverflow.png" alt="Stack Overflow" />
    </a>
</p>

<p align="center">
    <a href="https://travis-ci.org/chrisdhaan/CDUntappdKit">
        <img src="http://img.shields.io/travis/chrisdhaan/CDUntappdKit.svg?style=flat" alt="CI Status">
    </a>
    <a href="https://github.com/chrisdhaan/CDUntappdKit/releases">
        <img src="https://img.shields.io/github/release/chrisdhaan/CDUntappdKit.svg" alt="GitHub Release">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/v/CDUntappdKit.svg?style=flat" alt="Version">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/p/CDUntappdKit.svg?style=flat" alt="Platform">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/l/CDUntappdKit.svg?style=flat" alt="License">
    </a>
</p>

<br>

This Swift wrapper covers all possible network endpoints and responses for the Untappd Developers API.

For a demonstration of the capabilities of CDUntappdKit; run the iOS Example project after cloning the repo.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [User Info Endpoint](#user-info-endpoint)
    - [User Wish List Endpoint](#user-wish-list-endpoint)
    - [User Friends Endpoint](#user-friends-endpoint)
    - [Brand Assets](#brand-assets)
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
    - [x] User Info
    - [x] User Wish List
    - [x] User Friends
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
- [ ] Brand Assets
    - [x] Colors
    - [ ] Logo
- [x] Platform Support
    - [x] iOS
    - [x] macOS
    - [x] tvOS
- [x] watchOS
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
pod 'CDUntappdKit', '1.0.0'
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
github "chrisdhaan/CDUntappdKit" == 1.0.0
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
    .Package(url: "https://github.com/chrisdhaan/CDUntappdKit.git", "1.0.0")
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

### Initialization

```swift
let untappdAPIClient = CDUntappdAPIClient(clientId: "YOUR_CLIENT_ID",
                                          clientSecret: "YOUR_CLIENT_SECRET",
                                          redirectUrl: "YOUR_REDIRECT_URL")
```

Once you've created a CDUntappdAPIClient object you can use it to query the Untappd API using any of the following methods.

- Parameters with `// Optional` can take nil as a value.
- Parameters with `// Required` will throw an exception when passing nil as a value.

### [User Info Endpoint](https://untappd.com/api/docs#userinfo)

```swift
public func fetchUserInfo(forUsername username: String?, // Optional
                          compact: Bool,                 // Required
                          completion: @escaping (CDUntappdUserInfoResponse?) -> Void)
```

The following lines of code show an example query to the user info endpoint.

```swift
// Cancel any API requests previously made
untappdAPIClient.cancelAllPendingAPIRequests()
// Query Untappd API for user info results
untappdAPIClient.fetchUserInfo(forUsername: "DehaanSolo",
                               compact: false) { (response) in
                               
  if let response = response,
      let user = response.user {
      print(user)
  }
}
```

### [User Wish List Endpoint](https://untappd.com/api/docs#userwishlist)

```swift
public func fetchUserWishList(forUsername username: String?,
                              offset: Int?,
                              limit: Int?,
                              sort: CDUntappdUserWishListSortType?,
                              completion: @escaping (CDUntappdUserWishListResponse?) -> Void)
```

The user wish list endpoint has a `sort` parameter which allows for query results to be filtered based off six types of criteria. The following lines of code show which sort types can be passed into the `sort` parameter.

```swift
CDUntappdUserWishListSortType.checkin
CDUntappdUserWishListSortType.date
CDUntappdUserWishListSortType.highestABV
CDUntappdUserWishListSortType.highestRated
CDUntappdUserWishListSortType.lowestABV
CDUntappdUserWishListSortType.lowestRated
```

The following lines of code show an example query to the user wish list endpoint.

```swift
untappdAPIClient.fetchUserWishList(forUsername: "DehaanSolo",
                                   offset: 0,
                                   limit: 10,
                                   sort: .highestABV) { (response) in
                                   
  if let response = response,
      let wishList = response.wishList {
      print(wishList)
  }
}
```

### [User Friends Endpoint](https://untappd.com/api/docs#userfriends)

```swift
public func fetchUserFriends(forUsername username: String?,
                             offset: Int?,
                             limit: Int?,
                             completion: @escaping (CDUntappdUserFriendsResponse?) -> Void)
```

The following lines of code show an example query to the user friends endpoint.

```swift
untappdAPIClient.fetchUserFriends(forUsername: "DehaanSolo",
                                  offset: 0,
                                  limit: 10) { (response) in
                                  
  if let response = response,
      let friends = response.friends {
      print(friends)
  }
}
```

### Brand Assets

The Untappd brand guidelines exist to achieve consistency and make sure the branded elements of Untappd are used correctly across every application.

### Color

```swift
class func untappdBrown() -> UIColor
class func untappdYellow() -> UIColor
```

The following lines of code show an example of how to use the brand color.

```swift
cell.textLabel?.textColor = UIColor.untappdBrown()
cell.textLabel?.textColor = UIColor.untappdYellow()
```

---

## Author

Christopher de Haan, contact@christopherdehaan.me

## Resources

Visit the [Untappd Developers](https://untappd.com/api/docs) portal for additional resources regarding the Untappd API.

## License

CDUntappdKit is available under the MIT license. See the LICENSE file for more info.

---
