//
//  CDUntappdBrewery.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
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

import Foundation

/// Represents an Untappd brewery.
public struct CDUntappdBrewery: Decodable, Sendable {

    /// The unique brewery identifier.
    public var id: Int?
    /// The brewery's name.
    public var name: String?
    /// Whether the brewery is currently active.
    public var isActive: Bool?
    /// The brewery's logo image URL.
    public var label: URL?
    /// The brewery's URL-friendly slug.
    public var slug: String?
    public var latitude: Double?
    public var longitude: Double?
    public var city: String?
    public var state: String?
    public var country: String?
    public var facebookUrl: URL?
    public var twitterHandle: String?
    public var instagramHandle: String?
    public var website: URL?

    private enum RootKeys: String, CodingKey {
        case id = "brewery_id"
        case name = "brewery_name"
        case isActive = "brewery_active"
        case label = "brewery_label"
        case slug = "brewery_slug"
        case location
        case country = "country_name"
        case contact
    }

    private enum LocationKeys: String, CodingKey {
        case lat
        case lng
        case city = "brewery_city"
        case state = "brewery_state"
    }

    private enum ContactKeys: String, CodingKey {
        case facebook
        case twitter
        case instagram
        case url
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        id = try root.decodeIfPresent(Int.self, forKey: .id)
        name = try root.decodeIfPresent(String.self, forKey: .name)
        isActive = Self.decodeLenientBool(from: root, forKey: .isActive)
        label = try root.decodeIfPresent(URL.self, forKey: .label)
        slug = try root.decodeIfPresent(String.self, forKey: .slug)
        country = try root.decodeIfPresent(String.self, forKey: .country)

        if let locationContainer = try? root.nestedContainer(keyedBy: LocationKeys.self, forKey: .location) {
            latitude = try locationContainer.decodeIfPresent(Double.self, forKey: .lat)
            longitude = try locationContainer.decodeIfPresent(Double.self, forKey: .lng)
            city = try locationContainer.decodeIfPresent(String.self, forKey: .city)
            state = try locationContainer.decodeIfPresent(String.self, forKey: .state)
        } else {
            latitude = nil
            longitude = nil
            city = nil
            state = nil
        }

        if let contactContainer = try? root.nestedContainer(keyedBy: ContactKeys.self, forKey: .contact) {
            facebookUrl = try contactContainer.decodeIfPresent(URL.self, forKey: .facebook)
            twitterHandle = try contactContainer.decodeIfPresent(String.self, forKey: .twitter)
            instagramHandle = try contactContainer.decodeIfPresent(String.self, forKey: .instagram)
            website = try contactContainer.decodeIfPresent(URL.self, forKey: .url)
        } else {
            facebookUrl = nil
            twitterHandle = nil
            instagramHandle = nil
            website = nil
        }
    }

    /// Untappd returns this flag as either a JSON boolean or a `1`/`0` integer
    /// depending on endpoint; decode leniently rather than throwing on the integer form.
    private static func decodeLenientBool(from container: KeyedDecodingContainer<RootKeys>,
                                          forKey key: RootKeys) -> Bool? {
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return intValue == 1
        }
        return (try? container.decodeIfPresent(Bool.self, forKey: key)) ?? nil
    }
}
