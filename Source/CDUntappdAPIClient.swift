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
