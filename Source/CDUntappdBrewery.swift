//
//  CDUntappdBrewery.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
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

#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif

public struct CDUntappdBrewery: Decodable {

    public let id: Int?
    public let name: String?
    public let isActive: Bool?
    public let label: URL?
    public let slug: String?
    public let latitude: Double?
    public let longitude: Double?
    public let city: String?
    public let state: String?
    public let country: String?
    public let facebookUrl: URL?
    public let twitterHandle: String?
    public let instagramHandle: String?
    public let website: URL?

    enum CodingKeys: String, CodingKey {
        case id = "brewery_id"
        case name = "brewery_name"
        case isActive = "brewery_active"
        case label = "brewery_label"
        case slug = "brewery_slug"
        case latitude = "location.lat"
        case longitude = "location.lng"
        case city = "location.brewery_city"
        case state = "location.brewery_state"
        case country = "country_name"
        case facebookUrl = "contact.facebook"
        case twitterHandle = "contact.twitter"
        case instagramHandle = "contact.instagram"
        case website = "contact.url"
    }
}
