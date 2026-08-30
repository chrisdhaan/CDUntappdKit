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

private let logger = Logger(subsystem: CDUntappdKitBundleIdentifier, category: "APIClient")

/// The primary API client for interacting with the Untappd API.
///
/// Create one instance per application and hold a strong reference to it.
/// All methods are `@MainActor` — call them from the main thread or from a `Task`.
@MainActor
public class CDUntappdAPIClient {

    let session: CDUntappdURLSession
    let oAuthClient: CDUntappdOAuthClient

    // MARK: - Initializers

    /// Creates an Untappd API client backed by a caller-supplied `URLSession`.
    ///
    /// Intended for tests: pass a session built around `CDUntappdMockURLProtocol.makeSession()`
    /// (from the `CDUntappdKitTesting` product) to mock network calls without hitting the real API.
    /// - Parameters:
    ///   - clientId: Your Untappd application client ID.
    ///   - clientSecret: Your Untappd application client secret. Do not share this key.
    ///   - redirectUrl: The OAuth redirect URL registered with your application.
    ///   - urlSession: The `URLSession` used to perform requests.
    ///   - retryConfiguration: Configuration for automatic retry with exponential backoff on
    ///     transient failures and rate-limit responses. Defaults to `.disabled`.
    ///   - eventMonitors: Observers notified of request/response lifecycle events. Defaults to none.
    ///   - requestAdapters: Adapters run in order to mutate each outgoing request before it is sent.
    ///     Defaults to none.
    ///   - cacheConfiguration: Configuration for the built-in in-memory response cache applied to
    ///     `GET` requests. Defaults to `.disabled`.
    ///   - decoderConfiguration: Configuration for `JSONDecoder`'s key and date decoding strategies.
    ///     Defaults to `.default`.
    public init(clientId: String, clientSecret: String, redirectUrl: String, urlSession: URLSession,
                retryConfiguration: CDUntappdRetryConfiguration = .disabled,
                eventMonitors: [any CDUntappdEventMonitor] = [], requestAdapters: [any CDUntappdRequestAdapter] = [],
                cacheConfiguration: CDUntappdCacheConfiguration = .disabled,
                decoderConfiguration: CDUntappdDecoderConfiguration = .default) {
        precondition(!clientId.isEmpty && !clientSecret.isEmpty && !redirectUrl.isEmpty,
                     "A clientId, clientSecret, and redirectUrl are required to query the Untappd Developers API oauth endpoint.")
        self.oAuthClient = CDUntappdOAuthClient(clientId: clientId, clientSecret: clientSecret, redirectUrl: redirectUrl,
                                                retryConfiguration: retryConfiguration, eventMonitors: eventMonitors,
                                                requestAdapters: requestAdapters, cacheConfiguration: cacheConfiguration,
                                                decoderConfiguration: decoderConfiguration)
        self.session = CDUntappdURLSession(session: urlSession, decoderConfiguration: decoderConfiguration,
                                           retryConfiguration: retryConfiguration,
                                           eventMonitors: eventMonitors, requestAdapters: requestAdapters,
                                           cacheConfiguration: cacheConfiguration)
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

}

// Untappd API endpoint methods live in CDUntappdAPIClient+UserEndpoints.swift and
// CDUntappdAPIClient+ContentEndpoints.swift, split out to keep this file's type body
// under the shared type_body_length threshold.

extension CDUntappdAPIClient {

    /// Creates an Untappd API client.
    /// - Parameters:
    ///   - clientId: Your Untappd application client ID.
    ///   - clientSecret: Your Untappd application client secret. Do not share this key.
    ///   - redirectUrl: The OAuth redirect URL registered with your application.
    ///   - retryConfiguration: Configuration for automatic retry with exponential backoff on
    ///     transient failures and rate-limit responses. Defaults to `.disabled`.
    ///   - eventMonitors: Observers notified of request/response lifecycle events. Defaults to none.
    ///   - requestAdapters: Adapters run in order to mutate each outgoing request before it is sent.
    ///     Defaults to none.
    ///   - cacheConfiguration: Configuration for the built-in in-memory response cache applied to
    ///     `GET` requests. Defaults to `.disabled`.
    ///   - decoderConfiguration: Configuration for `JSONDecoder`'s key and date decoding strategies.
    ///     Defaults to `.default`.
    public convenience init(clientId: String, clientSecret: String, redirectUrl: String,
                            retryConfiguration: CDUntappdRetryConfiguration = .disabled,
                            eventMonitors: [any CDUntappdEventMonitor] = [], requestAdapters: [any CDUntappdRequestAdapter] = [],
                            cacheConfiguration: CDUntappdCacheConfiguration = .disabled,
                            decoderConfiguration: CDUntappdDecoderConfiguration = .default) {
        self.init(clientId: clientId, clientSecret: clientSecret, redirectUrl: redirectUrl, urlSession: URLSession(configuration: .default),
                  retryConfiguration: retryConfiguration, eventMonitors: eventMonitors, requestAdapters: requestAdapters,
                  cacheConfiguration: cacheConfiguration, decoderConfiguration: decoderConfiguration)
    }
}
