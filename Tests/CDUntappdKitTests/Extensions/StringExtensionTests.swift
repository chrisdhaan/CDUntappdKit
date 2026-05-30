//
//  StringExtensionTests.swift
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

@Suite("String Extension Tests")
struct StringExtensionTests {

    @Test
    func fromBoolReturnsTrueString() {
        let result = String.fromBool(value: true)
        #expect(result == "true")
    }

    @Test
    func fromBoolReturnsFalseString() {
        let result = String.fromBool(value: false)
        #expect(result == "false")
    }

    @Test
    func pathAppendsUsernameCorrectly() {
        let result = String.path("user/info", forUsername: "testuser")
        #expect(result == "user/info/testuser")
    }

    @Test
    func pathWithoutUsernameReturnsBasePath() {
        let result = String.path("user/info", forUsername: nil)
        #expect(result == "user/info")
    }

    @Test
    func pathAppendsEmptyStringUsername() {
        let result = String.path("user/info", forUsername: "")
        #expect(result == "user/info/")
    }

    @Test
    func pathWithComplexPath() {
        let result = String.path("v4/user/wishlist", forUsername: "john_doe")
        #expect(result == "v4/user/wishlist/john_doe")
    }

    @Test
    func pathWithSpecialCharactersInUsername() {
        let result = String.path("user/info", forUsername: "user-123")
        #expect(result == "user/info/user-123")
    }
}
