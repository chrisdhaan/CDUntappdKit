//
//  CDUntappdMediaTests.swift
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

@Suite("CDUntappdMedia Tests")
struct CDUntappdMediaTests {

    @Test
    func decodesNestedPhotoImagesFromRealisticShape() throws {
        let json = """
        {
          "photo_id": 1,
          "photo": {
            "photo_img_og": "https://example.com/original.jpg",
            "photo_img_sm": "https://example.com/small.jpg",
            "photo_img_md": "https://example.com/medium.jpg",
            "photo_img_lg": "https://example.com/large.jpg"
          }
        }
        """.data(using: .utf8)!
        let media = try JSONDecoder().decode(CDUntappdMedia.self, from: json)
        #expect(media.originalImage?.absoluteString == "https://example.com/original.jpg")
        #expect(media.smallImage?.absoluteString == "https://example.com/small.jpg")
        #expect(media.mediumImage?.absoluteString == "https://example.com/medium.jpg")
        #expect(media.largeImage?.absoluteString == "https://example.com/large.jpg")
    }

    @Test
    func imagesAreNilWhenPhotoKeyIsAbsent() throws {
        let json = """
        {
          "photo_id": 1
        }
        """.data(using: .utf8)!
        let media = try JSONDecoder().decode(CDUntappdMedia.self, from: json)
        #expect(media.originalImage == nil)
        #expect(media.id == 1)
    }
}
