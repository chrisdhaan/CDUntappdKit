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
    <a href="https://github.com/chrisdhaan/CDUntappdKit/actions/workflows/ci.yml">
        <img src="https://github.com/chrisdhaan/CDUntappdKit/actions/workflows/ci.yml/badge.svg" alt="CI Status">
    </a>
    <a href="https://github.com/chrisdhaan/CDUntappdKit/releases">
        <img src="https://img.shields.io/github/release/chrisdhaan/CDUntappdKit.svg" alt="GitHub Release">
    </a>
    <a href="https://www.swift.org">
        <img src="https://img.shields.io/badge/Swift-5.3_5.4_5.5_5.6-orange?style=flat" alt="Swift Versions">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/p/CDUntappdKit.svg?style=flat" alt="Platforms">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/v/CDUntappdKit.svg?style=flat" alt="CocoaPods Compatible">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible">
    </a>
    <a href="https://www.swift.org/package-manager">
        <img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat" alt="Swift Package Manager Compatible">
    </a>
    <a href="http://cocoapods.org/pods/CDUntappdKit">
        <img src="https://img.shields.io/cocoapods/l/CDUntappdKit.svg?style=flat" alt="License">
    </a>
</p>

<br>

This Swift wrapper covers all possible network endpoints and responses for the Untappd API.

For a demonstration of the capabilities of CDUntappdKit; run the iOS Example project after cloning the repo.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Contributing](#contributing)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [User Info Endpoint](#user-info-endpoint)
    - [User Wish List Endpoint](#user-wish-list-endpoint)
    - [User Friends Endpoint](#user-friends-endpoint)
    - [Brand Assets](#brand-assets)
- [Author](#author)
- [Resources](#resources)
- [License](#license)

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

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Swift 5.3+

---

## Dependencies

- [Alamofire](https://github.com/Alamofire/Alamofire)

---

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate CDUntappdKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'CDUntappdKit', '1.1.1'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate CDUntappdKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "chrisdhaan/CDUntappdKit" == 1.1.1
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding CDUntappdKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/chrisdhaan/CDUntappdKit.git", .upToNextMajor(from: "1.1.1"))
]
```

### Git Submodule

If you prefer not to use any of the aforementioned dependency managers, you can integrate CDUntappdKit into your project manually.

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add CDUntappdKit as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

```git
git submodule add https://github.com/chrisdhaan/CDUntappdKit.git
```

- Open the new `CDUntappdKit` folder, and drag the `CDUntappdKit.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `CDUntappdKit.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `CDUntappdKit.xcodeproj` folders each with two different versions of the `CDUntappdKit.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `CDUntappdKit.framework`.

- Select the top `CDUntappdKit.framework` for iOS and the bottom one for macOS.

    > You can verify which one you selected by inspecting the build log for your project. The build target for `CDUntappdKit` will be listed as either `CDUntappdKit iOS`, `CDUntappdKit macOS`, `CDUntappdKit tvOS` or `CDUntappdKit watchOS`.

- And that's it!

  > The `CDUntappdKit.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

---

## Contributing

Before contributing to CDUntappdKit, please read the instructions detailed in our [contribution guide](https://github.com/chrisdhaan/CDUntappdKit/blob/master/CONTRIBUTING.md).

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

---

## Resources

Visit the [Untappd Developers](https://untappd.com/api/docs) portal for additional resources regarding the Untappd API.

---

## License

CDUntappdKit is available under the MIT license. See the LICENSE file for more info.

---
