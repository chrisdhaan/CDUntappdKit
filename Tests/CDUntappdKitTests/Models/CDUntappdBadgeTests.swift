//
//  CDUntappdBadgeTests.swift
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

@Suite("CDUntappdBadge Tests")
struct CDUntappdBadgeTests {

    @Test
    func decodesNestedBadgeImagesFromRealisticShape() throws {
        let json = """
        {
          "badge_id": 1,
          "badge_name": "Example Badge",
          "badge_image": {
            "sm": "https://example.com/badge_sm.jpg",
            "md": "https://example.com/badge_md.jpg",
            "lg": "https://example.com/badge_lg.jpg"
          }
        }
        """.data(using: .utf8)!
        let badge = try JSONDecoder().decode(CDUntappdBadge.self, from: json)
        #expect(badge.smallImage?.absoluteString == "https://example.com/badge_sm.jpg")
        #expect(badge.mediumImage?.absoluteString == "https://example.com/badge_md.jpg")
        #expect(badge.largeImage?.absoluteString == "https://example.com/badge_lg.jpg")
    }

    @Test
    func imagesAreNilWhenBadgeImageKeyIsAbsent() throws {
        let json = """
        {
          "badge_id": 1,
          "badge_name": "Example Badge"
        }
        """.data(using: .utf8)!
        let badge = try JSONDecoder().decode(CDUntappdBadge.self, from: json)
        #expect(badge.smallImage == nil)
        #expect(badge.mediumImage == nil)
        #expect(badge.largeImage == nil)
        #expect(badge.name == "Example Badge")
    }
}
