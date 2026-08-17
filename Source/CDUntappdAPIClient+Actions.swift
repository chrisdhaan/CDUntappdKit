//
//  CDUntappdAPIClient+Actions.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/16/26.
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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
private let logger = Logger(subsystem: CDUntappdKitBundleIdentifier, category: "APIClient")

extension CDUntappdAPIClient {

    /// Posts a new beer check-in.
    /// - Parameters:
    ///   - bid: The Untappd beer ID to check in.
    ///   - gmtOffset: Hours offset from GMT (e.g. `"-5"`).
    ///   - timezone: Timezone abbreviation (e.g. `"EST"`).
    ///   - foursquareId: Foursquare venue ID. Pass `nil` to omit.
    ///   - latitude: Location latitude. Pass `nil` to omit.
    ///   - longitude: Location longitude. Pass `nil` to omit.
    ///   - shout: Optional comment, max 140 characters. Pass `nil` to omit.
    ///   - rating: Rating from 1.0–5.0 in 0.5 increments. Pass `nil` to omit.
    ///   - facebook: Pass `true` to cross-post to Facebook. Defaults to `false`.
    ///   - twitter: Pass `true` to cross-post to Twitter. Defaults to `false`.
    ///   - foursquare: Pass `true` to cross-post to Foursquare (requires lat/lng). Defaults to `false`.
    /// - Returns: The decoded ``CDUntappdCheckinResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func addCheckin(bid: Int,
                           gmtOffset: String,
                           timezone: String,
                           foursquareId: String?,
                           latitude: Double?,
                           longitude: Double?,
                           shout: String?,
                           rating: Double?,
                           facebook: Bool = false,
                           twitter: Bool = false,
                           foursquare: Bool = false) async throws -> CDUntappdCheckinResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to post an Untappd check-in."
        )

        var params = Parameters.checkinParameters(bid: bid, gmtOffset: gmtOffset, timezone: timezone,
                                                  foursquareId: foursquareId, latitude: latitude,
                                                  longitude: longitude, shout: shout, rating: rating,
                                                  facebook: facebook, twitter: twitter, foursquare: foursquare)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.addCheckin(parameters: params).asURLRequest()
        let response: CDUntappdCheckinResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("addCheckin API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Toggles a toast on a check-in (calling it again removes the toast).
    /// - Parameter checkinId: The Untappd check-in ID to toast.
    /// - Returns: The decoded ``CDUntappdToastResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func toast(checkinId: Int) async throws -> CDUntappdToastResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to toast an Untappd check-in."
        )

        var params = Parameters()
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.toast(checkinId: checkinId, parameters: params).asURLRequest()
        let response: CDUntappdToastResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("toast API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Adds a comment to a check-in.
    /// - Parameters:
    ///   - checkinId: The Untappd check-in ID to comment on.
    ///   - comment: The comment text, max 140 characters.
    /// - Returns: The decoded ``CDUntappdAddCommentResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func addComment(toCheckinId checkinId: Int, comment: String) async throws -> CDUntappdAddCommentResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to comment on an Untappd check-in."
        )

        var params = Parameters.addCommentParameters(comment: comment)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.addComment(checkinId: checkinId, parameters: params).asURLRequest()
        let response: CDUntappdAddCommentResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("addComment API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Removes a comment from a check-in.
    /// - Parameter commentId: The Untappd comment ID to remove.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func removeComment(commentId: Int) async throws {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to remove an Untappd check-in comment."
        )

        var params = Parameters()
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.deleteComment(commentId: commentId, parameters: params).asURLRequest()
        // No metadata error-check here: this endpoint returns HTTP 204 with no body, so
        // status-code validation (inside perform(_:)) is the only error signal available.
        try await self.session.perform(request)
    }

    /// Fetches the authenticated user's pending friend requests.
    /// - Parameters:
    ///   - offset: The zero-based offset for pagination. Defaults to `nil` (start from 0).
    ///   - limit: Maximum number of results to return. Defaults to `nil` (all results).
    /// - Returns: The decoded ``CDUntappdPendingFriendsResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func fetchPendingFriends(offset: Int?,
                                    limit: Int?) async throws -> CDUntappdPendingFriendsResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to query the Untappd API pending friends endpoint."
        )

        var params = Parameters.pendingFriendsParameters(withOffset: offset, limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.pendingFriends(parameters: params).asURLRequest()
        let response: CDUntappdPendingFriendsResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchPendingFriends API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Sends a friend request to a user.
    /// - Parameter targetId: The target user's Untappd user ID.
    /// - Returns: The decoded ``CDUntappdActionResultResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func addFriend(targetId: Int) async throws -> CDUntappdActionResultResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to send an Untappd friend request."
        )

        var params = Parameters()
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.addFriend(targetId: targetId, parameters: params).asURLRequest()
        let response: CDUntappdActionResultResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("addFriend API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Removes a friend.
    /// - Parameter targetId: The target user's Untappd user ID.
    /// - Returns: The decoded ``CDUntappdActionResultResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func removeFriend(targetId: Int) async throws -> CDUntappdActionResultResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to remove an Untappd friend."
        )

        var params = Parameters()
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.removeFriend(targetId: targetId, parameters: params).asURLRequest()
        let response: CDUntappdActionResultResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("removeFriend API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Accepts a pending friend request.
    /// - Parameter targetId: The requesting user's Untappd user ID.
    /// - Returns: The decoded ``CDUntappdActionResultResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func acceptFriend(targetId: Int) async throws -> CDUntappdActionResultResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to accept an Untappd friend request."
        )

        var params = Parameters()
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.acceptFriend(targetId: targetId, parameters: params).asURLRequest()
        let response: CDUntappdActionResultResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("acceptFriend API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Rejects a pending friend request.
    /// - Parameter targetId: The requesting user's Untappd user ID.
    /// - Returns: The decoded ``CDUntappdActionResultResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func rejectFriend(targetId: Int) async throws -> CDUntappdActionResultResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to reject an Untappd friend request."
        )

        var params = Parameters()
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.rejectFriend(targetId: targetId, parameters: params).asURLRequest()
        let response: CDUntappdActionResultResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("rejectFriend API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Adds a beer to the authenticated user's wish list.
    /// - Parameter bid: The Untappd beer ID to add.
    /// - Returns: The decoded ``CDUntappdActionResultResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func addToWishList(bid: Int) async throws -> CDUntappdActionResultResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to add a beer to the Untappd wish list."
        )

        var params = Parameters.wishListActionParameters(bid: bid)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.addToWishList(parameters: params).asURLRequest()
        let response: CDUntappdActionResultResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("addToWishList API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Removes a beer from the authenticated user's wish list.
    /// - Parameter bid: The Untappd beer ID to remove.
    /// - Returns: The decoded ``CDUntappdActionResultResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func removeFromWishList(bid: Int) async throws -> CDUntappdActionResultResponse {
        precondition(
            self.isAuthenticated(),
            "Authentication is required to remove a beer from the Untappd wish list."
        )

        var params = Parameters.wishListActionParameters(bid: bid)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.removeFromWishList(parameters: params).asURLRequest()
        let response: CDUntappdActionResultResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("removeFromWishList API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }
}
