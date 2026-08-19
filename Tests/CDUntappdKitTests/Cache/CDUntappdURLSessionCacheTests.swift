import CDUntappdKitTesting
import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdURLSession Cache Tests")
struct CDUntappdURLSessionCacheTests {

    private struct Fixture: Decodable, Equatable {
        let value: String
    }

    private struct OtherFixture: Decodable, Equatable {
        let other: String
    }

    private func makeRequest(path: String, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.untappd.com/v4/cache/\(path)")!)
        request.httpMethod = method
        return request
    }

    @Test
    func secondIdenticalGETWithinTTLDoesNotHitTheNetwork() async throws {
        let request = makeRequest(path: "second-hit")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            cacheConfiguration: CDUntappdCacheConfiguration(ttl: 300)
        )

        let first: Fixture = try await session.perform(request)
        let second: Fixture = try await session.perform(request)

        #expect(first == Fixture(value: "ok"))
        #expect(second == Fixture(value: "ok"))
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 1)
    }

    @Test
    func expiredCacheEntryHitsTheNetworkAgain() async throws {
        let request = makeRequest(path: "expired-hit")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(statusCode: 200, data: Data(#"{"value":"first"}"#.utf8)),
                .init(statusCode: 200, data: Data(#"{"value":"second"}"#.utf8)),
            ],
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            cacheConfiguration: CDUntappdCacheConfiguration(ttl: 0.01)
        )

        let first: Fixture = try await session.perform(request)
        try await Task.sleep(nanoseconds: 50_000_000)
        let second: Fixture = try await session.perform(request)

        #expect(first == Fixture(value: "first"))
        #expect(second == Fixture(value: "second"))
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    @Test
    func postRequestsAreNeverCached() async throws {
        let request = makeRequest(path: "post-not-cached", method: "POST")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            cacheConfiguration: CDUntappdCacheConfiguration(ttl: 300)
        )

        let _: Fixture = try await session.perform(request)
        let _: Fixture = try await session.perform(request)

        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    @Test
    func defaultDisabledConfigurationNeverCaches() async throws {
        let request = makeRequest(path: "disabled-default")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())

        let _: Fixture = try await session.perform(request)
        let _: Fixture = try await session.perform(request)

        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    @Test
    func aFailedHTTPResponseIsNeverCached() async throws {
        let request = makeRequest(path: "error-not-cached")
        try CDUntappdMockURLProtocol.register(stub: .init(statusCode: 404, data: Data()), for: #require(request.url))
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            cacheConfiguration: CDUntappdCacheConfiguration(ttl: 300)
        )

        for _ in 0 ..< 2 {
            do {
                let _: Fixture = try await session.perform(request)
                Issue.record("Expected .httpErrorWithHeaders to be thrown")
            } catch let CDUntappdKitError.httpErrorWithHeaders(statusCode, _, _) {
                #expect(statusCode == 404)
            }
        }

        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    /// A cache entry that fails to decode against the type now requested (e.g. a stale shape
    /// after an app update) is evicted rather than poisoning every subsequent call — the next
    /// request for the same key hits the network fresh.
    @Test
    func aCorruptCacheEntrySelfHealsOnTheNextCall() async throws {
        let request = makeRequest(path: "corrupt-self-heals")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
                .init(statusCode: 200, data: Data(#"{"other":"fresh"}"#.utf8)),
            ],
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            cacheConfiguration: CDUntappdCacheConfiguration(ttl: 300)
        )

        let _: Fixture = try await session.perform(request)
        do {
            let _: OtherFixture = try await session.perform(request)
            Issue.record("Expected a decoding failure against the cached entry's shape")
        } catch is CDUntappdKitError {
            // expected — the cached entry doesn't decode as OtherFixture
        }
        let third: OtherFixture = try await session.perform(request)

        #expect(third == OtherFixture(other: "fresh"))
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    @Test
    func clearCacheForcesTheNextCallToHitTheNetwork() async throws {
        let request = makeRequest(path: "clear-cache")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(statusCode: 200, data: Data(#"{"value":"first"}"#.utf8)),
                .init(statusCode: 200, data: Data(#"{"value":"second"}"#.utf8)),
            ],
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            cacheConfiguration: CDUntappdCacheConfiguration(ttl: 300)
        )

        let first: Fixture = try await session.perform(request)
        session.clearCache()
        let second: Fixture = try await session.perform(request)

        #expect(first == Fixture(value: "first"))
        #expect(second == Fixture(value: "second"))
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    @Test
    func cacheHitNotifiesEventMonitorsWithAPairedStartAndComplete() async throws {
        let request = makeRequest(path: "cache-hit-monitor")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            for: #require(request.url)
        )
        final class SpyMonitor: CDUntappdEventMonitor, @unchecked Sendable {
            private let lock = NSLock()
            private var _startCount = 0
            private var _completeCount = 0
            var startCount: Int { lock.lock()
                defer { lock.unlock() }
                return _startCount
            }
            var completeCount: Int { lock.lock()
                defer { lock.unlock() }
                return _completeCount
            }
            func requestDidStart(urlRequest _: URLRequest) {
                lock.lock()
                _startCount += 1
                lock.unlock()
            }
            func requestDidComplete(urlRequest _: URLRequest?, response _: HTTPURLResponse?, data _: Data?, error _: Error?) {
                lock.lock()
                _completeCount += 1
                lock.unlock()
            }
            func requestWillRetry(urlRequest _: URLRequest?, retryCount _: Int) {}
        }
        let monitor = SpyMonitor()
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            eventMonitors: [monitor],
            cacheConfiguration: CDUntappdCacheConfiguration(ttl: 300)
        )

        let _: Fixture = try await session.perform(request)
        let _: Fixture = try await session.perform(request)

        #expect(monitor.startCount == 2)
        #expect(monitor.completeCount == 2)
    }
}
