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
