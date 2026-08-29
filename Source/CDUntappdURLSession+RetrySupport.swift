//
//  CDUntappdURLSession+RetrySupport.swift
//  CDUntappdKit
//
//  Created by Christopher de Haan on 8/29/26.
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

extension CDUntappdURLSession {

    /// Not private: called from CDUntappdURLSession.swift's performRequest(_:) and retryOrThrow(...).
    func notifyStart(_ request: URLRequest) {
        for monitor in eventMonitors {
            monitor.requestDidStart(urlRequest: request)
        }
    }

    /// Not private: called from CDUntappdURLSession.swift's perform<T>(_:), performRequest(_:),
    /// and retryOrThrow(...).
    func notifyComplete(_ request: URLRequest, response: HTTPURLResponse?, data: Data?, error: (any Error)?) {
        for monitor in eventMonitors {
            monitor.requestDidComplete(urlRequest: request, response: response, data: data, error: error)
        }
    }

    /// Not private: called from CDUntappdURLSession.swift's retryOrThrow(...).
    func notifyRetry(_ request: URLRequest, retryCount: Int) {
        for monitor in eventMonitors {
            monitor.requestWillRetry(urlRequest: request, retryCount: retryCount)
        }
    }

    /// Not private: called from CDUntappdURLSession.swift's retryOrThrow(...).
    func shouldRetry(_ error: CDUntappdKitError, httpMethod: String?, attempt: UInt) -> Bool {
        guard attempt < retryConfiguration.retryLimit else { return false }
        guard let httpMethod, Self.idempotentHTTPMethods.contains(httpMethod.uppercased()) else { return false }
        switch error {
        case let .httpErrorWithHeaders(statusCode, _, _):
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

    /// Not private: called from CDUntappdURLSession.swift's retryOrThrow(...).
    func backoffNanoseconds(attempt: UInt) -> UInt64 {
        let maxDelay: TimeInterval = 60
        let delay = min(retryConfiguration.initialDelay * pow(2.0, Double(attempt)), maxDelay)
        return UInt64(max(0, delay) * 1_000_000_000)
    }

    /// Not private: called from CDUntappdURLSession.swift's retryOrThrow(...).
    /// Sleeps for `nanoseconds`, tracked in `retrySleepTasks` so `cancelAllTasks()` can cancel a
    /// pending retry's backoff wait — a plain `URLSession` task cancel wouldn't reach it, since
    /// no network task is in flight during the sleep.
    func trackedSleep(nanoseconds: UInt64) async throws {
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
