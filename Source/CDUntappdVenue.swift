//
//  CDUntappdVenue.swift
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

/// Represents an Untappd venue (establishment).
public struct CDUntappdVenue: Decodable, Sendable {

    /// The unique venue identifier.
    public var id: Int?
    /// The venue's name.
    public var name: String?
    /// Whether the venue is verified by Untappd.
    public var isVerified: Bool?
    /// The parent category identifier.
    public var parentCategoryId: String?
    /// The venue's primary category.
    public var primaryCategory: String?
    public var categories: [CDUntappdCategory]?
    public var smallIcon: URL?
    public var mediumIcon: URL?
    public var largeIcon: URL?
    public var slug: String?
    public var latitude: Double?
    public var longitude: Double?
    public var address: String?
    public var city: String?
    public var state: String?
    public var country: String?
    public var foursqaureId: String?
    public var foursqaureUrl: URL?
    public var twitterHandle: String?
    public var website: URL?

    private enum RootKeys: String, CodingKey {
        case id = "venue_id"
        case name = "venue_name"
        case isVerified = "is_verified"
        case parentCategoryId = "parent_category_id"
        case primaryCategory = "primary_category"
        case categories
        case venueIcon = "venue_icon"
        case slug = "venue_slug"
        case location
        case foursquare
        case contact
    }

    private enum ItemsKeys: String, CodingKey {
        case items
    }

    private enum IconKeys: String, CodingKey {
        case small = "sm"
        case medium = "md"
        case large = "lg"
    }

    private enum LocationKeys: String, CodingKey {
        case lat
        case lng
        case address = "venue_address"
        case city = "venue_city"
        case state = "venue_state"
        case country = "venue_country"
    }

    private enum FoursquareKeys: String, CodingKey {
        case id = "foursquare_id"
        case url = "foursquare_url"
    }

    private enum ContactKeys: String, CodingKey {
        case twitter
        case url = "venue_url"
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        id = try root.decodeIfPresent(Int.self, forKey: .id)
        name = try root.decodeIfPresent(String.self, forKey: .name)
        isVerified = Self.decodeLenientBool(from: root, forKey: .isVerified)
        parentCategoryId = try root.decodeIfPresent(String.self, forKey: .parentCategoryId)
        primaryCategory = try root.decodeIfPresent(String.self, forKey: .primaryCategory)
        slug = try root.decodeIfPresent(String.self, forKey: .slug)

        if let categoriesContainer = try? root.nestedContainer(keyedBy: ItemsKeys.self, forKey: .categories) {
            categories = try categoriesContainer.decodeIfPresent([CDUntappdCategory].self, forKey: .items)
        } else {
            categories = nil
        }

        if let iconContainer = try? root.nestedContainer(keyedBy: IconKeys.self, forKey: .venueIcon) {
            smallIcon = try iconContainer.decodeIfPresent(URL.self, forKey: .small)
            mediumIcon = try iconContainer.decodeIfPresent(URL.self, forKey: .medium)
            largeIcon = try iconContainer.decodeIfPresent(URL.self, forKey: .large)
        } else {
            smallIcon = nil
            mediumIcon = nil
            largeIcon = nil
        }

        if let locationContainer = try? root.nestedContainer(keyedBy: LocationKeys.self, forKey: .location) {
            latitude = try locationContainer.decodeIfPresent(Double.self, forKey: .lat)
            longitude = try locationContainer.decodeIfPresent(Double.self, forKey: .lng)
            address = try locationContainer.decodeIfPresent(String.self, forKey: .address)
            city = try locationContainer.decodeIfPresent(String.self, forKey: .city)
            state = try locationContainer.decodeIfPresent(String.self, forKey: .state)
            country = try locationContainer.decodeIfPresent(String.self, forKey: .country)
        } else {
            latitude = nil
            longitude = nil
            address = nil
            city = nil
            state = nil
            country = nil
        }

        if let foursquareContainer = try? root.nestedContainer(keyedBy: FoursquareKeys.self, forKey: .foursquare) {
            foursqaureId = try foursquareContainer.decodeIfPresent(String.self, forKey: .id)
            foursqaureUrl = try foursquareContainer.decodeIfPresent(URL.self, forKey: .url)
        } else {
            foursqaureId = nil
            foursqaureUrl = nil
        }

        if let contactContainer = try? root.nestedContainer(keyedBy: ContactKeys.self, forKey: .contact) {
            twitterHandle = try contactContainer.decodeIfPresent(String.self, forKey: .twitter)
            website = try contactContainer.decodeIfPresent(URL.self, forKey: .url)
        } else {
            twitterHandle = nil
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
