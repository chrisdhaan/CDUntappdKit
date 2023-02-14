//
//  CDUntappdRouter.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/4/17.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
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

#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif

import Alamofire

enum CDUntappdRouter: URLRequestConvertible {

    // Feeds
    case activityFeed(parameters: Parameters)
    case userActivityFeed(username: String?, parameters: Parameters)
    case thePubLocal(parameters: Parameters)
    case venueActivityFeed(venueId: Int, parameters: Parameters)
    case beerActivityFeed(bid: Int, parameters: Parameters)
    case breweryActivityFeed(breweryId: Int, parameters: Parameters)
    case notifications(parameters: Parameters)
    // Info / Search
    case userInfo(username: String?, parameters: Parameters)
    case userWishList(username: String?, parameters: Parameters)
    case userFriends(username: String?, parameters: Parameters)
    case userBadges(username: String?, parameters: Parameters)
    case userBeers(username: String?, parameters: Parameters)
    case breweryInfo(breweryId: Int, parameters: Parameters)
    case beerInfo(bid: Int, parameters: Parameters)
    case venueInfo(venueId: Int, parameters: Parameters)
    case beerSearch(parameters: Parameters)
    case brewerySearch(parameters: Parameters)
    // Actions
    case checkin(parameters: Parameters)
    case toast(checkinId: Int, parameters: Parameters)
    case pendingFriends(parameters: Parameters)
    case addFriend(targetId: Int, parameters: Parameters)
    case removeFriend(targetId: Int, parameters: Parameters)
    case acceptFriend(targetId: Int, parameters: Parameters)
    case rejectFriend(targetId: Int, parameters: Parameters)
    case addComment(checkinId: Int, parameters: Parameters)
    case removeComment(checkinId: Int, parameters: Parameters)
    case addToWishList(parameters: Parameters)
    case removeFromWishList(parameters: Parameters)
    // Utilities
    case foursquareLookup(venueId: String, parameters: Parameters)

    var method: HTTPMethod {
        switch self {
        case
            // Feeds
            .activityFeed(parameters: _),
            .userActivityFeed(username: _, parameters: _),
            .thePubLocal(parameters: _),
            .venueActivityFeed(venueId: _, parameters: _),
            .beerActivityFeed(bid: _, parameters: _),
            .breweryActivityFeed(breweryId: _, parameters: _),
            .notifications(parameters: _),
            // Info / Search
            .userInfo(username: _, parameters: _),
            .userWishList(username: _, parameters: _),
            .userFriends(username: _, parameters: _),
            .userBadges(username: _, parameters: _),
            .userBeers(username: _, parameters: _),
            .breweryInfo(breweryId: _, parameters: _),
            .beerInfo(bid: _, parameters: _),
            .venueInfo(venueId: _, parameters: _),
            .beerSearch(parameters: _),
            .brewerySearch(parameters: _),
            // Actions
            .pendingFriends(parameters: _),
            .addFriend(targetId: _, parameters: _),
            .removeFriend(targetId: _, parameters: _),
            .acceptFriend(targetId: _, parameters: _),
            .rejectFriend(targetId: _, parameters: _),
            .addToWishList(parameters: _),
            .removeFromWishList(parameters: _),
            // Utilities
            .foursquareLookup(venueId: _, parameters: _):
            return .get
        case
            // Actions
            .checkin(parameters: _),
            .toast(checkinId: _, parameters: _),
            .addComment(checkinId: _, parameters: _),
            .removeComment(checkinId: _, parameters: _):
            return .post
        }
    }

    var path: String {
        switch self {
        // Feeds
        case .activityFeed(parameters: _):
            return "checkin/recent"
        case .userActivityFeed(let username, parameters: _):
            return String.path("user/checkins", forUsername: username)
        case .thePubLocal(parameters: _):
            return "thepub/local"
        case .venueActivityFeed(let venueId, parameters: _):
            return "venue/checkins/\(venueId)"
        case .beerActivityFeed(let bid, parameters: _):
            return "beer/checkins/\(bid)"
        case .breweryActivityFeed(let breweryId, parameters: _):
            return "brewery/checkins/\(breweryId)"
        case .notifications(parameters: _):
            return "notifications"
        // Info / Search
        case .userInfo(let username, parameters: _):
            return String.path("user/info", forUsername: username)
        case .userWishList(let username, parameters: _):
            return String.path("user/wishlist", forUsername: username)
        case .userFriends(let username, parameters: _):
            return String.path("user/friends", forUsername: username)
        case .userBadges(let username, parameters: _):
            return String.path("user/badges", forUsername: username)
        case .userBeers(let username, parameters: _):
            return String.path("user/beers", forUsername: username)
        case .breweryInfo(let breweryId, parameters: _):
            return "brewery/info/\(breweryId)"
        case .beerInfo(let bid, parameters: _):
            return "beer/info/\(bid)"
        case .venueInfo(let venueId, parameters: _):
            return "venue/info/\(venueId)"
        case .beerSearch(parameters: _):
            return "search/beer"
        case .brewerySearch(parameters: _):
            return "search/brewery"
        // Actions
        case .checkin(parameters: _):
            return "checkin/add"
        case .toast(let checkinId, parameters: _):
            return "checkin/toast/\(checkinId)"
        case .pendingFriends(parameters: _):
            return "user/pending"
        case .addFriend(let targetId, parameters: _):
            return "friend/request/\(targetId)"
        case .removeFriend(let targetId, parameters: _):
            return "friend/remove/\(targetId)"
        case .acceptFriend(let targetId, parameters: _):
            return "friend/accept/\(targetId)"
        case .rejectFriend(let targetId, parameters: _):
            return "friend/reject/\(targetId)"
        case .addComment(let checkinId, parameters: _):
            return "checkin/addcomment/\(checkinId)"
        case .removeComment(let checkinId, parameters: _):
            return "checkin/deletecomment/\(checkinId)"
        case .addToWishList(parameters: _):
            return "user/wishlist/add"
        case .removeFromWishList(parameters: _):
            return "user/wishlist/add"
        // Utilities
        case .foursquareLookup(let venueId, parameters: _):
            return "venue/foursquare_lookup/\(venueId)"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try CDUntappdURL.base.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        case
            // Feeds
            .activityFeed(let parameters),
            .userActivityFeed(username: _, let parameters),
            .thePubLocal(let parameters),
            .venueActivityFeed(venueId: _, let parameters),
            .beerActivityFeed(bid: _, let parameters),
            .breweryActivityFeed(breweryId: _, let parameters),
            .notifications(let parameters),
            // Info / Search
            .userInfo(username: _, let parameters),
            .userWishList(username: _, let parameters),
            .userFriends(username: _, let parameters),
            .userBadges(username: _, let parameters),
            .userBeers(username: _, let parameters),
            .breweryInfo(breweryId: _, let parameters),
            .beerInfo(bid: _, let parameters),
            .venueInfo(venueId: _, let parameters),
            .beerSearch(let parameters),
            .brewerySearch(let parameters),
            // Actions
            .checkin(let parameters),
            .toast(checkinId: _, let parameters),
            .pendingFriends(let parameters),
            .addFriend(targetId: _, let parameters),
            .removeFriend(targetId: _, let parameters),
            .acceptFriend(targetId: _, let parameters),
            .rejectFriend(targetId: _, let parameters),
            .addComment(checkinId: _, let parameters),
            .removeComment(checkinId: _, let parameters),
            .addToWishList(let parameters),
            .removeFromWishList(let parameters),
            // Utilities
            .foursquareLookup(venueId: _, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }
}
