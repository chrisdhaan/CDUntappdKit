//
//  CDUntappdURLSession.swift
//  CDUntappdKit
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

/// A minimal request/decode pipeline over `URLSession`, replacing `Alamofire.Session`.
///
/// Deliberately has no cache, retry, or request-adapter support — those are separate,
/// not-yet-built features that will extend this actor later.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor CDUntappdURLSession {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw CDUntappdKitError.networkFailure(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CDUntappdKitError.networkFailure(underlying: URLError(.badServerResponse))
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw CDUntappdKitError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw CDUntappdKitError.decodingFailed(underlying: error)
        }
    }

    /// Performs a request that returns no body (e.g. an HTTP 204 response), validating only the
    /// status code. Used for endpoints like `removeComment` where there's nothing to decode.
    func perform(_ request: URLRequest) async throws {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw CDUntappdKitError.networkFailure(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CDUntappdKitError.networkFailure(underlying: URLError(.badServerResponse))
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw CDUntappdKitError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    /// Cancels all in-flight requests and suspends until they've actually finished cancelling —
    /// not just until cancellation has been requested.
    ///
    /// Polls for up to ~5 seconds (500 attempts, 10ms apart); if tasks are still outstanding
    /// after that, returns anyway on a best-effort basis rather than suspending indefinitely.
    func cancelAllTasks() async {
        for task in await session.allTasks {
            task.cancel()
        }

        var remainingPollAttempts = 500
        while remainingPollAttempts > 0, await !session.allTasks.isEmpty {
            remainingPollAttempts -= 1
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}
