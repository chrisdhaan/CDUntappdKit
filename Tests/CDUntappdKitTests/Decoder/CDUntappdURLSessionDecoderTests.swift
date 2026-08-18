//
//  CDUntappdURLSessionDecoderTests.swift
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

@Suite("CDUntappdURLSession Decoder Tests")
struct CDUntappdURLSessionDecoderTests {

    private struct Fixture: Decodable, Equatable {
        let helloWorld: String
    }

    private func makeRequest(path: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.untappd.com/v4/decoder/\(path)")!)
        request.httpMethod = "GET"
        return request
    }

    @Test
    func defaultDecoderConfigurationDoesNotConvertSnakeCaseKeys() async throws {
        let request = makeRequest(path: "default-config")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"hello_world":"test"}"#.utf8)),
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())

        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected decoding to fail without .convertFromSnakeCase")
        } catch is CDUntappdKitError {
            // Expected — the default decoder does not convert snake_case keys.
        }
    }

    @Test
    func customDecoderConfigurationConvertsSnakeCaseKeys() async throws {
        let request = makeRequest(path: "custom-config")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"hello_world":"test"}"#.utf8)),
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            decoderConfiguration: CDUntappdDecoderConfiguration(keyDecodingStrategy: .convertFromSnakeCase)
        )

        let result: Fixture = try await session.perform(request)

        #expect(result == Fixture(helloWorld: "test"))
    }
}
