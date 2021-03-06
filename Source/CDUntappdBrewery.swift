//
//  CDUntappdBrewery.swift
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

public class CDUntappdBrewery: Mappable {

    public var id: Int?
    public var name: String?
    public var isActive: Bool?
    public var label: URL?
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
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id              <- map["brewery_id"]
        name            <- map["brewery_name"]
        isActive        <- map["brewery_active"]
        label           <- (map["brewery_label"], URLTransform())
        slug            <- map["brewery_slug"]
        latitude        <- map["location.lat"]
        longitude       <- map["location.lng"]
        city            <- map["location.brewery_city"]
        state           <- map["location.brewery_state"]
        country         <- map["country_name"]
        facebookUrl     <- (map["contact.facebook"], URLTransform())
        twitterHandle   <- map["contact.twitter"]
        instagramHandle <- map["contact.instagram"]
        website         <- (map["contact.url"], URLTransform())
    }
}
