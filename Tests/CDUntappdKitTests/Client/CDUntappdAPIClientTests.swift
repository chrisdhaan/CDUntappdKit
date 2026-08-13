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

@Suite("CDUntappdAPIClient Tests", .serialized)
@MainActor
struct CDUntappdAPIClientTests {

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

    @Test
    func fetchUserInfoDecodesSuccessfulResponse() async throws {
        let json = """
        {"meta": {"code": 200}, "response": {"user": {"user_name": "testuser"}}}
        """
        CDUntappdMockURLProtocol.stub = .init(statusCode: 200, data: Data(json.utf8))
        let client = CDUntappdAPIClient(
            clientId: "test_id",
            clientSecret: "test_secret",
            redirectUrl: "testapp://oauth",
            urlSession: CDUntappdMockURLProtocol.makeSession()
        )
        let response = try await client.fetchUserInfo(forUsername: "testuser", compact: false)
        #expect(response.user?.username == "testuser")
    }

    @Test
    func fetchUserInfoThrowsOnHTTPError() async throws {
        CDUntappdMockURLProtocol.stub = .init(statusCode: 500, data: Data())
        let client = CDUntappdAPIClient(
            clientId: "test_id",
            clientSecret: "test_secret",
            redirectUrl: "testapp://oauth",
            urlSession: CDUntappdMockURLProtocol.makeSession()
        )
        await #expect(throws: CDUntappdKitError.self) {
            _ = try await client.fetchUserInfo(forUsername: "testuser", compact: false)
        }
    }
}
