//
//  CDUntappdAPIClient+UserEndpoints.swift
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

    /// Fetches user information for the given username.
    /// - Parameters:
    ///   - username: The Untappd username to fetch. Pass `nil` to fetch the authenticated user (requires prior authorization).
    ///   - compact: Pass `true` to omit checkins, media, and recent brews. Defaults to `false` for full response.
    /// - Returns: The decoded ``CDUntappdUserInfoResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchUserInfo(forUsername username: String?,
                              compact: Bool) async throws -> CDUntappdUserInfoResponse {
        precondition(
            username != nil || self.isAuthenticated(),
            "Either user authentication or a username are required to query the Untappd API user info endpoint."
        )

        var params = Parameters.userInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.userInfo(username: username,
                                                   parameters: params).asURLRequest()
        let response: CDUntappdUserInfoResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchUserInfo API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches the user's wish list of beers.
    /// - Parameters:
    ///   - username: The Untappd username to fetch the wish list for. Pass `nil` to fetch for the authenticated user.
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    ///   - limit: Maximum number of results to return (max 50, default 25). Defaults to `nil`.
    ///   - sort: How to sort results. Defaults to `nil` (date order).
    /// - Returns: The decoded ``CDUntappdUserWishListResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchUserWishList(forUsername username: String?,
                                  offset: Int?,
                                  limit: Int?,
                                  sort: CDUntappdUserWishListSortType?) async throws -> CDUntappdUserWishListResponse {
        precondition(
            username != nil || self.isAuthenticated(),
            "Either user authentication or a username are required to query the Untappd API user wish list endpoint."
        )

        var params = Parameters.userWishListParameters(withOffset: offset,
                                                       limit: limit,
                                                       sort: sort)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.userWishList(username: username,
                                                       parameters: params).asURLRequest()
        let response: CDUntappdUserWishListResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchUserWishList API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches a list of the user's friends.
    /// - Parameters:
    ///   - username: The Untappd username to fetch friends for. Pass `nil` to fetch for the authenticated user.
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    ///   - limit: Maximum number of results to return (max 25, default 25). Defaults to `nil`.
    /// - Returns: The decoded ``CDUntappdUserFriendsResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchUserFriends(forUsername username: String?,
                                 offset: Int?,
                                 limit: Int?) async throws -> CDUntappdUserFriendsResponse {
        precondition(
            username != nil || self.isAuthenticated(),
            "Either user authentication or a username are required to query the Untappd API user friends endpoint."
        )

        var params = Parameters.userFriendsParameters(withOffset: offset,
                                                      limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.userFriends(username: username,
                                                      parameters: params).asURLRequest()
        let response: CDUntappdUserFriendsResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchUserFriends API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches the user's earned badges.
    /// - Parameters:
    ///   - username: The Untappd username to fetch badges for. Pass `nil` to fetch for the authenticated user.
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    /// - Returns: The decoded ``CDUntappdUserBadgesResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchUserBadges(forUsername username: String?,
                                offset: Int?) async throws -> CDUntappdUserBadgesResponse {
        precondition(
            username != nil || self.isAuthenticated(),
            "Either user authentication or a username are required to query the Untappd API user badges endpoint."
        )

        var params = Parameters.userBadgesParameters(withOffset: offset)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.userBadges(username: username,
                                                     parameters: params).asURLRequest()
        let response: CDUntappdUserBadgesResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchUserBadges API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches a list of beers the user has checked in.
    /// - Parameters:
    ///   - username: The Untappd username to fetch beers for. Pass `nil` to fetch for the authenticated user.
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    ///   - limit: Maximum number of results to return (max 50, default 25). Defaults to `nil`.
    ///   - sort: How to sort results. Defaults to `nil` (date order).
    /// - Returns: The decoded ``CDUntappdUserBeersResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchUserBeers(forUsername username: String?,
                               offset: Int?,
                               limit: Int?,
                               sort: CDUntappdUserBeersSortType?) async throws -> CDUntappdUserBeersResponse {
        precondition(
            username != nil || self.isAuthenticated(),
            "Either user authentication or a username are required to query the Untappd API user beers endpoint."
        )

        var params = Parameters.userBeersParameters(withOffset: offset,
                                                    limit: limit,
                                                    sort: sort)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.userBeers(username: username,
                                                    parameters: params).asURLRequest()
        let response: CDUntappdUserBeersResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchUserBeers API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches the authenticated user's friend check-in activity feed.
    /// - Parameters:
    ///   - maxId: Return checkins with ID ≤ maxId (older). Pass `nil` to omit.
    ///   - minId: Return checkins with ID ≥ minId (newer). Pass `nil` to omit.
    ///   - limit: Maximum results (default 25, max 50). Pass `nil` to omit.
    /// - Returns: The decoded ``CDUntappdActivityFeedResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchActivityFeed(maxId: Int?,
                                  minId: Int?,
                                  limit: Int?) async throws -> CDUntappdActivityFeedResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to query the Untappd API activity feed endpoint."
        )

        var params = Parameters.activityFeedParameters(maxId: maxId, minId: minId, limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.activityFeed(parameters: params).asURLRequest()
        let response: CDUntappdActivityFeedResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchActivityFeed API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches a user's check-in history.
    /// - Parameters:
    ///   - username: The Untappd username to fetch check-ins for. Pass `nil` to fetch for the authenticated user.
    ///   - maxId: Return checkins with ID ≤ maxId (older). Pass `nil` to omit.
    ///   - minId: Return checkins with ID ≥ minId (newer). Pass `nil` to omit.
    ///   - limit: Maximum results (default 25, max 25). Pass `nil` to omit.
    /// - Returns: The decoded ``CDUntappdActivityFeedResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchUserActivityFeed(forUsername username: String?,
                                      maxId: Int?,
                                      minId: Int?,
                                      limit: Int?) async throws -> CDUntappdActivityFeedResponse {
        precondition(
            username != nil || self.isAuthenticated(),
            "Either user authentication or a username are required to query the Untappd API user activity feed endpoint."
        )

        var params = Parameters.activityFeedParameters(maxId: maxId, minId: minId, limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.userActivityFeed(username: username,
                                                           parameters: params).asURLRequest()
        let response: CDUntappdActivityFeedResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchUserActivityFeed API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches the authenticated user's toast and comment notifications.
    /// - Parameters:
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    ///   - limit: Maximum number of results to return (max 25, default 25). Defaults to `nil`.
    /// - Returns: The decoded ``CDUntappdNotificationsResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    public func fetchNotifications(offset: Int?,
                                   limit: Int?) async throws -> CDUntappdNotificationsResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to query the Untappd API notifications endpoint."
        )

        var params = Parameters.notificationsParameters(withOffset: offset, limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.notifications(parameters: params).asURLRequest()
        let response: CDUntappdNotificationsResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            logger.error("fetchNotifications API error: \(metadata.description(), privacy: .public)")
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }
}
