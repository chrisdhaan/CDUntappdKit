//
//  CDUntappdMetadataTests.swift
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

@Suite("CDUntappdMetadata Tests")
struct CDUntappdMetadataTests {

    let fixtureURL = Bundle.module.url(forResource: "user_info", withExtension: "json")!

    @Test
    func decodesMetadataCodeCorrectly() throws {
        let data = try Data(contentsOf: fixtureURL)
        let response = try JSONDecoder().decode(CDUntappdUserInfoResponse.self, from: data)
        #expect(response.metadata?.code == 200)
    }

    @Test
    func hasErrorReturnsFalseForSuccessCode() throws {
        let data = try Data(contentsOf: fixtureURL)
        let response = try JSONDecoder().decode(CDUntappdUserInfoResponse.self, from: data)
        #expect(response.metadata?.hasError() == false)
    }

    @Test
    func metadataDecodingIsSupported() throws {
        let json = """
        {
          "code": 200
        }
        """.data(using: .utf8)!
        let metadata = try JSONDecoder().decode(CDUntappdMetadata.self, from: json)
        #expect(metadata.code == 200)
    }
}
