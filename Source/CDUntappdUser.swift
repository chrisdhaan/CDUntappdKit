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

    public let id: Int?
    public let uid: Int?
    public let username: String?
    public let firstName: String?
    public let lastName: String?
    public let userAvatar: String?
    public let userAvatarHd: String?
    public let userCoverPhoto: String?
    public let userCoverPhotoOffset: Int?
    public let isPrivate: Int?
    public let location: String?
    public let website: String?
    public let bio: String?
    public let isSupporter: Int?
    public let relationship: String?
    public let untappd: String?
    public let accountType: String?
//    public let isModerator: Int?
//    public let blockStatus: String?
//    public let stats: CDUntappdStats?
//    public let checkins: [CDUntappdCheckin]?
//    public let recentBrews: [CDUntappdRecentBrew]?
//    public let media: [CDUntappdMedia]?
//    public let contact: CDUntappdContact?
//    public let dateJoined: String?
//    public let settings: CDUntappdSettings?

    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case username = "user_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case userAvatar = "user_avatar"
        case userAvatarHd = "user_avatar_hd"
        case userCoverPhoto = "user_cover_photo"
        case userCoverPhotoOffset = "user_cover_photo_offset"
        case isPrivate = "is_private"
        case location
        case website = "url"
        case bio
        case isSupporter = "is_supporter"
        case relationship
        case untappd = "untappd_url"
        case accountType = "account_type"
//        case isModerator = "is_moderator"
//        case blockStatus = "block_status"
//        case stats
//        case checkins = "checkins.items"
//        case recentBrews = "recent_brews.items"
//        case media
//        case contact
//        case dateJoined = "date_joined"
//        case settings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        uid = try container.decodeIfPresent(Int.self, forKey: .uid)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        userAvatar = try container.decodeIfPresent(String.self, forKey: .userAvatar)
        userAvatarHd = try container.decodeIfPresent(String.self, forKey: .userAvatarHd)
        userCoverPhoto = try container.decodeIfPresent(String.self, forKey: .userCoverPhoto)
        userCoverPhotoOffset = try container.decodeIfPresent(Int.self, forKey: .userCoverPhotoOffset)
        isPrivate = try container.decodeIfPresent(Int.self, forKey: .isPrivate)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        isSupporter = try container.decodeIfPresent(Int.self, forKey: .isSupporter)
        relationship = try container.decodeIfPresent(String.self, forKey: .relationship)
        untappd = try container.decodeIfPresent(String.self, forKey: .untappd)
        accountType = try container.decodeIfPresent(String.self, forKey: .accountType)
//        isModerator = try container.decodeIfPresent(Int.self, forKey: .isModerator)
//        blockStatus = try container.decodeIfPresent(String.self, forKey: .blockStatus)
//        stats = try container.decodeIfPresent(CDUntappdStats.self, forKey: .stats)
//        dateJoined = try container.decodeIfPresent(String.self, forKey: .dateJoined)
//        let response = try container.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response)
//        user = try response.decode(CDUntappdUser.self, forKey: .user)
    }

    public func userAvatarUrl() -> URL? {
        if let userAvatar = self.userAvatar,
           let url = URL(string: userAvatar) {
            return url
        }
        return nil
    }

    public func userAvatarHdUrl() -> URL? {
        if let userAvatarHd = self.userAvatarHd,
           let url = URL(string: userAvatarHd) {
            return url
        }
        return nil
    }

    public func userCoverPhotoUrl() -> URL? {
        if let userCoverPhoto = self.userCoverPhoto,
           let url = URL(string: userCoverPhoto) {
            return url
        }
        return nil
    }

    public func isPrivateBool() -> Bool? {
        if let isPrivate = self.isPrivate,
           isPrivate == 1 {
            return true
        }
        return false
    }

    public func websiteUrl() -> URL? {
        if let website = self.website,
           let url = URL(string: website) {
            return url
        }
        return nil
    }

    public func isSupporterBool() -> Bool? {
        if let isSupporter = self.isSupporter,
           isSupporter == 1 {
            return true
        }
        return false
    }

    public func untappdUrl() -> URL? {
        if let untappd = self.untappd,
           let url = URL(string: untappd) {
            return url
        }
        return nil
    }
//
//
//    public func isModeratorBool() -> Bool? {
//        if let isModerator = self.isModerator,
//           isModerator == 1 {
//            return true
//        }
//        return false
//    }
//
}
