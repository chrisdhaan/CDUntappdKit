//
//  CDUntappdCheckin.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
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

public struct CDUntappdCheckin: Decodable {

    public let id: Int?
    public let comment: String?
    public let rating: Double?
    public let user: CDUntappdUser?
    public let brewery: CDUntappdBrewery?
    public let beer: CDUntappdBeer?
    public let venue: CDUntappdVenue?
//    public let toasts: [CDUntappdToast]?
//    public let comments: [CDUntappdComment]?
    public let badges: [CDUntappdBadge]?
    public let media: [CDUntappdMedia]?
    public let source: CDUntappdSource?
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "checkin_id"
        case comment = "checkin_comment"
        case rating = "rating_score"
        case user
        case brewery
        case beer
        case venue
//        case toasts = "toasts.items"
//        case comments = "comments.items"
        case badges = "badges.items"
        case media = "media.items"
        case source
        case createdAt = "created_at"
    }
}
