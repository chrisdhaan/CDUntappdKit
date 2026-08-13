//
//  CDUntappdSettings.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/4/17.
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

public struct CDUntappdSettings: Decodable, Sendable {

    public var badgesToFacebook: Bool?
    public var badgesToTwitter: Bool?
    public var checkinToFacebook: Bool?
    public var checkinToTwitter: Bool?
    public var checkinToFoursquare: Bool?
    public var defaultToCheckin: Bool?
    public var emailAddress: String?

    private enum RootKeys: String, CodingKey {
        case badge
        case checkin
        case navigation
        case emailAddress = "email_address"
    }

    private enum BadgeKeys: String, CodingKey {
        case badgesToFacebook = "badges_to_facebook"
        case badgesToTwitter = "badges_to_twitter"
    }

    private enum CheckinKeys: String, CodingKey {
        case checkinToFacebook = "checkin_to_facebook"
        case checkinToTwitter = "checkin_to_twitter"
        case checkinToFoursquare = "checkin_to_foursquare"
    }

    private enum NavigationKeys: String, CodingKey {
        case defaultToCheckin = "default_to_checkin"
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        emailAddress = try root.decodeIfPresent(String.self, forKey: .emailAddress)

        if let badgeContainer = try? root.nestedContainer(keyedBy: BadgeKeys.self, forKey: .badge) {
            badgesToFacebook = try badgeContainer.decodeIfPresent(Bool.self, forKey: .badgesToFacebook)
            badgesToTwitter = try badgeContainer.decodeIfPresent(Bool.self, forKey: .badgesToTwitter)
        } else {
            badgesToFacebook = nil
            badgesToTwitter = nil
        }

        if let checkinContainer = try? root.nestedContainer(keyedBy: CheckinKeys.self, forKey: .checkin) {
            checkinToFacebook = try checkinContainer.decodeIfPresent(Bool.self, forKey: .checkinToFacebook)
            checkinToTwitter = try checkinContainer.decodeIfPresent(Bool.self, forKey: .checkinToTwitter)
            checkinToFoursquare = try checkinContainer.decodeIfPresent(Bool.self, forKey: .checkinToFoursquare)
        } else {
            checkinToFacebook = nil
            checkinToTwitter = nil
            checkinToFoursquare = nil
        }

        if let navigationContainer = try? root.nestedContainer(keyedBy: NavigationKeys.self, forKey: .navigation) {
            defaultToCheckin = try navigationContainer.decodeIfPresent(Bool.self, forKey: .defaultToCheckin)
        } else {
            defaultToCheckin = nil
        }
    }
}
