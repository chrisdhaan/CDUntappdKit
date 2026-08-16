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

        if let offset {
            params["offset"] = offset
        }
        if let limit {
            params["limit"] = limit
        }
        if let sort {
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

        if let offset {
            params["offset"] = offset
        }
        if let limit {
            params["limit"] = limit
        }

        return params
    }

    /// Builds parameters for the user badges API endpoint.
    /// - Parameter offset: Zero-based offset for pagination. Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func userBadgesParameters(withOffset offset: Int?) -> Parameters {
        var params: Parameters = [:]

        if let offset {
            params["offset"] = offset
        }

        return params
    }

    /// Builds parameters for the user beers API endpoint.
    /// - Parameters:
    ///   - offset: Zero-based offset for pagination. Pass `nil` to omit.
    ///   - limit: Maximum number of results (max 50). Pass `nil` to omit.
    ///   - sort: How to sort results. Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func userBeersParameters(withOffset offset: Int?,
                                    limit: Int?,
                                    sort: CDUntappdUserBeersSortType?) -> Parameters {
        var params: Parameters = [:]

        if let offset {
            params["offset"] = offset
        }
        if let limit {
            params["limit"] = limit
        }
        if let sort {
            params["sort"] = sort
        }

        return params
    }

    /// Builds parameters for the beer info API endpoint.
    /// - Parameter isCompact: Pass `true` for a compact response omitting extended fields.
    /// - Returns: A parameters dictionary with the `compact` key set.
    static func beerInfoParameters(isCompact compact: Bool) -> Parameters {
        var params: Parameters = [:]

        params["compact"] = compact ? "true" : false

        return params
    }

    /// Builds parameters for the brewery info API endpoint.
    /// - Parameter isCompact: Pass `true` for a compact response omitting extended fields.
    /// - Returns: A parameters dictionary with the `compact` key set.
    static func breweryInfoParameters(isCompact compact: Bool) -> Parameters {
        var params: Parameters = [:]

        params["compact"] = compact ? "true" : false

        return params
    }

    /// Builds parameters for the venue info API endpoint.
    /// - Parameter isCompact: Pass `true` for a compact response omitting extended fields.
    /// - Returns: A parameters dictionary with the `compact` key set.
    static func venueInfoParameters(isCompact compact: Bool) -> Parameters {
        var params: Parameters = [:]

        params["compact"] = compact ? "true" : false

        return params
    }

    /// Builds parameters for the beer search API endpoint.
    /// - Parameters:
    ///   - query: The search term.
    ///   - offset: Zero-based offset for pagination. Pass `nil` to omit.
    ///   - limit: Maximum number of results (max 50). Pass `nil` to omit.
    ///   - sort: How to sort results. Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func beerSearchParameters(query: String,
                                     offset: Int?,
                                     limit: Int?,
                                     sort: CDUntappdBeerSearchSortType?) -> Parameters {
        var params: Parameters = ["q": query]

        if let offset {
            params["offset"] = offset
        }
        if let limit {
            params["limit"] = limit
        }
        if let sort {
            params["sort"] = sort
        }

        return params
    }

    /// Builds parameters for the brewery search API endpoint.
    /// - Parameters:
    ///   - query: The search term.
    ///   - offset: Zero-based offset for pagination. Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func brewerySearchParameters(query: String,
                                        offset: Int?) -> Parameters {
        var params: Parameters = ["q": query]

        if let offset {
            params["offset"] = offset
        }

        return params
    }

    /// Builds parameters for the check-in activity feed API endpoints.
    /// - Parameters:
    ///   - maxId: Return checkins with ID ≤ maxId (older). Pass `nil` to omit.
    ///   - minId: Return checkins with ID ≥ minId (newer). Pass `nil` to omit.
    ///   - limit: Maximum number of results. Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func activityFeedParameters(maxId: Int?,
                                       minId: Int?,
                                       limit: Int?) -> Parameters {
        var params: Parameters = [:]

        if let maxId {
            params["max_id"] = maxId
        }
        if let minId {
            params["min_id"] = minId
        }
        if let limit {
            params["limit"] = limit
        }

        return params
    }

    /// Builds parameters for the notifications API endpoint.
    /// - Parameters:
    ///   - offset: Zero-based offset for pagination. Pass `nil` to omit.
    ///   - limit: Maximum number of results (max 25). Pass `nil` to omit.
    /// - Returns: A parameters dictionary with the provided values.
    static func notificationsParameters(withOffset offset: Int?,
                                        limit: Int?) -> Parameters {
        var params: Parameters = [:]

        if let offset {
            params["offset"] = offset
        }
        if let limit {
            params["limit"] = limit
        }

        return params
    }

    /// Builds parameters for the checkin add API endpoint.
    /// - Parameters:
    ///   - bid: The Untappd beer ID to check in.
    ///   - gmtOffset: Hours offset from GMT (e.g. `"-5"`).
    ///   - timezone: Timezone abbreviation (e.g. `"EST"`).
    ///   - foursquareId: Foursquare venue ID. Pass `nil` to omit.
    ///   - latitude: Location latitude. Pass `nil` to omit.
    ///   - longitude: Location longitude. Pass `nil` to omit.
    ///   - shout: Optional comment, max 140 characters. Pass `nil` to omit.
    ///   - rating: Rating from 1.0–5.0 in 0.5 increments. Pass `nil` to omit.
    ///   - facebook: Pass `true` to cross-post to Facebook.
    ///   - twitter: Pass `true` to cross-post to Twitter.
    ///   - foursquare: Pass `true` to cross-post to Foursquare (requires lat/lng).
    /// - Returns: A parameters dictionary with the provided values.
    static func checkinParameters(bid: Int,
                                  gmtOffset: String,
                                  timezone: String,
                                  foursquareId: String?,
                                  latitude: Double?,
                                  longitude: Double?,
                                  shout: String?,
                                  rating: Double?,
                                  facebook: Bool,
                                  twitter: Bool,
                                  foursquare: Bool) -> Parameters {
        var params: Parameters = [
            "bid": bid,
            "gmt_offset": gmtOffset,
            "timezone": timezone,
            "facebook": facebook ? "on" : "off",
            "twitter": twitter ? "on" : "off",
            "foursquare": foursquare ? "on" : "off",
        ]
        if let foursquareId {
            params["foursquare_id"] = foursquareId
        }
        if let latitude {
            params["geolat"] = latitude
        }
        if let longitude {
            params["geolng"] = longitude
        }
        if let shout {
            params["shout"] = shout
        }
        if let rating {
            params["rating"] = rating
        }
        return params
    }

    /// Builds parameters for the add comment API endpoint.
    /// - Parameter comment: The comment text, max 140 characters.
    /// - Returns: A parameters dictionary with the `comment` key set.
    static func addCommentParameters(comment: String) -> Parameters {
        ["comment": comment]
    }

    /// Builds parameters for the pending friends API endpoint.
    /// - Parameters:
    ///   - offset: Zero-based offset for pagination. Pass `nil` to omit.
    ///   - limit: Maximum number of results. Pass `nil` to omit (API defaults to all results).
    /// - Returns: A parameters dictionary with the provided values.
    static func pendingFriendsParameters(withOffset offset: Int?,
                                         limit: Int?) -> Parameters {
        var params: Parameters = [:]

        if let offset {
            params["offset"] = offset
        }
        if let limit {
            params["limit"] = limit
        }

        return params
    }

    /// Builds parameters for the add/remove wish list API endpoints.
    /// - Parameter bid: The Untappd beer ID to add or remove.
    /// - Returns: A parameters dictionary with the `bid` key set.
    static func wishListActionParameters(bid: Int) -> Parameters {
        ["bid": bid]
    }
}
