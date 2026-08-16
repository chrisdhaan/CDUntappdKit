//
//  CDUntappdRouter.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/4/17.
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

/// Routes for Untappd API endpoints.
///
/// Used internally to construct HTTP requests for the Untappd API.
public enum CDUntappdRouter {

    /// Fetch user information by username.
    case userInfo(username: String?, parameters: Parameters)
    /// Fetch a user's wish list of beers.
    case userWishList(username: String?, parameters: Parameters)
    /// Fetch a user's friends list.
    case userFriends(username: String?, parameters: Parameters)
    /// Fetch a user's badges.
    case userBadges(username: String?, parameters: Parameters)
    /// Fetch beers a user has checked in.
    case userBeers(username: String?, parameters: Parameters)
    /// Fetch brewery information by ID.
    case breweryInfo(breweryId: Int, parameters: Parameters)
    /// Fetch beer information by ID.
    case beerInfo(bid: Int, parameters: Parameters)
    /// Fetch venue information by ID.
    case venueInfo(venueId: Int, parameters: Parameters)
    /// Search for beers.
    case beerSearch(parameters: Parameters)
    /// Search for breweries.
    case brewerySearch(parameters: Parameters)
    /// Fetch the authenticated user's friend check-in feed.
    case activityFeed(parameters: Parameters)
    /// Fetch a user's check-in history.
    case userActivityFeed(username: String?, parameters: Parameters)
    /// Fetch recent check-ins for a beer.
    case beerActivityFeed(bid: Int, parameters: Parameters)
    /// Fetch recent check-ins for a brewery.
    case breweryActivityFeed(breweryId: Int, parameters: Parameters)
    /// Fetch recent check-ins at a venue.
    case venueActivityFeed(venueId: Int, parameters: Parameters)
    /// Fetch the authenticated user's toast and comment notifications.
    case notifications(parameters: Parameters)
    /// Look up an Untappd venue by its Foursquare v2 venue ID.
    case foursquareLookup(venueId: String, parameters: Parameters)

    var path: String {
        switch self {
        case .userInfo(let username, parameters: _):
            String.path("user/info", forUsername: username)
        case .userWishList(let username, parameters: _):
            String.path("user/wishlist", forUsername: username)
        case .userFriends(let username, parameters: _):
            String.path("user/friends", forUsername: username)
        case .userBadges(let username, parameters: _):
            String.path("user/badges", forUsername: username)
        case .userBeers(let username, parameters: _):
            String.path("user/beers", forUsername: username)
        case .breweryInfo(let breweryId, parameters: _):
            "brewery/info/\(breweryId)"
        case .beerInfo(let bid, parameters: _):
            "beer/info/\(bid)"
        case .venueInfo(let venueId, parameters: _):
            "venue/info/\(venueId)"
        case .beerSearch:
            "search/beer"
        case .brewerySearch:
            "search/brewery"
        case .activityFeed:
            "checkin/recent"
        case .userActivityFeed(let username, parameters: _):
            String.path("user/checkins", forUsername: username)
        case .beerActivityFeed(let bid, parameters: _):
            "beer/checkins/\(bid)"
        case .breweryActivityFeed(let breweryId, parameters: _):
            "brewery/checkins/\(breweryId)"
        case .venueActivityFeed(let venueId, parameters: _):
            "venue/checkins/\(venueId)"
        case .notifications:
            "notifications"
        case .foursquareLookup(let venueId, parameters: _):
            "venue/foursquare_lookup/\(venueId)"
        }
    }

    var parameters: Parameters {
        switch self {
        case let .userInfo(username: _, parameters),
             let .userWishList(username: _, parameters),
             let .userFriends(username: _, parameters),
             let .userBadges(username: _, parameters),
             let .userBeers(username: _, parameters),
             let .breweryInfo(breweryId: _, parameters),
             let .beerInfo(bid: _, parameters),
             let .venueInfo(venueId: _, parameters),
             let .beerSearch(parameters),
             let .brewerySearch(parameters),
             let .userActivityFeed(username: _, parameters),
             let .beerActivityFeed(bid: _, parameters),
             let .breweryActivityFeed(breweryId: _, parameters),
             let .venueActivityFeed(venueId: _, parameters),
             let .activityFeed(parameters),
             let .notifications(parameters),
             let .foursquareLookup(venueId: _, parameters):
            parameters
        }
    }

    public func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: CDUntappdURL.base) else {
            throw CDUntappdKitError.invalidRequest(underlying: URLError(.badURL))
        }
        return try CDUntappdParameterEncoding.urlRequest(
            for: url.appendingPathComponent(path),
            parameters: parameters
        )
    }
}
