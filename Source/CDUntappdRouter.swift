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

    var method: HTTPMethod {
        switch self {
        // Info / Search
        case .userInfo(username: _, parameters: _),
             .userWishList(username: _, parameters: _),
             .userFriends(username: _, parameters: _),
             .userBadges(username: _, parameters: _),
             .userBeers(username: _, parameters: _),
             .breweryInfo(breweryId: _, parameters: _),
             .beerInfo(bid: _, parameters: _),
             .venueInfo(venueId: _, parameters: _),
             .beerSearch(parameters: _),
             .brewerySearch(parameters: _):
            return .get
        }
    }

    var path: String {
        switch self {
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
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try CDUntappdURL.base.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        // Info / Search
        case .userInfo(username: _, let parameters),
             .userWishList(username: _, let parameters),
             .userFriends(username: _, let parameters),
             .userBadges(username: _, let parameters),
             .userBeers(username: _, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .breweryInfo(breweryId: _, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .beerInfo(bid: _, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .venueInfo(venueId: _, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .beerSearch(let parameters),
             .brewerySearch(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }
}
