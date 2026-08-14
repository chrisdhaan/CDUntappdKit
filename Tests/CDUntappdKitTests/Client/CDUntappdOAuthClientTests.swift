//
//  CDUntappdOAuthClientTests.swift
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

@Suite("CDUntappdOAuthClient Tests", .serialized)
@MainActor
struct CDUntappdOAuthClientTests {

    /// `CDUntappdOAuthClient.authorize` builds its own `URLRequest` internally via
    /// `CDUntappdOAuthRouter`, so tests can't attach a stub to a specific request instance
    /// (`URLProtocol.setProperty` is tied to request object identity). Instead, replicate the
    /// exact same parameter-building the client does internally to compute the identical
    /// `URL`, then register the stub against that `URL`. Each test passes a distinct `code`
    /// so concurrently-running tests never collide on the same registered entry.
    private func expectedAuthorizeURL(clientId: String, clientSecret: String,
                                      redirectUrl: String, code: String) throws -> URL {
        let params: Parameters = ["client_id": clientId,
                                  "client_secret": clientSecret,
                                  "response_type": "code",
                                  "redirect_url": redirectUrl,
                                  "code": code]
        let request = try CDUntappdOAuthRouter.authorize(parameters: params).asURLRequest()
        return try #require(request.url)
    }

    @Test
    func isNotAuthorizedInitially() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                          redirectUrl: "test://callback")
        #expect(client.isAuthorized() == false)
    }

    @Test
    func isAuthorizedAfterStoringToken() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                          redirectUrl: "test://callback")
        UserDefaults.standard.set("fake_token_123", forKey: "CDUntappdAccessToken")
        #expect(client.isAuthorized() == true)
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
    }

    @Test
    func accessTokenReturnsNilWhenNotAuthorized() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                          redirectUrl: "test://callback")
        #expect(client.accessToken() == nil)
    }

    @Test
    func accessTokenReturnsStoredToken() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                          redirectUrl: "test://callback")
        let expectedToken = "test_token_abc123"
        UserDefaults.standard.set(expectedToken, forKey: "CDUntappdAccessToken")
        #expect(client.accessToken() == expectedToken)
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
    }

    @Test
    func addTokensIncludesAccessTokenWhenAuthorized() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test_id", clientSecret: "test_secret",
                                          redirectUrl: "test://callback")
        let token = "stored_access_token"
        UserDefaults.standard.set(token, forKey: "CDUntappdAccessToken")

        let parameters: [String: Any] = ["param1": "value1"]
        let result = client.addTokens(toParameters: parameters)

        #expect(result["access_token"] as? String == token)
        #expect(result["param1"] as? String == "value1")
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
    }

    @Test
    func addTokensIncludesClientCredentialsWhenNotAuthorized() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test_id", clientSecret: "test_secret",
                                          redirectUrl: "test://callback")

        let parameters: [String: Any] = ["param1": "value1"]
        let result = client.addTokens(toParameters: parameters)

        #expect(result["client_id"] as? String == "test_id")
        #expect(result["client_secret"] as? String == "test_secret")
        #expect(result["param1"] as? String == "value1")
    }

    @Test
    func addTokensPrefersAccessTokenOverClientCredentials() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test_id", clientSecret: "test_secret",
                                          redirectUrl: "test://callback")
        let token = "access_token_xyz"
        UserDefaults.standard.set(token, forKey: "CDUntappdAccessToken")

        let parameters: [String: Any] = [:]
        let result = client.addTokens(toParameters: parameters)

        #expect(result["access_token"] as? String == token)
        #expect(result["client_id"] == nil)
        #expect(result["client_secret"] == nil)
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
    }

    @Test
    func clientStoresProperties() {
        let client = CDUntappdOAuthClient(clientId: "my_client_id", clientSecret: "my_secret",
                                          redirectUrl: "myapp://oauth")
        #expect(client.clientId == "my_client_id")
        #expect(client.clientSecret == "my_secret")
        #expect(client.redirectUrl == "myapp://oauth")
    }

    @Test
    func multipleClientsShareUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")

        let client1 = CDUntappdOAuthClient(clientId: "id1", clientSecret: "secret1",
                                           redirectUrl: "app1://oauth")
        let client2 = CDUntappdOAuthClient(clientId: "id2", clientSecret: "secret2",
                                           redirectUrl: "app2://oauth")

        UserDefaults.standard.set("shared_token", forKey: "CDUntappdAccessToken")

        #expect(client1.isAuthorized() == true)
        #expect(client2.isAuthorized() == true)
        #expect(client1.accessToken() == client2.accessToken())

        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
    }

    @Test
    func clearingTokenRemovesAuthorization() {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                          redirectUrl: "test://callback")

        UserDefaults.standard.set("temporary_token", forKey: "CDUntappdAccessToken")
        #expect(client.isAuthorized() == true)

        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        #expect(client.isAuthorized() == false)
    }

    @Test
    func authorizeStoresAccessTokenOnSuccess() async throws {
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
        let url = try expectedAuthorizeURL(clientId: "test", clientSecret: "test",
                                           redirectUrl: "test://callback", code: "auth_code_success")
        CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"response": {"access_token": "new_token_456"}}"#.utf8)),
            for: url
        )
        let client = CDUntappdOAuthClient(
            clientId: "test", clientSecret: "test", redirectUrl: "test://callback",
            urlSession: CDUntappdMockURLProtocol.makeSession()
        )
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool?, Error>) in
            client.authorize(withCode: "auth_code_success") { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
        #expect(result == true)
        #expect(UserDefaults.standard.string(forKey: "CDUntappdAccessToken") == "new_token_456")
        UserDefaults.standard.removeObject(forKey: "CDUntappdAccessToken")
    }

    @Test
    func authorizeReportsFailureOnHTTPError() async throws {
        let url = try expectedAuthorizeURL(clientId: "test", clientSecret: "test",
                                           redirectUrl: "test://callback", code: "auth_code_http_error")
        CDUntappdMockURLProtocol.register(stub: .init(statusCode: 401, data: Data()), for: url)
        let client = CDUntappdOAuthClient(
            clientId: "test", clientSecret: "test", redirectUrl: "test://callback",
            urlSession: CDUntappdMockURLProtocol.makeSession()
        )
        let (success, error) = await withCheckedContinuation { (continuation: CheckedContinuation<(Bool?, Error?), Never>) in
            client.authorize(withCode: "auth_code_http_error") { success, error in
                continuation.resume(returning: (success, error))
            }
        }
        #expect(success == false)
        #expect(error != nil)
    }

    @Test
    func authorizeReturnsFalseImmediatelyForEmptyCode() {
        let client = CDUntappdOAuthClient(clientId: "test", clientSecret: "test",
                                          redirectUrl: "test://callback")
        var capturedSuccess: Bool?
        client.authorize(withCode: "") { success, _ in
            capturedSuccess = success
        }
        #expect(capturedSuccess == false)
    }
}
