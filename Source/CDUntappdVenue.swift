//
//  CDUntappdVenue.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
//
//  Copyright © 2016-2017 Christopher de Haan <contact@christopherdehaan.me>
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

import ObjectMapper

public class CDUntappdVenue: Mappable {

    public var id: Int?
    public var name: String?
    public var isVerified: Bool?
    public var parentCategoryId: String?
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
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id                  <- map["venue_id"]
        name                <- map["venue_name"]
        isVerified          <- map["is_verified"]
        parentCategoryId    <- map["parent_category_id"]
        primaryCategory     <- map["primary_category"]
        categories          <- map["categories.items"]
        smallIcon           <- (map["venue_icon.sm"], URLTransform())
        mediumIcon          <- (map["venue_icon.md"], URLTransform())
        largeIcon           <- (map["venue_icon.lg"], URLTransform())
        slug                <- map["venue_slug"]
        latitude            <- map["location.lat"]
        longitude           <- map["location.lng"]
        address             <- map["location.venue_address"]
        city                <- map["location.venue_city"]
        state               <- map["location.venue_state"]
        country             <- map["location.venue_country"]
        foursqaureId        <- map["foursquare.foursquare_id"]
        foursqaureUrl       <- (map["foursquare.foursquare_url"], URLTransform())
        twitterHandle       <- map["contact.twitter"]
        website             <- (map["contact.venue_url"], URLTransform())
    }
}
