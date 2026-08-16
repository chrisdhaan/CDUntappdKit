//
//  CDUntappdBeerItem.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/15/26.
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

/// Represents a single beer entry within a list response (user beers or beer search).
public struct CDUntappdBeerItem: Decodable, Sendable {

    /// The beer.
    public var beer: CDUntappdBeer?
    /// The brewery that makes the beer.
    public var brewery: CDUntappdBrewery?
    /// The number of times the user has checked in this beer.
    public var count: Int?
    /// When the user first checked in this beer.
    public var firstCreatedAt: String?
    /// When the user most recently checked in this beer.
    public var recentCreatedAt: String?

    enum CodingKeys: String, CodingKey {
        case beer
        case brewery
        case count
        case firstCreatedAt = "first_created_at"
        case recentCreatedAt = "recent_created_at"
    }
}
