//
//  CDUntappdAPIClient+ContentEndpoints.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/29/26.
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
import os.log

private let logger = Logger(subsystem: CDUntappdKitBundleIdentifier, category: "APIClient")

extension CDUntappdAPIClient {

    /// Fetches information for a beer by its Untappd ID.
    /// - Parameters:
    ///   - bid: The Untappd beer ID (bid).
    ///   - compact: Pass `true` to omit extended fields. Defaults to `false`.
    /// - Returns: The decoded ``CDUntappdBeerInfoResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchBeerInfo(forBid bid: Int,
                              compact: Bool) async throws -> CDUntappdBeerInfoResponse {
        var params = Parameters.beerInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.beerInfo(bid: bid,
                                                   parameters: params).asURLRequest()
        let response: CDUntappdBeerInfoResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchBeerInfo API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches information for a brewery by its Untappd ID.
    /// - Parameters:
    ///   - breweryId: The Untappd brewery ID.
    ///   - compact: Pass `true` to omit extended fields. Defaults to `false`.
    /// - Returns: The decoded ``CDUntappdBreweryInfoResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchBreweryInfo(forBreweryId breweryId: Int,
                                 compact: Bool) async throws -> CDUntappdBreweryInfoResponse {
        var params = Parameters.breweryInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.breweryInfo(breweryId: breweryId,
                                                      parameters: params).asURLRequest()
        let response: CDUntappdBreweryInfoResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchBreweryInfo API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches information for a venue by its Untappd ID.
    /// - Parameters:
    ///   - venueId: The Untappd venue ID.
    ///   - compact: Pass `true` to omit extended fields. Defaults to `false`.
    /// - Returns: The decoded ``CDUntappdVenueInfoResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchVenueInfo(forVenueId venueId: Int,
                               compact: Bool) async throws -> CDUntappdVenueInfoResponse {
        var params = Parameters.venueInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.venueInfo(venueId: venueId,
                                                    parameters: params).asURLRequest()
        let response: CDUntappdVenueInfoResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchVenueInfo API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Searches for beers by name.
    /// - Parameters:
    ///   - query: The search term.
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    ///   - limit: Maximum number of results to return (max 50, default 25). Defaults to `nil`.
    ///   - sort: How to sort results. Defaults to `nil` (date order).
    /// - Returns: The decoded ``CDUntappdBeerSearchResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func searchBeers(query: String,
                            offset: Int?,
                            limit: Int?,
                            sort: CDUntappdBeerSearchSortType?) async throws -> CDUntappdBeerSearchResponse {
        var params = Parameters.beerSearchParameters(query: query,
                                                     offset: offset,
                                                     limit: limit,
                                                     sort: sort)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.beerSearch(parameters: params).asURLRequest()
        let response: CDUntappdBeerSearchResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("searchBeers API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Searches for breweries by name.
    /// - Parameters:
    ///   - query: The search term.
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    /// - Returns: The decoded ``CDUntappdBrewerySearchResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func searchBreweries(query: String,
                                offset: Int?) async throws -> CDUntappdBrewerySearchResponse {
        var params = Parameters.brewerySearchParameters(query: query,
                                                        offset: offset)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.brewerySearch(parameters: params).asURLRequest()
        let response: CDUntappdBrewerySearchResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("searchBreweries API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches recent check-ins for a beer.
    /// - Parameters:
    ///   - bid: The Untappd beer ID.
    ///   - maxId: Return checkins with ID ≤ maxId (older). Pass `nil` to omit.
    ///   - minId: Return checkins with ID ≥ minId (newer). Pass `nil` to omit.
    ///   - limit: Maximum results (default 25, max 25). Pass `nil` to omit.
    /// - Returns: The decoded ``CDUntappdActivityFeedResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchBeerActivityFeed(forBid bid: Int,
                                      maxId: Int?,
                                      minId: Int?,
                                      limit: Int?) async throws -> CDUntappdActivityFeedResponse {
        var params = Parameters.activityFeedParameters(maxId: maxId, minId: minId, limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.beerActivityFeed(bid: bid,
                                                           parameters: params).asURLRequest()
        let response: CDUntappdActivityFeedResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchBeerActivityFeed API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches recent check-ins for a brewery.
    /// - Parameters:
    ///   - breweryId: The Untappd brewery ID.
    ///   - maxId: Return checkins with ID ≤ maxId (older). Pass `nil` to omit.
    ///   - minId: Return checkins with ID ≥ minId (newer). Pass `nil` to omit.
    ///   - limit: Maximum results (default 25, max 25). Pass `nil` to omit.
    /// - Returns: The decoded ``CDUntappdActivityFeedResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchBreweryActivityFeed(forBreweryId breweryId: Int,
                                         maxId: Int?,
                                         minId: Int?,
                                         limit: Int?) async throws -> CDUntappdActivityFeedResponse {
        var params = Parameters.activityFeedParameters(maxId: maxId, minId: minId, limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.breweryActivityFeed(breweryId: breweryId,
                                                              parameters: params).asURLRequest()
        let response: CDUntappdActivityFeedResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchBreweryActivityFeed API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches recent check-ins at a venue.
    /// - Parameters:
    ///   - venueId: The Untappd venue ID.
    ///   - maxId: Return checkins with ID ≤ maxId (older). Pass `nil` to omit.
    ///   - minId: Return checkins with ID ≥ minId (newer). Pass `nil` to omit.
    ///   - limit: Maximum results (default 25, max 25). Pass `nil` to omit.
    /// - Returns: The decoded ``CDUntappdActivityFeedResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchVenueActivityFeed(forVenueId venueId: Int,
                                       maxId: Int?,
                                       minId: Int?,
                                       limit: Int?) async throws -> CDUntappdActivityFeedResponse {
        var params = Parameters.activityFeedParameters(maxId: maxId, minId: minId, limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.venueActivityFeed(venueId: venueId,
                                                            parameters: params).asURLRequest()
        let response: CDUntappdActivityFeedResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchVenueActivityFeed API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Looks up an Untappd venue by its Foursquare v2 venue ID.
    /// - Parameter foursquareId: The Foursquare v2 venue ID.
    /// - Returns: The decoded ``CDUntappdFoursquareLookupResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func lookupVenue(byFoursquareId foursquareId: String) async throws -> CDUntappdFoursquareLookupResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to query the Untappd API Foursquare venue lookup endpoint."
        )

        var params = Parameters()
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.foursquareLookup(venueId: foursquareId,
                                                           parameters: params).asURLRequest()
        let response: CDUntappdFoursquareLookupResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("lookupVenue(byFoursquareId:) API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }
}
