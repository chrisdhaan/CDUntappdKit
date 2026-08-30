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
/// Supports retry (`CDUntappdRetryConfiguration`), event monitoring (`CDUntappdEventMonitor`),
/// request adaptation (`CDUntappdRequestAdapter`), and an opt-in in-memory response cache
/// (`CDUntappdCacheConfiguration`) for `GET` requests.
actor CDUntappdURLSession {

    // Not private: read by CDUntappdURLSession+RetrySupport.swift's cancelAllTasks().
    let session: URLSession
    private let decoder: JSONDecoder
    // Not private: read by CDUntappdURLSession+RetrySupport.swift's shouldRetry/backoffNanoseconds.
    let retryConfiguration: CDUntappdRetryConfiguration
    // Not private: read by CDUntappdURLSession+RetrySupport.swift's notify*(_:) methods.
    let eventMonitors: [any CDUntappdEventMonitor]
    private let requestAdapters: [any CDUntappdRequestAdapter]
    private let cache: CDUntappdResponseCache?
    // Not private: read/written by CDUntappdURLSession+RetrySupport.swift.
    var retrySleepTasks: [UUID: Task<Void, any Error>] = [:]

    /// Not private: read by CDUntappdURLSession+RetrySupport.swift's shouldRetry(_:httpMethod:attempt:).
    /// HTTP methods safe to automatically resend without risking a duplicate side effect —
    /// notably excludes POST, so a retried POST write/action request (e.g. `addCheckin`,
    /// `toast`, `addComment`) can never be silently submitted twice. This does NOT cover every
    /// write/action endpoint: `addFriend`/`removeFriend`/`acceptFriend`/`rejectFriend`/
    /// `addToWishList`/`removeFromWishList` are `GET` requests per `CDUntappdRouter`, so they're
    /// retried like any other idempotent call — whether repeating one of those state changes is
    /// actually a server-side no-op isn't documented in `Documentation/API_SCHEMA.md` and hasn't
    /// been live-verified.
    static let idempotentHTTPMethods: Set<String> = ["DELETE", "GET", "HEAD", "OPTIONS", "PUT", "TRACE"]

    init(
        session: URLSession = .shared,
        decoderConfiguration: CDUntappdDecoderConfiguration = .default,
        retryConfiguration: CDUntappdRetryConfiguration = .disabled,
        eventMonitors: [any CDUntappdEventMonitor] = [],
        requestAdapters: [any CDUntappdRequestAdapter] = [],
        cacheConfiguration: CDUntappdCacheConfiguration = .disabled
    ) {
        self.session = session
        self.decoder = decoderConfiguration.makeDecoder()
        self.retryConfiguration = retryConfiguration
        self.eventMonitors = eventMonitors
        self.requestAdapters = requestAdapters
        self.cache = cacheConfiguration.ttl > 0 ? CDUntappdResponseCache(configuration: cacheConfiguration) : nil
    }

    /// Decoding happens after `performRequest` returns, so a decode failure is reported to
    /// `eventMonitors` as its own terminal outcome here — `performRequest` only ever notifies
    /// monitors of the HTTP-level result, not whether the body could be decoded.
    ///
    /// A cache write only ever happens after a successful decode (`result.cacheKey` is only
    /// non-nil on a live, cacheable fetch — never on a cache hit, which has nothing new to
    /// write), so a corrupted or transient response can never poison the cache. Conversely, if
    /// decoding a *cached* entry fails (e.g. its shape no longer matches `T`, such as after an
    /// app update), that entry is evicted so the next call for the same key hits the network
    /// fresh rather than repeatedly failing against the same stale bytes.
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let result = try await performRequest(request)
        do {
            let decoded = try decoder.decode(T.self, from: result.data)
            notifyComplete(result.request, response: result.response, data: result.data, error: nil)
            if let cacheKey = result.cacheKey {
                cache?.set(data: result.data, forKey: cacheKey)
            }
            return decoded
        } catch {
            let wrapped = CDUntappdKitError.decodingFailed(underlying: error)
            notifyComplete(result.request, response: result.response, data: result.data, error: wrapped)
            if result.servedFromCache {
                cache?.remove(forKey: CDUntappdCacheKey.key(for: result.request))
            }
            throw wrapped
        }
    }

    /// Removes every entry from the response cache, if caching is enabled.
    nonisolated func clearCache() {
        cache?.removeAll()
    }

    /// Performs a request that returns no body (e.g. an HTTP 204 response), validating only the
    /// status code. Used for endpoints like `removeComment` where there's nothing to decode.
    func perform(_ request: URLRequest) async throws {
        let result = try await performRequest(request)
        notifyComplete(result.request, response: result.response, data: result.data, error: nil)
    }

    /// The successful outcome of `performRequest`: the response body, alongside the adapted
    /// request and HTTP response that produced it, so callers can notify `eventMonitors` of
    /// their own terminal outcome (e.g. a decode failure). `response` is `nil` for a cache hit,
    /// which never touches the network. `cacheKey` is non-nil only for a live, cacheable fetch —
    /// signaling to `perform<T>` that a successful decode should be written to the cache;
    /// `servedFromCache` signals the opposite case, that a decode failure should evict the
    /// now-suspect cached entry instead.
    private struct PerformResult {
        let data: Data
        let request: URLRequest
        let response: HTTPURLResponse?
        let cacheKey: String?
        let servedFromCache: Bool
    }

    /// Sends `request`, retrying per `retryConfiguration` on transient failures, and returns the
    /// successful response. Every retry decision (idempotent method, retryable status/error
    /// code, attempts remaining) is centralized in `shouldRetry(...)` so both `perform` overloads
    /// share identical retry behavior. Does not itself notify monitors of a successful HTTP
    /// response — only of terminal failures — leaving success notification to the callers above.
    private func performRequest(_ originalRequest: URLRequest) async throws -> PerformResult {
        let request: URLRequest
        do {
            request = try adaptedRequest(from: originalRequest)
        } catch {
            let wrapped = (error as? CDUntappdKitError) ?? .invalidRequest(underlying: error)
            notifyStart(originalRequest)
            notifyComplete(originalRequest, response: nil, data: nil, error: wrapped)
            throw wrapped
        }

        // Cache key is computed from the *adapted* request — consistent with retry eligibility
        // above, which also decides from the adapted request rather than the original one (see
        // CDUntappdRequestAdapter's doc comment). Only GET requests are ever cacheable.
        let cacheKey: String? = (cache != nil && request.httpMethod?.uppercased() == "GET")
            ? CDUntappdCacheKey.key(for: request) : nil
        if let cacheKey, let cachedData = cache?.data(forKey: cacheKey) {
            notifyStart(request)
            return PerformResult(data: cachedData, request: request, response: nil, cacheKey: nil, servedFromCache: true)
        }

        notifyStart(request)
        return try await sendWithRetry(request, cacheKey: cacheKey)
    }

    /// The retry loop proper, factored out of `performRequest` so each stays under the shared
    /// function_body_length threshold. `cacheKey` is threaded through unchanged from the caller —
    /// it only ever affects the final successful `PerformResult`, never the retry decisions here.
    private func sendWithRetry(_ request: URLRequest, cacheKey: String?) async throws -> PerformResult {
        var attempt: UInt = 0
        while true {
            let data: Data
            let httpResponse: HTTPURLResponse?
            do {
                let (responseData, response) = try await session.data(for: request)
                data = responseData
                httpResponse = response as? HTTPURLResponse
            } catch {
                try await retryOrThrow(.networkFailure(underlying: error), request: request, attempt: &attempt, response: nil, data: nil)
                continue
            }

            guard let httpResponse else {
                try await retryOrThrow(
                    .networkFailure(underlying: URLError(.badServerResponse)),
                    request: request,
                    attempt: &attempt,
                    response: nil,
                    data: data
                )
                continue
            }

            guard (200 ..< 300).contains(httpResponse.statusCode) else {
                let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, field in
                    guard let key = field.key as? String else { return }
                    result[key] = "\(field.value)"
                }
                try await retryOrThrow(
                    .httpErrorWithHeaders(statusCode: httpResponse.statusCode, data: data, headers: headers),
                    request: request,
                    attempt: &attempt,
                    response: httpResponse,
                    data: data
                )
                continue
            }

            return PerformResult(data: data, request: request, response: httpResponse, cacheKey: cacheKey, servedFromCache: false)
        }
    }

    /// Runs `requestAdapters` in order, once per logical call (not once per retry attempt — see
    /// `CDUntappdRequestAdapter`'s doc comment). Restores any framework-set header an adapter
    /// stripped entirely — currently just `Content-Type` on POST requests (`CDUntappdRouter`
    /// never sets an auth header; OAuth credentials travel as URL query parameters, which this
    /// restoration does not touch and an adapter that replaces `request.url` can still drop). An
    /// adapter that sets a *different* value for a header (e.g. token rotation) keeps its
    /// replacement.
    private func adaptedRequest(from originalRequest: URLRequest) throws -> URLRequest {
        var request = originalRequest
        let originalHeaders = originalRequest.allHTTPHeaderFields ?? [:]
        for adapter in requestAdapters {
            request = try adapter.adapt(request)
        }
        for (header, originalValue) in originalHeaders where request.value(forHTTPHeaderField: header) == nil {
            request.setValue(originalValue, forHTTPHeaderField: header)
        }
        return request
    }

    /// Sleeps for the backoff interval and advances `attempt` if `error` should be retried;
    /// otherwise notifies monitors of the terminal failure and throws `error` (or a cancellation
    /// error from the backoff sleep itself).
    private func retryOrThrow(
        _ error: CDUntappdKitError,
        request: URLRequest,
        attempt: inout UInt,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws {
        guard shouldRetry(error, httpMethod: request.httpMethod, attempt: attempt) else {
            notifyComplete(request, response: response, data: data, error: error)
            throw error
        }
        notifyRetry(request, retryCount: Int(attempt + 1))
        do {
            try await trackedSleep(nanoseconds: backoffNanoseconds(attempt: attempt))
        } catch {
            notifyComplete(request, response: response, data: data, error: error)
            throw error
        }
        attempt += 1
    }
}

// notifyStart/notifyComplete/notifyRetry, shouldRetry, backoffNanoseconds, trackedSleep, and
// cancelAllTasks live in CDUntappdURLSession+RetrySupport.swift, split out to keep this file's
// type body under the shared type_body_length threshold.
