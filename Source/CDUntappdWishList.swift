//
//  CDUntappdWishList.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/30/17.
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

/// Represents a user's Untappd wish list.
public struct CDUntappdWishList: Decodable, Sendable {

    /// The beers on the wish list.
    public var items: [CDUntappdWishListItem]?
    /// When the wish list was last updated.
    public var updatedAt: String?

    private enum RootKeys: String, CodingKey {
        case beers
        case updatedAt = "updated_at"
    }

    private enum BeersKeys: String, CodingKey {
        case items
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        updatedAt = try root.decodeIfPresent(String.self, forKey: .updatedAt)
        if let beersContainer = try? root.nestedContainer(keyedBy: BeersKeys.self, forKey: .beers) {
            items = try beersContainer.decodeIfPresent([CDUntappdWishListItem].self, forKey: .items)
        } else {
            items = nil
        }
    }
}
