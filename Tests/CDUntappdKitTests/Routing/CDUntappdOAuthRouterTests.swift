//
//  CDUntappdOAuthRouterTests.swift
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

@Suite("CDUntappdOAuthRouter Tests")
struct CDUntappdOAuthRouterTests {

    @Test
    func authorizeRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "response_type": "code"]
        let request = try CDUntappdOAuthRouter.authorize(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func authorizeRouteContainsPath() throws {
        let parameters: [String: Any] = ["client_id": "test", "response_type": "code"]
        let request = try CDUntappdOAuthRouter.authorize(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("authorize") == true)
    }

    @Test
    func authorizeRouteUsesUntappdOAuthBase() throws {
        let parameters: [String: Any] = ["client_id": "test", "response_type": "code"]
        let request = try CDUntappdOAuthRouter.authorize(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("untappd.com/oauth/") == true)
    }

    @Test
    func authorizeRouteContainsClientId() throws {
        let parameters: [String: Any] = ["client_id": "test123", "response_type": "code"]
        let request = try CDUntappdOAuthRouter.authorize(parameters: parameters).asURLRequest()
        #expect(request.url?.query?.contains("client_id=test123") == true)
    }

    @Test
    func authorizeRouteContainsResponseType() throws {
        let parameters: [String: Any] = ["client_id": "test", "response_type": "code"]
        let request = try CDUntappdOAuthRouter.authorize(parameters: parameters).asURLRequest()
        #expect(request.url?.query?.contains("response_type=code") == true)
    }

    @Test
    func authorizeRouteIncludesAllQueryParameters() throws {
        let parameters: [String: Any] = [
            "client_id": "id123",
            "response_type": "code",
            "redirect_url": "myapp://oauth",
        ]
        let request = try CDUntappdOAuthRouter.authorize(parameters: parameters).asURLRequest()
        #expect(request.url?.query != nil)
        #expect(request.url?.query?.contains("client_id") == true)
        #expect(request.url?.query?.contains("response_type") == true)
        #expect(request.url?.query?.contains("redirect_url") == true)
    }
}
