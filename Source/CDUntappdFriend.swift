//
//  CDUntappdFriend.swift
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

/// Represents a friendship relationship on Untappd.
public struct CDUntappdFriend: Decodable, Sendable {

    /// A unique hash for the friendship.
    public var friendshipHash: String?
    /// The friend's user information.
    public var user: CDUntappdUser?
    /// Mutual friends between the two users.
    public var mutualFriends: [CDUntappdFriend]?
    /// When the friendship was established.
    public var createdAt: String?

    private enum RootKeys: String, CodingKey {
        case friendshipHash = "friendship_hash"
        case user
        case mutualFriends = "mutual_friends"
        case createdAt = "created_at"
    }

    private enum MutualFriendsKeys: String, CodingKey {
        case items
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        friendshipHash = try root.decodeIfPresent(String.self, forKey: .friendshipHash)
        user = try root.decodeIfPresent(CDUntappdUser.self, forKey: .user)
        createdAt = try root.decodeIfPresent(String.self, forKey: .createdAt)
        if let mutualContainer = try? root.nestedContainer(keyedBy: MutualFriendsKeys.self, forKey: .mutualFriends) {
            mutualFriends = try mutualContainer.decodeIfPresent([CDUntappdFriend].self, forKey: .items)
        } else {
            mutualFriends = nil
        }
    }
}
