//
//  CDUntappdSettings.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/4/17.
//
//  Copyright (c) 2016-2017 Christopher de Haan <contact@christopherdehaan.me>
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

public class CDUntappdSettings: Mappable {

    public var badgesToFacebook: Bool?
    public var badgesToTwitter: Bool?
    public var checkinToFacebook: Bool?
    public var checkinToTwitter: Bool?
    public var checkinToFoursquare: Bool?
    public var defaultToCheckin: Bool?
    public var emailAddress: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        badgesToFacebook    <- map["badge.badges_to_facebook"]
        badgesToTwitter     <- map["badge.badges_to_twitter"]
        checkinToFacebook   <- map["checkin.checkin_to_facebook"]
        checkinToTwitter    <- map["checkin.checkin_to_twitter"]
        checkinToFoursquare <- map["checkin.checkin_to_foursquare"]
        defaultToCheckin    <- map["navigation.default_to_checkin"]
        emailAddress        <- map["email_address"]
    }
}
