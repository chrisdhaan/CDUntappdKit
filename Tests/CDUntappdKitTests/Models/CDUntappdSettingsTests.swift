//
//  CDUntappdSettingsTests.swift
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

@Suite("CDUntappdSettings Tests")
struct CDUntappdSettingsTests {

    @Test
    func decodesNestedSettingsFromRealisticShape() throws {
        let json = """
        {
          "badge": {
            "badges_to_facebook": true,
            "badges_to_twitter": false
          },
          "checkin": {
            "checkin_to_facebook": true,
            "checkin_to_twitter": false,
            "checkin_to_foursquare": true
          },
          "navigation": {
            "default_to_checkin": true
          },
          "email_address": "test@example.com"
        }
        """.data(using: .utf8)!
        let settings = try JSONDecoder().decode(CDUntappdSettings.self, from: json)
        #expect(settings.badgesToFacebook == true)
        #expect(settings.badgesToTwitter == false)
        #expect(settings.checkinToFacebook == true)
        #expect(settings.checkinToFoursquare == true)
        #expect(settings.defaultToCheckin == true)
        #expect(settings.emailAddress == "test@example.com")
    }

    @Test
    func settingsAreNilWhenParentKeysAreAbsent() throws {
        let json = """
        {
          "email_address": "test@example.com"
        }
        """.data(using: .utf8)!
        let settings = try JSONDecoder().decode(CDUntappdSettings.self, from: json)
        #expect(settings.badgesToFacebook == nil)
        #expect(settings.checkinToFacebook == nil)
        #expect(settings.defaultToCheckin == nil)
    }
}
