//
//  CDUntappdUserTests.swift
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

import Testing
import Foundation
@testable import CDUntappdKit

@Suite("CDUntappdUser Tests")
@MainActor
struct CDUntappdUserTests {

    @Test
    func decodesUsernameCorrectly() throws {
        let json = """
        {
          "uid": 1,
          "user_name": "DehaanSolo",
          "first_name": "Christopher",
          "last_name": "de Haan"
        }
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(CDUntappdUser.self, from: json)
        #expect(user.username == "DehaanSolo")
    }

    @Test
    func decodesFirstNameCorrectly() throws {
        let json = """
        {
          "uid": 1,
          "user_name": "DehaanSolo",
          "first_name": "Christopher",
          "last_name": "de Haan"
        }
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(CDUntappdUser.self, from: json)
        #expect(user.firstName == "Christopher")
    }

    @Test
    func decodesLastNameCorrectly() throws {
        let json = """
        {
          "uid": 1,
          "user_name": "DehaanSolo",
          "first_name": "Christopher",
          "last_name": "de Haan"
        }
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(CDUntappdUser.self, from: json)
        #expect(user.lastName == "de Haan")
    }

    @Test
    func decodesUidCorrectly() throws {
        let json = """
        {
          "uid": 1,
          "user_name": "DehaanSolo"
        }
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(CDUntappdUser.self, from: json)
        #expect(user.uid == 1)
    }

    @Test
    func userDecodingIsSupported() throws {
        let json = """
        {
          "uid": 1,
          "user_name": "DehaanSolo"
        }
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(CDUntappdUser.self, from: json)
        #expect(user != nil)
    }
}
