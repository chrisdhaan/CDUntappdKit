//
//  CDUntappdAPIClient.swift
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
import os.log
#if os(iOS) || os(visionOS)
    import UIKit
#endif

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
private let logger = Logger(subsystem: CDUntappdKitBundleIdentifier, category: "APIClient")

/// The primary API client for interacting with the Untappd API.
///
/// Create one instance per application and hold a strong reference to it.
/// All methods are `@MainActor` — call them from the main thread or from a `Task`.
@MainActor
public class CDUntappdAPIClient {

    private let session: CDUntappdURLSession
    private let oAuthClient: CDUntappdOAuthClient

    // MARK: - Initializers

    /// Creates an Untappd API client.
    /// - Parameters:
    ///   - clientId: Your Untappd application client ID.
    ///   - clientSecret: Your Untappd application client secret. Do not share this key.
    ///   - redirectUrl: The OAuth redirect URL registered with your application.
    public convenience init(clientId: String,
                            clientSecret: String,
                            redirectUrl: String) {
        self.init(clientId: clientId,
                  clientSecret: clientSecret,
                  redirectUrl: redirectUrl,
                  urlSession: URLSession(configuration: .default))
    }

    init(clientId: String,
         clientSecret: String,
         redirectUrl: String,
         urlSession: URLSession) {
        precondition(!clientId.isEmpty && !clientSecret.isEmpty && !redirectUrl.isEmpty,
                     "A clientId, clientSecret, and redirectUrl are required to query the Untappd Developers API oauth endpoint.")
        self.oAuthClient = CDUntappdOAuthClient(clientId: clientId,
                                                clientSecret: clientSecret,
                                                redirectUrl: redirectUrl)
        self.session = CDUntappdURLSession(session: urlSession)
    }

    // MARK: - Authentication Methods

    // Presents an OAuth authentication flow to authorize access to the Untappd API.
    //
    // This method displays a ``CDUntappdOAuthViewController`` with a `WKWebView`-based OAuth flow.
    // On iOS and visionOS only.
    #if os(iOS) || os(visionOS)
        @available(iOSApplicationExtension, unavailable)
        public func authenticate() {
            if let tvc = UIApplication.topViewController(),
               tvc.parent as? UINavigationController == nil,
               self.isAuthenticated() == false {

                let oAuthStoryboard = UIStoryboard(name: CDUntappdStoryboardIdentifier.oAuth,
                                                   bundle: Bundle(identifier: CDUntappdKitBundleIdentifier))
                if let oAuthNavigationController = oAuthStoryboard.instantiateViewController(
                    withIdentifier: CDUntappdNavigationControllerIdentifier.oAuth
                ) as? UINavigationController {
                    if let oAuthViewController = oAuthNavigationController.topViewController as? CDUntappdOAuthViewController {
                        oAuthViewController.oAuthClient = self.oAuthClient
                        oAuthViewController.onAuthorization = { _, _ in
                            UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                        }
                    }
                    tvc.present(oAuthNavigationController, animated: true, completion: nil)
                }
            }
        }
    #endif

    /// Checks whether the client has an active access token.
    /// - Returns: `true` if an access token is stored in the Keychain.
    public func isAuthenticated() -> Bool {
        self.oAuthClient.isAuthorized()
    }

    /// Clears the stored access token from the Keychain.
    public func unauthenticate() {
        CDUntappdKeychain.delete(forKey: CDUntappdDefaults.accessToken)
    }

    // MARK: - Untappd API Methods

    /// Fetches user information for the given username.
    /// - Parameters:
    ///   - username: The Untappd username to fetch. Pass `nil` to fetch the authenticated user (requires prior authorization).
    ///   - compact: Pass `true` to omit checkins, media, and recent brews. Defaults to `false` for full response.
    /// - Returns: The decoded ``CDUntappdUserInfoResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchUserInfo API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchUserWishList API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchUserFriends API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchUserBadges API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchUserBeers API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Fetches information for a beer by its Untappd ID.
    /// - Parameters:
    ///   - bid: The Untappd beer ID (bid).
    ///   - compact: Pass `true` to omit extended fields. Defaults to `false`.
    /// - Returns: The decoded ``CDUntappdBeerInfoResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func fetchBeerInfo(forBid bid: Int,
                              compact: Bool) async throws -> CDUntappdBeerInfoResponse {
        var params = Parameters.beerInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.beerInfo(bid: bid,
                                                   parameters: params).asURLRequest()
        let response: CDUntappdBeerInfoResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchBeerInfo API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func fetchBreweryInfo(forBreweryId breweryId: Int,
                                 compact: Bool) async throws -> CDUntappdBreweryInfoResponse {
        var params = Parameters.breweryInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.breweryInfo(breweryId: breweryId,
                                                      parameters: params).asURLRequest()
        let response: CDUntappdBreweryInfoResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchBreweryInfo API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func fetchVenueInfo(forVenueId venueId: Int,
                               compact: Bool) async throws -> CDUntappdVenueInfoResponse {
        var params = Parameters.venueInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.venueInfo(venueId: venueId,
                                                    parameters: params).asURLRequest()
        let response: CDUntappdVenueInfoResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchVenueInfo API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("searchBeers API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func searchBreweries(query: String,
                                offset: Int?) async throws -> CDUntappdBrewerySearchResponse {
        var params = Parameters.brewerySearchParameters(query: query,
                                                        offset: offset)
        params = self.oAuthClient.addTokens(toParameters: params)

        let request = try CDUntappdRouter.brewerySearch(parameters: params).asURLRequest()
        let response: CDUntappdBrewerySearchResponse = try await self.session.perform(request)

        if let metadata = response.metadata,
           metadata.hasError() {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("searchBreweries API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchActivityFeed API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchUserActivityFeed API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchBeerActivityFeed API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchBreweryActivityFeed API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchVenueActivityFeed API error: \(metadata.description(), privacy: .public)")
            }
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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("fetchNotifications API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    /// Looks up an Untappd venue by its Foursquare v2 venue ID.
    /// - Parameter foursquareId: The Foursquare v2 venue ID.
    /// - Returns: The decoded ``CDUntappdFoursquareLookupResponse``.
    /// - Throws: ``CDUntappdKitError`` if the request fails or the API returns an error.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
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
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                logger.error("lookupVenue(byFoursquareId:) API error: \(metadata.description(), privacy: .public)")
            }
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

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

    /// Deprecated: Use Swift structured concurrency instead.
    ///
    /// With async/await, call `Task.cancel()` on the task that wraps the async API call.
    ///
    /// Suspends until all in-flight requests have actually finished cancelling, not just until
    /// cancellation has been requested.
    @available(*, deprecated, message: "Use Task.cancel() with async/await API instead")
    public func cancelAllPendingAPIRequests() async {
        await self.session.cancelAllTasks()
    }
}
