//
//  CDUntappdKitTestingProductTests.swift
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

import CDUntappdKit
import CDUntappdKitTesting
import Foundation
import Testing

/// Exercises `CDUntappdKitTesting` exactly as a downstream consumer would: without
/// `@testable`, using only the public `CDUntappdAPIClient(... urlSession:)` initializer and
/// `CDUntappdMockURLProtocol` to mock a real request/response round trip.
@Suite("CDUntappdKitTesting Product Tests")
@MainActor
struct CDUntappdKitTestingProductTests {
    @Test
    func publicInitWithMockedSessionFetchesUserInfo() async throws {
        let clientId = "public-surface-client-id"
        let clientSecret = "public-surface-client-secret"

        var params: Parameters = ["compact": false]
        params["client_id"] = clientId
        params["client_secret"] = clientSecret
        let request = try CDUntappdRouter.userInfo(username: "public-surface-user", parameters: params).asURLRequest()
        let url = try #require(request.url)

        let json = """
        {"meta": {"code": 200}, "response": {"user": {"user_name": "public-surface-user"}}}
        """
        CDUntappdMockURLProtocol.register(stub: .init(statusCode: 200, data: Data(json.utf8)), for: url)

        let client = CDUntappdAPIClient(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectUrl: "testapp://oauth",
            urlSession: CDUntappdMockURLProtocol.makeSession()
        )

        let response = try await client.fetchUserInfo(forUsername: "public-surface-user", compact: false)
        #expect(response.user?.username == "public-surface-user")
    }
}
