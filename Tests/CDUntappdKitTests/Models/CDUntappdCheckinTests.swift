//
//  CDUntappdCheckinTests.swift
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

@Suite("CDUntappdCheckin Tests")
struct CDUntappdCheckinTests {

    @Test
    func checkinDecodingIsSupported() throws {
        let json = """
        {
          "checkin_id": 1,
          "checkin_comment": "Great beer!"
        }
        """.data(using: .utf8)!
        let checkin = try JSONDecoder().decode(CDUntappdCheckin.self, from: json)
        #expect(checkin.id == 1)
        #expect(checkin.comment == "Great beer!")
    }

    @Test
    func decodesNestedBadgesAndMediaFromRealisticShape() throws {
        let json = """
        {
          "checkin_id": 1,
          "badges": {
            "items": [
              { "badge_id": 1, "badge_name": "Example Badge" }
            ]
          },
          "media": {
            "items": [
              { "photo_id": 1 }
            ]
          }
        }
        """.data(using: .utf8)!
        let checkin = try JSONDecoder().decode(CDUntappdCheckin.self, from: json)
        #expect(checkin.badges?.first?.name == "Example Badge")
        #expect(checkin.media?.first?.id == 1)
    }

    @Test
    func badgesAndMediaAreNilWhenKeysAreAbsent() throws {
        let json = """
        {
          "checkin_id": 1
        }
        """.data(using: .utf8)!
        let checkin = try JSONDecoder().decode(CDUntappdCheckin.self, from: json)
        #expect(checkin.badges == nil)
        #expect(checkin.media == nil)
    }

    @Test
    func decodesNestedCommentsFromItemsWrappedShape() throws {
        let json = """
        {
          "checkin_id": 1,
          "comments": {
            "items": [
              { "comment_id": 1, "comment": "Cheers!" }
            ]
          }
        }
        """.data(using: .utf8)!
        let checkin = try JSONDecoder().decode(CDUntappdCheckin.self, from: json)
        #expect(checkin.comments?.first?.comment == "Cheers!")
    }

    @Test
    func commentsIsNilWhenKeyIsAbsent() throws {
        let json = """
        {
          "checkin_id": 1
        }
        """.data(using: .utf8)!
        let checkin = try JSONDecoder().decode(CDUntappdCheckin.self, from: json)
        #expect(checkin.comments == nil)
    }
}
