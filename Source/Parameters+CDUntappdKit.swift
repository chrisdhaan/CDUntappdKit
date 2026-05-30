//
//  Parameters+CDUntappdKit.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 11/21/17.
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

import Alamofire

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

    /// Builds parameters for the user info API endpoint.
    /// - Parameter isCompact: Pass `true` for a compact response omitting extended fields.
    /// - Returns: A parameters dictionary with the `compact` key set.
    static func userInfoParameters(isCompact compact: Bool) -> Parameters {
        var params: Parameters = [:]

        params["compact"] = compact ? "true" : false

        return params
    }

    /// Builds parameters for the user wish list API endpoint.
    /// - Parameters:
    ///   - offset: Zero-based offset for pagination. Pass `nil` to omit.
    ///   - limit: Maximum number of results (max 50). Pass `nil` to omit.
    ///   - sort: How to sort results. Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func userWishListParameters(withOffset offset: Int?,
                                       limit: Int?,
                                       sort: CDUntappdUserWishListSortType?) -> Parameters {
        var params: Parameters = [:]

        if let offset = offset {
            params["offset"] = offset
        }
        if let limit = limit {
            params["limit"] = limit
        }
        if let sort = sort {
            params["sort"] = sort
        }

        return params
    }

    /// Builds parameters for the user friends API endpoint.
    /// - Parameters:
    ///   - offset: Zero-based offset for pagination. Pass `nil` to omit.
    ///   - limit: Maximum number of results (max 25). Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func userFriendsParameters(withOffset offset: Int?,
                                      limit: Int?) -> Parameters {
        var params: Parameters = [:]

        if let offset = offset {
            params["offset"] = offset
        }
        if let limit = limit {
            params["limit"] = limit
        }

        return params
    }
}
