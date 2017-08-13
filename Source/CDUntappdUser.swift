//
//  CDUntappdUser.swift
//  CDUntappdKit
//
//  Created by Chris De Haan on 8/4/17.
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

public class CDUntappdUser: Mappable {

    public var id: Int?
    public var uid: Int?
    public var username: String?
    public var firstName: String?
    public var lastName: String?
    public var userAvatar: URL?
    public var userAvatatHd: URL?
    public var userCoverPhoto: URL?
    public var userCoverPhotoOffset: Int?
    public var isPrivate: Bool?
    public var location: String?
    public var url: URL?
    public var bio: String?
    public var isSupporter: Bool?
    public var relationship: String?
    public var untappdUrl: URL?
    public var accountType: String?
    public var stats: CDUntappdStats?
    public var dateJoined: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id                      <- map["id"]
        uid                     <- map["uid"]
        username                <- map["user_name"]
        firstName               <- map["first_name"]
        lastName                <- map["last_name"]
        userAvatar              <- map["user_avatar"]
        userAvatatHd            <- map["user_avatar"]
        userCoverPhoto          <- map["user_cover_photo"]
        userCoverPhotoOffset    <- map["user_cover_photo_offset"]
        isPrivate               <- map["is_private"]
        location                <- map["location"]
        url                     <- map["url"]
        bio                     <- map["bio"]
        isSupporter             <- map["is_supporter"]
        relationship            <- map["relationship"]
        untappdUrl              <- map["untappd_url"]
        accountType             <- map["account_type"]
        stats                   <- map["stats"]
        dateJoined              <- map["date_joined"]
    }
}
