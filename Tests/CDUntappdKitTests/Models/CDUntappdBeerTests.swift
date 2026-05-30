//
//  CDUntappdBeerTests.swift
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

@Suite("CDUntappdBeer Tests")
struct CDUntappdBeerTests {

    @Test
    func decodesBeerNameCorrectly() throws {
        let json = """
        {
          "bid": 1,
          "beer_name": "Example IPA",
          "beer_abv": 6.5,
          "beer_ibu": 65
        }
        """.data(using: .utf8)!
        let beer = try JSONDecoder().decode(CDUntappdBeer.self, from: json)
        #expect(beer.name == "Example IPA")
    }

    @Test
    func decodesBeerIdCorrectly() throws {
        let json = """
        {
          "bid": 1,
          "beer_name": "Example IPA"
        }
        """.data(using: .utf8)!
        let beer = try JSONDecoder().decode(CDUntappdBeer.self, from: json)
        #expect(beer.id == 1)
    }

    @Test
    func decodesBeerAbvCorrectly() throws {
        let json = """
        {
          "bid": 1,
          "beer_name": "Example IPA",
          "beer_abv": 6.5
        }
        """.data(using: .utf8)!
        let beer = try JSONDecoder().decode(CDUntappdBeer.self, from: json)
        #expect(beer.abv == 6.5)
    }

    @Test
    func decodesBeerIbuCorrectly() throws {
        let json = """
        {
          "bid": 1,
          "beer_name": "Example IPA",
          "beer_ibu": 65
        }
        """.data(using: .utf8)!
        let beer = try JSONDecoder().decode(CDUntappdBeer.self, from: json)
        #expect(beer.ibu == 65)
    }
}
