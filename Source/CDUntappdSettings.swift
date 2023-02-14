//
//  CDUntappdSettings.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/4/17.
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

public struct CDUntappdSettings: Decodable {

    public let badgesToFacebook: Bool?
    public let badgesToTwitter: Bool?
    public let checkinToFacebook: Bool?
    public let checkinToTwitter: Bool?
    public let checkinToFoursquare: Bool?
    public let defaultToCheckin: Bool?
    public let emailAddress: String?

    enum CodingKeys: String, CodingKey {
        case badgesToFacebook = "badge.badges_to_facebook"
        case badgesToTwitter = "badge.badges_to_twitter"
        case checkinToFacebook = "checkin.checkin_to_facebook"
        case checkinToTwitter = "checkin.checkin_to_twitter"
        case checkinToFoursquare = "checkin.checkin_to_foursquare"
        case defaultToCheckin = "navigation.default_to_checkin"
        case emailAddress = "email_address"
    }
}
