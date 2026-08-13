//
//  CDUntappdFriendTests.swift
//  CDUntappdKitTests
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

import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdFriend Tests")
struct CDUntappdFriendTests {

    @Test
    func decodesNestedMutualFriendsFromRealisticShape() throws {
        let json = """
        {
          "friendship_hash": "abc123",
          "user": { "uid": 1, "user_name": "DehaanSolo" },
          "mutual_friends": {
            "count": 1,
            "items": [
              { "user": { "uid": 2, "user_name": "MutualFriend" } }
            ]
          },
          "created_at": "Thu, 01 Jan 2015 00:00:00 +0000"
        }
        """.data(using: .utf8)!
        let friend = try JSONDecoder().decode(CDUntappdFriend.self, from: json)
        #expect(friend.mutualFriends != nil)
        #expect(friend.mutualFriends?.first?.user?.username == "MutualFriend")
    }

    @Test
    func mutualFriendsIsNilWhenKeyIsAbsent() throws {
        let json = """
        {
          "friendship_hash": "abc123",
          "user": { "uid": 1, "user_name": "DehaanSolo" }
        }
        """.data(using: .utf8)!
        let friend = try JSONDecoder().decode(CDUntappdFriend.self, from: json)
        #expect(friend.mutualFriends == nil)
        #expect(friend.user?.username == "DehaanSolo")
    }
}
