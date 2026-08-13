//
//  CDUntappdBreweryTests.swift
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

@Suite("CDUntappdBrewery Tests")
struct CDUntappdBreweryTests {

    @Test
    func decodesBreweryNameCorrectly() throws {
        let json = """
        {
          "brewery_id": 1,
          "brewery_name": "Example Brewery",
          "brewery_slug": "example-brewery"
        }
        """.data(using: .utf8)!
        let brewery = try JSONDecoder().decode(CDUntappdBrewery.self, from: json)
        #expect(brewery.name == "Example Brewery")
    }

    @Test
    func decodesBreweryIdCorrectly() throws {
        let json = """
        {
          "brewery_id": 1,
          "brewery_name": "Example Brewery",
          "brewery_slug": "example-brewery"
        }
        """.data(using: .utf8)!
        let brewery = try JSONDecoder().decode(CDUntappdBrewery.self, from: json)
        #expect(brewery.id == 1)
    }

    @Test
    func decodesBrewerySlugCorrectly() throws {
        let json = """
        {
          "brewery_id": 1,
          "brewery_name": "Example Brewery",
          "brewery_slug": "example-brewery"
        }
        """.data(using: .utf8)!
        let brewery = try JSONDecoder().decode(CDUntappdBrewery.self, from: json)
        #expect(brewery.slug == "example-brewery")
    }

    @Test
    func decodesNestedLocationAndContactFromRealisticShape() throws {
        let json = """
        {
          "brewery_id": 1,
          "brewery_name": "Example Brewery",
          "location": {
            "lat": 40.7128,
            "lng": -74.0060,
            "brewery_city": "New York",
            "brewery_state": "NY"
          },
          "contact": {
            "facebook": "https://facebook.com/example",
            "twitter": "example_brewery",
            "instagram": "example_brewery",
            "url": "https://example-brewery.com"
          }
        }
        """.data(using: .utf8)!
        let brewery = try JSONDecoder().decode(CDUntappdBrewery.self, from: json)
        #expect(brewery.latitude == 40.7128)
        #expect(brewery.city == "New York")
        #expect(brewery.state == "NY")
        #expect(brewery.facebookUrl?.absoluteString == "https://facebook.com/example")
        #expect(brewery.twitterHandle == "example_brewery")
        #expect(brewery.website?.absoluteString == "https://example-brewery.com")
    }

    @Test
    func decodesIsActiveFromIntegerOrBoolean() throws {
        let intJSON = """
        { "brewery_id": 1, "brewery_active": 1 }
        """.data(using: .utf8)!
        let breweryFromInt = try JSONDecoder().decode(CDUntappdBrewery.self, from: intJSON)
        #expect(breweryFromInt.isActive == true)

        let boolJSON = """
        { "brewery_id": 1, "brewery_active": false }
        """.data(using: .utf8)!
        let breweryFromBool = try JSONDecoder().decode(CDUntappdBrewery.self, from: boolJSON)
        #expect(breweryFromBool.isActive == false)
    }

    @Test
    func locationAndContactAreNilWhenKeysAreAbsent() throws {
        let json = """
        {
          "brewery_id": 1,
          "brewery_name": "Example Brewery"
        }
        """.data(using: .utf8)!
        let brewery = try JSONDecoder().decode(CDUntappdBrewery.self, from: json)
        #expect(brewery.latitude == nil)
        #expect(brewery.facebookUrl == nil)
    }
}
