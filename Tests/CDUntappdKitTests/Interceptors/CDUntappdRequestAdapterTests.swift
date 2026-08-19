import CDUntappdKitTesting
import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdRequestAdapter Tests")
struct CDUntappdRequestAdapterTests {

    private struct Fixture: Decodable, Equatable {
        let value: String
    }

    private final class HeaderInjectingAdapter: CDUntappdRequestAdapter, @unchecked Sendable {
        func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            var request = urlRequest
            request.setValue("trace-123", forHTTPHeaderField: "X-Trace-Id")
            return request
        }
    }

    private final class ThrowingAdapter: CDUntappdRequestAdapter, @unchecked Sendable {
        struct AdapterError: Error {}
        func adapt(_: URLRequest) throws -> URLRequest {
            throw AdapterError()
        }
    }

    private func makeRequest(path: String) -> URLRequest {
        URLRequest(url: URL(string: "https://api.untappd.com/v4/adapter/\(path)")!)
    }

    @Test
    func adapterMutatesOutgoingRequestHeaders() async throws {
        let request = makeRequest(path: "header-injection")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            requestAdapters: [HeaderInjectingAdapter()]
        )

        let result: Fixture = try await session.perform(request)

        #expect(result == Fixture(value: "ok"))
    }

    @Test
    func adapterFailureIsWrappedAsInvalidRequest() async throws {
        let request = makeRequest(path: "adapter-throws")
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            requestAdapters: [ThrowingAdapter()]
        )

        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .invalidRequest to be thrown")
        } catch let CDUntappdKitError.invalidRequest(underlying) {
            #expect(underlying is ThrowingAdapter.AdapterError)
        }
    }

    @Test
    func adaptedRequestRunsOnceNotOncePerRetryAttempt() async throws {
        let request = makeRequest(path: "adapt-once")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(statusCode: 503, data: Data()),
                .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            ],
            for: #require(request.url)
        )
        let adapter = CountingAdapter()
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 3, initialDelay: 0.01),
            requestAdapters: [adapter]
        )

        let result: Fixture = try await session.perform(request)

        #expect(result == Fixture(value: "ok"))
        #expect(adapter.adaptCallCount == 1)
    }

    private final class CountingAdapter: CDUntappdRequestAdapter, @unchecked Sendable {
        private let lock = NSLock()
        private var _adaptCallCount = 0

        var adaptCallCount: Int {
            lock.lock()
            defer { lock.unlock() }
            return _adaptCallCount
        }

        func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            lock.lock()
            _adaptCallCount += 1
            lock.unlock()
            return urlRequest
        }
    }
}
