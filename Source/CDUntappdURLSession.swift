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
/// Deliberately has no cache or request-adapter support — those are separate, not-yet-built
/// features that will extend this actor later.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor CDUntappdURLSession {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let retryConfiguration: CDUntappdRetryConfiguration
    private var retrySleepTasks: [UUID: Task<Void, any Error>] = [:]

    /// HTTP methods safe to automatically resend without risking a duplicate side effect —
    /// notably excludes POST, so a retried POST write/action request (e.g. `addCheckin`,
    /// `toast`, `addComment`) can never be silently submitted twice. This does NOT cover every
    /// write/action endpoint: `addFriend`/`removeFriend`/`acceptFriend`/`rejectFriend`/
    /// `addToWishList`/`removeFromWishList` are `GET` requests per `CDUntappdRouter`, so they're
    /// retried like any other idempotent call — whether repeating one of those state changes is
    /// actually a server-side no-op isn't documented in `Documentation/API_SCHEMA.md` and hasn't
    /// been live-verified.
    private static let idempotentHTTPMethods: Set<String> = ["DELETE", "GET", "HEAD", "OPTIONS", "PUT", "TRACE"]

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        retryConfiguration: CDUntappdRetryConfiguration = .disabled
    ) {
        self.session = session
        self.decoder = decoder
        self.retryConfiguration = retryConfiguration
    }

    func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data = try await performRequest(request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw CDUntappdKitError.decodingFailed(underlying: error)
        }
    }

    /// Performs a request that returns no body (e.g. an HTTP 204 response), validating only the
    /// status code. Used for endpoints like `removeComment` where there's nothing to decode.
    func perform(_ request: URLRequest) async throws {
        _ = try await performRequest(request)
    }

    /// Sends `request`, retrying per `retryConfiguration` on transient failures, and returns the
    /// successful response body. Every retry decision (idempotent method, retryable status/error
    /// code, attempts remaining) is centralized in `shouldRetry(...)` so both `perform` overloads
    /// share identical retry behavior.
    private func performRequest(_ request: URLRequest) async throws -> Data {
        var attempt: UInt = 0
        while true {
            let data: Data
            let httpResponse: HTTPURLResponse?
            do {
                let (responseData, response) = try await session.data(for: request)
                data = responseData
                httpResponse = response as? HTTPURLResponse
            } catch {
                try await retryOrThrow(.networkFailure(underlying: error), request: request, attempt: &attempt)
                continue
            }

            guard let httpResponse else {
                try await retryOrThrow(
                    .networkFailure(underlying: URLError(.badServerResponse)),
                    request: request,
                    attempt: &attempt
                )
                continue
            }

            guard (200 ..< 300).contains(httpResponse.statusCode) else {
                try await retryOrThrow(
                    .httpError(statusCode: httpResponse.statusCode, data: data),
                    request: request,
                    attempt: &attempt
                )
                continue
            }

            return data
        }
    }

    /// Sleeps for the backoff interval and advances `attempt` if `error` should be retried;
    /// otherwise throws `error` (or a cancellation error from the backoff sleep itself).
    private func retryOrThrow(_ error: CDUntappdKitError, request: URLRequest, attempt: inout UInt) async throws {
        guard shouldRetry(error, httpMethod: request.httpMethod, attempt: attempt) else {
            throw error
        }
        try await trackedSleep(nanoseconds: backoffNanoseconds(attempt: attempt))
        attempt += 1
    }

    private func shouldRetry(_ error: CDUntappdKitError, httpMethod: String?, attempt: UInt) -> Bool {
        guard attempt < retryConfiguration.retryLimit else { return false }
        guard let httpMethod, Self.idempotentHTTPMethods.contains(httpMethod.uppercased()) else { return false }
        switch error {
        case let .httpError(statusCode, _):
            return retryConfiguration.retryableHTTPStatusCodes.contains(statusCode)
        case let .networkFailure(underlying):
            guard let urlError = underlying as? URLError else { return false }
            // .cancelled must never be retried, even if a caller's retryableURLErrorCodes
            // includes it — cancelAllTasks() must reliably terminate an in-flight request
            // rather than have it silently resent.
            guard urlError.code != .cancelled else { return false }
            return retryConfiguration.retryableURLErrorCodes.contains(urlError.code)
        default:
            return false
        }
    }

    private func backoffNanoseconds(attempt: UInt) -> UInt64 {
        let maxDelay: TimeInterval = 60
        let delay = min(retryConfiguration.initialDelay * pow(2.0, Double(attempt)), maxDelay)
        return UInt64(max(0, delay) * 1_000_000_000)
    }

    /// Sleeps for `nanoseconds`, tracked in `retrySleepTasks` so `cancelAllTasks()` can cancel a
    /// pending retry's backoff wait — a plain `URLSession` task cancel wouldn't reach it, since
    /// no network task is in flight during the sleep.
    private func trackedSleep(nanoseconds: UInt64) async throws {
        let id = UUID()
        let task = Task<Void, any Error> { try await Task.sleep(nanoseconds: nanoseconds) }
        retrySleepTasks[id] = task
        defer {
            task.cancel()
            retrySleepTasks.removeValue(forKey: id)
        }
        do {
            try await withTaskCancellationHandler {
                try await task.value
            } onCancel: {
                task.cancel()
            }
        } catch {
            throw CDUntappdKitError.networkFailure(underlying: error)
        }
    }

    /// Cancels all in-flight requests and any Tasks sleeping during retry backoff, and suspends
    /// until they've actually finished cancelling — not just until cancellation has been
    /// requested.
    ///
    /// Polls for up to ~5 seconds (500 attempts, 10ms apart); if tasks are still outstanding
    /// after that, returns anyway on a best-effort basis rather than suspending indefinitely.
    func cancelAllTasks() async {
        for task in retrySleepTasks.values {
            task.cancel()
        }
        retrySleepTasks.removeAll()

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
