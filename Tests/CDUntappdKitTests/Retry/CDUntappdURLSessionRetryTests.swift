import CDUntappdKitTesting
import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdURLSession Retry Tests")
struct CDUntappdURLSessionRetryTests {

    private struct Fixture: Decodable, Equatable {
        let value: String
    }

    private func makeRequest(path: String, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.untappd.com/v4/retry/\(path)")!)
        request.httpMethod = method
        return request
    }

    @Test
    func retriesRetryableStatusCodeThenSucceeds() async throws {
        let request = makeRequest(path: "retry-then-succeed")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(statusCode: 503, data: Data()),
                .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            ],
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 3, initialDelay: 0.01)
        )
        let result: Fixture = try await session.perform(request)
        #expect(result == Fixture(value: "ok"))
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    @Test
    func throwsAfterExhaustingRetryLimit() async throws {
        let request = makeRequest(path: "retry-exhausted")
        try CDUntappdMockURLProtocol.register(stub: .init(statusCode: 503, data: Data()), for: #require(request.url))
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 2, initialDelay: 0.01)
        )
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .httpErrorWithHeaders to be thrown")
        } catch let CDUntappdKitError.httpErrorWithHeaders(statusCode, _, _) {
            #expect(statusCode == 503)
        }
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 3)
    }

    @Test
    func doesNotRetryNonRetryableStatusCode() async throws {
        let request = makeRequest(path: "non-retryable-status")
        try CDUntappdMockURLProtocol.register(stub: .init(statusCode: 404, data: Data()), for: #require(request.url))
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 3, initialDelay: 0.01)
        )
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .httpErrorWithHeaders to be thrown")
        } catch let CDUntappdKitError.httpErrorWithHeaders(statusCode, _, _) {
            #expect(statusCode == 404)
        }
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 1)
    }

    @Test
    func doesNotRetryPOSTEvenOnRetryableStatusCode() async throws {
        let request = makeRequest(path: "post-not-retried", method: "POST")
        try CDUntappdMockURLProtocol.register(stub: .init(statusCode: 503, data: Data()), for: #require(request.url))
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 3, initialDelay: 0.01)
        )
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .httpErrorWithHeaders to be thrown")
        } catch let CDUntappdKitError.httpErrorWithHeaders(statusCode, _, _) {
            #expect(statusCode == 503)
        }
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 1)
    }

    @Test
    func retriesTransientURLErrorThenSucceeds() async throws {
        let request = makeRequest(path: "transient-error")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(error: URLError(.timedOut)),
                .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            ],
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 3, initialDelay: 0.01)
        )
        let result: Fixture = try await session.perform(request)
        #expect(result == Fixture(value: "ok"))
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }

    @Test
    func doesNotRetryCancelledURLError() async throws {
        let request = makeRequest(path: "cancelled-not-retried")
        try CDUntappdMockURLProtocol.register(stub: .init(error: URLError(.cancelled)), for: #require(request.url))
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(
                retryLimit: 3,
                initialDelay: 0.01,
                retryableURLErrorCodes: [.cancelled]
            )
        )
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .networkFailure to be thrown")
        } catch let CDUntappdKitError.networkFailure(underlying) {
            #expect((underlying as? URLError)?.code == .cancelled)
        }
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 1)
    }

    @Test
    func defaultDisabledConfigurationNeverRetries() async throws {
        let request = makeRequest(path: "disabled-default")
        try CDUntappdMockURLProtocol.register(stub: .init(statusCode: 503, data: Data()), for: #require(request.url))
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .httpErrorWithHeaders to be thrown")
        } catch let CDUntappdKitError.httpErrorWithHeaders(statusCode, _, _) {
            #expect(statusCode == 503)
        }
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 1)
    }

    @Test
    func cancelAllTasksStopsAPendingRetryDuringBackoff() async throws {
        let request = makeRequest(path: "cancel-during-backoff")
        try CDUntappdMockURLProtocol.register(stub: .init(statusCode: 503, data: Data()), for: #require(request.url))
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 5, initialDelay: 5)
        )

        let performTask = Task<Fixture?, Never> {
            try? await session.perform(request) as Fixture?
        }

        // Let the first attempt land (server responds 503) and the backoff sleep begin,
        // before cancelling — this is the window a plain URLSession-task cancel wouldn't reach.
        while try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) < 1 {
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        try await Task.sleep(nanoseconds: 20_000_000)

        await session.cancelAllTasks()

        let result = await performTask.value
        #expect(result == nil)
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 1)
    }

    /// Also serves as the perform(_:) void-overload's retry coverage — same retry loop, not
    /// duplicated per behavior above.
    @Test
    func performVoidRetriesRetryableStatusCodeThenSucceeds() async throws {
        let request = makeRequest(path: "void-retry-then-succeed")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(statusCode: 503, data: Data()),
                .init(statusCode: 204, data: Data()),
            ],
            for: #require(request.url)
        )
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 3, initialDelay: 0.01)
        )
        try await session.perform(request)
        #expect(try CDUntappdMockURLProtocol.requestCount(for: #require(request.url)) == 2)
    }
}
