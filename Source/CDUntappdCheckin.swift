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
    /// Comments on the check-in.
    ///
    /// Decoded as an `items`-wrapped list, matching every other list field on this type
    /// (`badges`, `media`) and Untappd's consistent list-wrapping convention elsewhere in the
    /// API. Unlike those fields, this exact shape is not documented in `Documentation/API_SCHEMA.md`
    /// — no endpoint response containing a checkin with comments has been captured and verified.
    /// Treat as a confident inference, not a verified shape, until confirmed against a live response.
    public var comments: [CDUntappdComment]?
    public var badges: [CDUntappdBadge]?
    public var media: [CDUntappdMedia]?
    public var source: CDUntappdSource?
    public var createdAt: String?

    private enum RootKeys: String, CodingKey {
        case id = "checkin_id"
        case comment = "checkin_comment"
        case rating = "rating_score"
        case user
        case brewery
        case beer
        case venue
//        case toasts
        case comments
        case badges
        case media
        case source
        case createdAt = "created_at"
    }

    private enum ItemsKeys: String, CodingKey {
        case items
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        id = try root.decodeIfPresent(Int.self, forKey: .id)
        comment = try root.decodeIfPresent(String.self, forKey: .comment)
        rating = try root.decodeIfPresent(Double.self, forKey: .rating)
        user = try root.decodeIfPresent(CDUntappdUser.self, forKey: .user)
        brewery = try root.decodeIfPresent(CDUntappdBrewery.self, forKey: .brewery)
        beer = try root.decodeIfPresent(CDUntappdBeer.self, forKey: .beer)
        venue = try root.decodeIfPresent(CDUntappdVenue.self, forKey: .venue)
        source = try root.decodeIfPresent(CDUntappdSource.self, forKey: .source)
        createdAt = try root.decodeIfPresent(String.self, forKey: .createdAt)

        if let commentsContainer = try? root.nestedContainer(keyedBy: ItemsKeys.self, forKey: .comments) {
            comments = try commentsContainer.decodeIfPresent([CDUntappdComment].self, forKey: .items)
        } else {
            comments = nil
        }
        if let badgesContainer = try? root.nestedContainer(keyedBy: ItemsKeys.self, forKey: .badges) {
            badges = try badgesContainer.decodeIfPresent([CDUntappdBadge].self, forKey: .items)
        } else {
            badges = nil
        }
        if let mediaContainer = try? root.nestedContainer(keyedBy: ItemsKeys.self, forKey: .media) {
            media = try mediaContainer.decodeIfPresent([CDUntappdMedia].self, forKey: .items)
        } else {
            media = nil
        }
    }
}
