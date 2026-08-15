//
//  CDUntappdOAuthClient.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/15/17.
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
private let logger = Logger(subsystem: CDUntappdKitBundleIdentifier, category: "OAuthClient")

/// Handles OAuth 2.0 authentication with the Untappd API.
///
/// Manages access tokens stored in the Keychain and adds them to API requests.
public class CDUntappdOAuthClient: NSObject, @unchecked Sendable {

    private let session: CDUntappdURLSession

    /// Your Untappd application client ID.
    public let clientId: String!
    /// Your Untappd application client secret. Do not share this value.
    public let clientSecret: String!
    /// The OAuth redirect URL registered with your Untappd application.
    public let redirectUrl: String!

    // MARK: - Initializers

    /// Creates an OAuth client for Untappd API authentication.
    /// - Parameters:
    ///   - clientId: Your Untappd application client ID.
    ///   - clientSecret: Your Untappd application client secret.
    ///   - redirectUrl: The OAuth redirect URL registered with your application.
    public convenience init(clientId: String!,
                            clientSecret: String!,
                            redirectUrl: String!) {
        self.init(clientId: clientId, clientSecret: clientSecret,
                  redirectUrl: redirectUrl, urlSession: URLSession(configuration: .default))
    }

    /// Creates an OAuth client with an injected `URLSession`, for testing.
    init(clientId: String!,
         clientSecret: String!,
         redirectUrl: String!,
         urlSession: URLSession) {
        assert((clientId != nil && clientId != "") &&
            (clientSecret != nil && clientSecret != "") &&
            (redirectUrl != nil && redirectUrl != ""),
            "A clientId, clientSecret, and redirectUrl are required to query the Untappdd Developers API oauth endpoint.")
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUrl = redirectUrl
        self.session = CDUntappdURLSession(session: urlSession)
    }

    // MARK: - Authorization Methods

    /// Exchanges an OAuth authorization code for an access token.
    ///
    /// - Parameter code: The authorization code received from the OAuth redirect.
    /// - Throws: ``CDUntappdKitError`` if the client isn't configured with valid credentials,
    ///   `code` is empty, the network request fails, or the response can't be decoded.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    public func authorize(withCode code: String) async throws {
        guard let clientId, !clientId.isEmpty,
              let clientSecret, !clientSecret.isEmpty,
              let redirectUrl, !redirectUrl.isEmpty,
              !code.isEmpty
        else {
            throw CDUntappdKitError.invalidCredentials(
                "A clientId, clientSecret, redirectUrl, and code are required to authorize."
            )
        }

        let params: Parameters = ["client_id": clientId,
                                  "client_secret": clientSecret,
                                  "response_type": "code",
                                  "redirect_url": redirectUrl,
                                  "code": code]

        let urlRequest = try CDUntappdOAuthRouter.authorize(parameters: params).asURLRequest()
        let oAuthCredential: CDUntappdOAuthCredential = try await self.session.perform(urlRequest)
        Self.storeAccessToken(from: oAuthCredential)
    }

    /// Exchanges an OAuth authorization code for an access token.
    ///
    /// - Parameters:
    ///   - code: The authorization code received from the OAuth provider.
    ///   - completion: A closure called with the result, on the main thread. Passes `true` and
    ///     `nil` on success, `false` and an error on failure.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    @available(*, deprecated, renamed: "authorize(withCode:)")
    public func authorize(withCode code: String!, completion: @escaping (Bool?, (any Error)?) -> Void) {
        Task { @MainActor in
            do {
                try await self.authorize(withCode: code ?? "")
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
    }

    /// Stores the credential's access token in the Keychain, or clears any previously stored
    /// token if the response didn't include one - matching the prior `UserDefaults.set(nil,
    /// forKey:)` behavior, which is equivalent to `removeObject(forKey:)`.
    private static func storeAccessToken(from credential: CDUntappdOAuthCredential) {
        let keychainWriteSucceeded: Bool = if let token = credential.accessToken {
            CDUntappdKeychain.set(token, forKey: CDUntappdDefaults.accessToken)
        } else {
            CDUntappdKeychain.delete(forKey: CDUntappdDefaults.accessToken)
        }
        if !keychainWriteSucceeded, #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *) {
            logger.error("Failed to store OAuth access token in the Keychain.")
        }
    }

    /// Checks if an access token is stored.
    /// - Returns: `true` if an access token exists in the Keychain.
    public func isAuthorized() -> Bool {
        CDUntappdKeychain.string(forKey: CDUntappdDefaults.accessToken) != nil
    }

    /// Returns the stored access token.
    /// - Returns: The access token string, or `nil` if no token is stored.
    public func accessToken() -> String? {
        CDUntappdKeychain.string(forKey: CDUntappdDefaults.accessToken)
    }

    /// Adds authentication tokens to API request parameters.
    ///
    /// If an access token is available, adds it with key `access_token`.
    /// Otherwise, adds client ID and secret with keys `client_id` and `client_secret`.
    /// - Parameter parameters: The parameters dictionary to modify.
    /// - Returns: The updated parameters dictionary.
    public func addTokens(toParameters parameters: Parameters) -> Parameters {
        var params = parameters

        if let accessToken = self.accessToken() {
            params["access_token"] = accessToken
        } else {
            params["client_id"] = self.clientId
            params["client_secret"] = self.clientSecret
        }

        return params
    }
}
