//
//  CDUntappdAPIClientTests.swift
//  CDUntappdKitTests
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
import Testing
@testable import CDUntappdKit

extension SharedUserDefaultsTests {

    @Suite("CDUntappdAPIClient Tests")
    @MainActor
    struct APIClient {

        let client = CDUntappdAPIClient(
            clientId: "test_id",
            clientSecret: "test_secret",
            redirectUrl: "testapp://oauth"
        )

        @Test
        func isNotAuthenticatedWithoutStoredToken() {
            UserDefaults.standard.removeObject(forKey: CDUntappdDefaults.accessToken)
            #expect(client.isAuthenticated() == false)
        }

        @Test
        func isAuthenticatedWhenTokenIsStored() {
            UserDefaults.standard.set("fake_token", forKey: CDUntappdDefaults.accessToken)
            #expect(client.isAuthenticated() == true)
            UserDefaults.standard.removeObject(forKey: CDUntappdDefaults.accessToken)
        }

        @Test
        func unauthenticateClearsStoredToken() {
            UserDefaults.standard.set("fake_token", forKey: CDUntappdDefaults.accessToken)
            client.unauthenticate()
            #expect(client.isAuthenticated() == false)
        }

        /// `CDUntappdAPIClient.fetchUserInfo` builds its own `URLRequest` internally via
        /// `CDUntappdRouter`, so the test can't attach a stub to that specific request instance
        /// the way `CDUntappdURLSessionTests` does (`URLProtocol.setProperty` is tied to request
        /// object identity, and a separately-built "equivalent" request is a different object).
        /// Instead, replicate the exact same parameter-building the client does internally
        /// (`Parameters.userInfoParameters` + `CDUntappdOAuthClient.addTokens` +
        /// `CDUntappdRouter.userInfo(...).asURLRequest()`) to compute the identical `URL`, then
        /// register the stub against that `URL`. Each call site passes a distinct `username` so
        /// concurrently-running tests never collide on the same registered entry, per
        /// `CDUntappdMockURLProtocol`'s documented contract.
        private func expectedFetchUserInfoURL(forUsername username: String, compact: Bool) throws -> URL {
            var params = Parameters.userInfoParameters(isCompact: compact)
            let oAuthClient = CDUntappdOAuthClient(clientId: "test_id",
                                                   clientSecret: "test_secret",
                                                   redirectUrl: "testapp://oauth")
            params = oAuthClient.addTokens(toParameters: params)
            let request = try CDUntappdRouter.userInfo(username: username, parameters: params).asURLRequest()
            return try #require(request.url)
        }

        @Test
        func fetchUserInfoDecodesSuccessfulResponse() async throws {
            UserDefaults.standard.removeObject(forKey: CDUntappdDefaults.accessToken)
            let json = """
            {"meta": {"code": 200}, "response": {"user": {"user_name": "testuser"}}}
            """
            let url = try expectedFetchUserInfoURL(forUsername: "testuser-success", compact: false)
            CDUntappdMockURLProtocol.register(stub: .init(statusCode: 200, data: Data(json.utf8)), for: url)
            let client = CDUntappdAPIClient(
                clientId: "test_id",
                clientSecret: "test_secret",
                redirectUrl: "testapp://oauth",
                urlSession: CDUntappdMockURLProtocol.makeSession()
            )
            let response = try await client.fetchUserInfo(forUsername: "testuser-success", compact: false)
            #expect(response.user?.username == "testuser")
        }

        @Test
        func fetchUserInfoThrowsOnHTTPError() async throws {
            UserDefaults.standard.removeObject(forKey: CDUntappdDefaults.accessToken)
            let url = try expectedFetchUserInfoURL(forUsername: "testuser-http-error", compact: false)
            CDUntappdMockURLProtocol.register(stub: .init(statusCode: 500, data: Data()), for: url)
            let client = CDUntappdAPIClient(
                clientId: "test_id",
                clientSecret: "test_secret",
                redirectUrl: "testapp://oauth",
                urlSession: CDUntappdMockURLProtocol.makeSession()
            )
            do {
                _ = try await client.fetchUserInfo(forUsername: "testuser-http-error", compact: false)
                Issue.record("Expected .httpError to be thrown")
            } catch let CDUntappdKitError.httpError(statusCode, _) {
                #expect(statusCode == 500)
            }
        }
    }
}
