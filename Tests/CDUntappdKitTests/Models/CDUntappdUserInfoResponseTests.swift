//
//  CDUntappdUserInfoResponseTests.swift
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

@Suite("CDUntappdUserInfoResponse Tests")
struct CDUntappdUserInfoResponseTests {

    @Test
    func decodesNestedUserFromRealisticResponseShape() throws {
        let url = try #require(Bundle.module.url(forResource: "user_info", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdUserInfoResponse.self, from: data)
        #expect(response.user != nil)
        #expect(response.user?.username == "DehaanSolo")
    }

    @Test
    func decodesMetadataAlongsideUser() throws {
        let url = try #require(Bundle.module.url(forResource: "user_info", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdUserInfoResponse.self, from: data)
        #expect(response.metadata != nil)
    }

    @Test
    func userIsNilWhenResponseKeyIsAbsent() throws {
        let json = """
        {
          "meta": { "code": 200 }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDUntappdUserInfoResponse.self, from: json)
        #expect(response.user == nil)
    }
}
