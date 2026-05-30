//
//  CDUntappdBadge.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/27/17.
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

import Foundation

/// Represents an Untappd achievement badge.
public struct CDUntappdBadge: Decodable, Sendable {

    /// The badge's unique identifier.
    public let id: Int?
    /// The badge's name.
    public let name: String?
    /// The badge's description.
    public let description: String?
    /// The badge's small image.
    public let smallImage: URL?
    /// The badge's medium image.
    public let mediumImage: URL?
    /// The badge's large image.
    public let largeImage: URL?
    /// The user's badge instance identifier.
    public let userBadgeId: Int?
    /// When the user earned the badge.
    public let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "badge_id"
        case name = "badge_name"
        case description = "badge_description"
        case smallImage = "badge_image.sm"
        case mediumImage = "badge_image.md"
        case largeImage = "badge_image.lg"
        case userBadgeId = "user_badge_id"
        case createdAt = "created_at"
    }
}
