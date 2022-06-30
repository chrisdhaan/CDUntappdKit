//
//  CDUntappdUser.swift
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

#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif

public struct CDUntappdUser: Decodable {

    public var id: Int?
    public var uid: Int?
    public var username: String?
    public var firstName: String?
    public var lastName: String?
    public var userAvatar: URL?
    public var userAvatatHd: URL?
    public var userCoverPhoto: URL?
    public var userCoverPhotoOffset: Int?
    public var location: String?
    public var bio: String?
    public var website: URL?
    public var untappdUrl: URL?
    public var isPrivate: Bool?
    public var isModerator: Bool?
    public var isSupporter: Bool?
    public var relationship: String?
    public var accountType: String?
    public var blockStatus: String?
    public var stats: CDUntappdStats?
    public var checkins: [CDUntappdCheckin]?
    public var recentBrews: [CDUntappdRecentBrew]?
    public var media: [CDUntappdMedia]?
    public var contact: CDUntappdContact?
    public var dateJoined: String?
    public var settings: CDUntappdSettings?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case uid = "uid"
        case username = "user_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case userAvatar = "user_avatar"
        case userAvatatHd = "user_avatar_hd"
        case userCoverPhoto = "user_cover_photo"
        case userCoverPhotoOffset = "user_cover_photo_offset"
        case location = "location"
        case bio = "bio"
        case website = "url"
        case untappdUrl = "untappd_url"
        case isPrivate = "is_private"
        case isModerator = "is_moderator"
        case isSupporter = "is_supporter"
        case relationship = "relationship"
        case accountType = "account_type"
        case blockStatus = "block_status"
        case stats = "stats"
        case checkins = "checkins.items"
        case recentBrews = "recent_brews.items"
        case media = "media"
        case contact = "contact"
        case dateJoined = "date_joined"
        case settings = "settings"
    }
}
