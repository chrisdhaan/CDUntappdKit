//
//  CDUntappdBeer.swift
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

public class CDUntappdBeer: Mappable {

    public var id: Int?
    public var name: String?
    public var description: String?
    public var style: String?
    public var abv: Double?
    public var ibu: Double?
    public var rating: Double?
    public var overallRating: Double?
    public var totalRatings: Int?
    public var label: URL?
    public var isInProduction: Bool?
    public var hasHad: Bool?
    public var isOnWishList: Bool?
    public var createdAt: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id              <- map["bid"]
        name            <- map["beer_name"]
        description     <- map["beer_description"]
        style           <- map["beer_style"]
        abv             <- map["beer_abv"]
        ibu             <- map["beer_ibu"]
        rating          <- map["auth_rating"]
        overallRating   <- map["rating_score"]
        totalRatings    <- map["rating_count"]
        label           <- (map["beer_label"], URLTransform())
        isInProduction  <- map["is_in_production"]
        hasHad          <- map["has_had"]
        isOnWishList    <- map["wish_list"]
        createdAt       <- map["created_at"]
    }
}
