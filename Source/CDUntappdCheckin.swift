//
//  CDUntappdCheckin.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
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

/// Represents an Untappd check-in (beer visit record).
public struct CDUntappdCheckin: Decodable, Sendable {

    /// The unique check-in identifier.
    public var id: Int?
    /// The user's comment on the check-in.
    public var comment: String?
    /// The user's rating for the beer (0–5).
    public var rating: Double?
    /// The user who made the check-in.
    public var user: CDUntappdUser?
    /// The brewery associated with the beer.
    public var brewery: CDUntappdBrewery?
    /// The beer that was checked in.
    public var beer: CDUntappdBeer?
    /// The venue where the check-in occurred.
    public var venue: CDUntappdVenue?
//    public var toasts: [CDUntappdToast]?
//    public var comments: [CDUntappdComment]?
    public var badges: [CDUntappdBadge]?
    public var media: [CDUntappdMedia]?
    public var source: CDUntappdSource?
    public var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "checkin_id"
        case comment = "checkin_comment"
        case rating = "rating_score"
        case user = "user"
        case brewery = "brewery"
        case beer = "beer"
        case venue = "venue"
//        case toasts = "toasts.items"
//        case comments = "comments.items"
        case badges = "badges.items"
        case media = "media.items"
        case source = "source"
        case createdAt = "created_at"
    }
}
