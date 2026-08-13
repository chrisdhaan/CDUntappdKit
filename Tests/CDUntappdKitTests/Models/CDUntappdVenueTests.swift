//
//  CDUntappdVenueTests.swift
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

@Suite("CDUntappdVenue Tests")
struct CDUntappdVenueTests {

    @Test
    func venueDecodingIsSupported() throws {
        let json = """
        {
          "venue_id": 1,
          "venue_name": "Test Venue"
        }
        """.data(using: .utf8)!
        let venue = try JSONDecoder().decode(CDUntappdVenue.self, from: json)
        #expect(venue.id == 1)
        #expect(venue.name == "Test Venue")
    }

    @Test
    func decodesNestedFieldsFromRealisticShape() throws {
        let json = """
        {
          "venue_id": 1,
          "venue_name": "Test Venue",
          "categories": {
            "items": [
              { "category_name": "Bar" }
            ]
          },
          "venue_icon": {
            "sm": "https://example.com/icon_sm.jpg",
            "md": "https://example.com/icon_md.jpg",
            "lg": "https://example.com/icon_lg.jpg"
          },
          "location": {
            "lat": 40.7128,
            "lng": -74.0060,
            "venue_address": "123 Main St",
            "venue_city": "New York",
            "venue_state": "NY",
            "venue_country": "United States"
          },
          "foursquare": {
            "foursquare_id": "abc123",
            "foursquare_url": "https://foursquare.com/v/abc123"
          },
          "contact": {
            "twitter": "test_venue",
            "venue_url": "https://test-venue.com"
          }
        }
        """.data(using: .utf8)!
        let venue = try JSONDecoder().decode(CDUntappdVenue.self, from: json)
        #expect(venue.categories?.count == 1)
        #expect(venue.smallIcon?.absoluteString == "https://example.com/icon_sm.jpg")
        #expect(venue.latitude == 40.7128)
        #expect(venue.address == "123 Main St")
        #expect(venue.foursqaureId == "abc123")
        #expect(venue.twitterHandle == "test_venue")
        #expect(venue.website?.absoluteString == "https://test-venue.com")
    }

    @Test
    func decodesIsVerifiedFromIntegerOrBoolean() throws {
        let intJSON = """
        { "venue_id": 1, "is_verified": 1 }
        """.data(using: .utf8)!
        let venueFromInt = try JSONDecoder().decode(CDUntappdVenue.self, from: intJSON)
        #expect(venueFromInt.isVerified == true)

        let boolJSON = """
        { "venue_id": 1, "is_verified": false }
        """.data(using: .utf8)!
        let venueFromBool = try JSONDecoder().decode(CDUntappdVenue.self, from: boolJSON)
        #expect(venueFromBool.isVerified == false)
    }

    @Test
    func nestedFieldsAreNilWhenKeysAreAbsent() throws {
        let json = """
        {
          "venue_id": 1,
          "venue_name": "Test Venue"
        }
        """.data(using: .utf8)!
        let venue = try JSONDecoder().decode(CDUntappdVenue.self, from: json)
        #expect(venue.categories == nil)
        #expect(venue.latitude == nil)
        #expect(venue.foursqaureId == nil)
        #expect(venue.website == nil)
    }
}
