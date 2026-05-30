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

import Alamofire
#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif

@MainActor
public class CDUntappdAPIClient: NSObject, @unchecked Sendable {

    private lazy var manager: Alamofire.Session = {
        return Alamofire.Session()
    }()
    private let oAuthClient: CDUntappdOAuthClient!

    // MARK: - Initializers

    ///
    /// Initializes a new CDUntappdAPIClient object.
    ///
    /// - parameters:
    ///   - clientId: (**Required**) A unique identifier for the Untappd application used for authenticating with the Untappd API.
    ///   - clientSecret: (**Required**) A unique key for the Untappd application used for authenticating with the Untappd API. **Do not share this key**.
    ///   - redirectUrl: (**Required**) A url to redirect the Untappd application to during the authentication process.
    ///
    /// - returns: Void
    ///
    public init(clientId: String!,
                clientSecret: String!,
                redirectUrl: String!) {
        assert((clientId != nil && clientId != "") &&
            (clientSecret != nil && clientSecret != "") &&
            (redirectUrl != nil && redirectUrl != ""), "A clientId, clientSecret, and redirectUrl are required to query the Untappd Developers API oauth endpoint.")
        self.oAuthClient = CDUntappdOAuthClient(clientId: clientId,
                                                clientSecret: clientSecret,
                                                redirectUrl: redirectUrl)
        super.init()
    }

    // MARK: - Authentication Methods

    ///
    /// Attempts to authenticate the Untappd application credentials with the Untappd API if the Untappd application has not already authenticated.
    ///
    /// - returns: Void
    ///
#if os(iOS)
    @available(iOSApplicationExtension, unavailable)
    public func authenticate() {
        if let tvc = UIApplication.topViewController(),
            tvc.parent as? UINavigationController == nil,
            self.isAuthenticated() == false {

            let oAuthStoryboard = UIStoryboard(name: CDUntappdStoryboardIdentifier.oAuth,
                                               bundle: Bundle(identifier: CDUntappdKitBundleIdentifier))
            if let oAuthNavigationController = oAuthStoryboard.instantiateViewController(withIdentifier: CDUntappdNavigationControllerIdentifier.oAuth) as? UINavigationController {
                if let oAuthViewController = oAuthNavigationController.topViewController as? CDUntappdOAuthViewController {
                    oAuthViewController.oAuthClient = self.oAuthClient
                    oAuthViewController.onAuthorization = { (_, error) in

                        if let error = error {
                        }
                        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                    }
                }
                tvc.present(oAuthNavigationController, animated: true, completion: nil)
            }
        }
    }
#endif

    ///
    /// Determines whether or not the Untappd application has successfully authenticated with the Untappd API.
    ///
    /// - returns: Bool
    ///
    public func isAuthenticated() -> Bool {
        return self.oAuthClient.isAuthorized()
    }

    ///
    /// Removes the Untappd API authentication credentials.
    ///
    /// - returns: Void
    ///
    public func unauthenticate() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: CDUntappdDefaults.accessToken)
        userDefaults.synchronize()
    }

    // MARK: - Untappd API Methods

    ///
    /// This method will return the user information for a selected user. When using authentication, not passing the username parameter will return the authenticated users' information.
    ///
    /// - parameters:
    ///   - forUsername: (**Required**) The username for the Untappd API to query. Can be (Optional) if an access token is provided for an authenticated user.
    ///   - compact: (**Required**) Pass *true* to only show the user infomation, removing the *checkins*, *media*, and *recent_brews* attributes.
    ///
    /// - returns: CDUntappdUserInfoResponse
    ///
    /// - throws: CDUntappdKitError if the request fails or the response is invalid.
    ///
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func fetchUserInfo(forUsername username: String?,
                              compact: Bool) async throws -> CDUntappdUserInfoResponse {
        assert(username != nil || self.isAuthenticated(), "Either user authentication or a username are required to query the Untappd API user info endpoint.")

        var params = Parameters.userInfoParameters(isCompact: compact)
        params = self.oAuthClient.addTokens(toParameters: params)

        let response = try await self.manager
            .request(CDUntappdRouter.userInfo(username: username,
                                              parameters: params))
            .validate()
            .serializingDecodable(CDUntappdUserInfoResponse.self)
            .value
        
        if let metadata = response.metadata,
            metadata.hasError() {
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    ///
    /// This method will return a list of 25 of the user's wish listed beers. When using authentication, not passing the username parameter will return the authenticated users' information.
    ///
    /// - parameters:
    ///   - forUsername: (**Required**) The username for the Untappd API to query. Can be (Optional) if an access token is provided for an authenticated user.
    ///   - offset: (Optional) The numeric offset that you what results to start.
    ///   - limit: (Optional) The number of results to return, max of 50, default is 25.
    ///   - sort: (Optional) Results can be sorted using the following values (1) date - sorts by date (default), (2) checkin - sorted by highest checkin, (3) highest_rated - sorts by global rating descending order, (4) lowest_rated - sorts by global rating ascending order, (5) highest_abv - highest ABV from the wishlist, (6) lowest_abv - lowest ABV from the wishlist
    ///
    /// - returns: CDUntappdUserWishListResponse
    ///
    /// - throws: CDUntappdKitError if the request fails or the response is invalid.
    ///
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func fetchUserWishList(forUsername username: String?,
                                  offset: Int?,
                                  limit: Int?,
                                  sort: CDUntappdUserWishListSortType?) async throws -> CDUntappdUserWishListResponse {
        assert(username != nil || self.isAuthenticated(), "Either user authentication or a username are required to query the Untappd API user wish list endpoint.")

        var params = Parameters.userWishListParameters(withOffset: offset,
                                                       limit: limit,
                                                       sort: sort)
        params = self.oAuthClient.addTokens(toParameters: params)

        let response = try await self.manager
            .request(CDUntappdRouter.userWishList(username: username,
                                                  parameters: params))
            .validate()
            .serializingDecodable(CDUntappdUserWishListResponse.self)
            .value
        
        if let metadata = response.metadata,
            metadata.hasError() {
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    ///
    /// This method will return a list of the user's friends. When using authentication, not passing the username parameter will return the authenticated users' information.
    ///
    /// - parameters:
    ///   - forUsername: (**Required**) The username for the Untappd API to query. Can be (Optional) if an access token is provided for an authenticated user.
    ///   - offset: (Optional) The numeric offset that you what results to start.
    ///   - limit: (Optional) The number of records that you will return (max 25, default 25).
    ///
    /// - returns: CDUntappdUserFriendsResponse
    ///
    /// - throws: CDUntappdKitError if the request fails or the response is invalid.
    ///
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func fetchUserFriends(forUsername username: String?,
                                 offset: Int?,
                                 limit: Int?) async throws -> CDUntappdUserFriendsResponse {
        assert(username != nil || self.isAuthenticated(), "Either user authentication or a username are required to query the Untappd API user friends endpoint.")

        var params = Parameters.userFriendsParameters(withOffset: offset,
                                                      limit: limit)
        params = self.oAuthClient.addTokens(toParameters: params)

        let response = try await self.manager
            .request(CDUntappdRouter.userFriends(username: username,
                                                 parameters: params))
            .validate()
            .serializingDecodable(CDUntappdUserFriendsResponse.self)
            .value
        
        if let metadata = response.metadata,
            metadata.hasError() {
            throw CDUntappdKitError.apiError(metadata.description())
        }

        return response
    }

    ///
    /// Deprecated: With async/await, use Swift's structured concurrency cancellation instead.
    /// Call `Task.cancel()` on the Task that wraps the async API call to cancel it.
    ///
    /// - returns: Void
    ///
    @available(*, deprecated, message: "Use Task.cancel() with async/await API instead")
    public func cancelAllPendingAPIRequests() {
        self.manager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
}
