//
//  CDUntappdBeer.swift
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

/// Represents an Untappd beer.
public struct CDUntappdBeer: Decodable, Sendable {

    /// The unique beer identifier.
    public var id: Int?
    /// The beer's name.
    public var name: String?
    /// The beer's description.
    public var description: String?
    /// The beer's style category.
    public var style: String?
    /// The beer's alcohol by volume percentage.
    public var abv: Double?
    /// The beer's International Bitterness Units value.
    public var ibu: Double?
    public var rating: Double?
    public var overallRating: Double?
    public var totalRatings: Int?
    public var label: URL?
    public var isInProduction: Bool?
    public var hasHad: Bool?
    public var isOnWishList: Bool?
    public var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "bid"
        case name = "beer_name"
        case description = "beer_description"
        case style = "beer_style"
        case abv = "beer_abv"
        case ibu = "beer_ibu"
        case rating = "auth_rating"
        case overallRating = "rating_score"
        case totalRatings = "rating_count"
        case label = "beer_label"
        case isInProduction = "is_in_production"
        case hasHad = "has_had"
        case isOnWishList = "wish_list"
        case createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        style = try container.decodeIfPresent(String.self, forKey: .style)
        abv = try container.decodeIfPresent(Double.self, forKey: .abv)
        ibu = try container.decodeIfPresent(Double.self, forKey: .ibu)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        overallRating = try container.decodeIfPresent(Double.self, forKey: .overallRating)
        totalRatings = try container.decodeIfPresent(Int.self, forKey: .totalRatings)
        label = try container.decodeIfPresent(URL.self, forKey: .label)
        hasHad = try container.decodeIfPresent(Bool.self, forKey: .hasHad)
        isOnWishList = try container.decodeIfPresent(Bool.self, forKey: .isOnWishList)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        isInProduction = Self.decodeLenientBool(from: container, forKey: .isInProduction)
    }

    /// Untappd returns this flag as either a JSON boolean or a `1`/`0` integer
    /// depending on endpoint; decode leniently rather than throwing on the integer form.
    private static func decodeLenientBool(from container: KeyedDecodingContainer<CodingKeys>,
                                          forKey key: CodingKeys) -> Bool? {
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return intValue == 1
        }
        return (try? container.decodeIfPresent(Bool.self, forKey: key)) ?? nil
    }
}
